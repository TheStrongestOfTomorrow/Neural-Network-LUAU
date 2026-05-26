-- markov.lua - Markov Chain Engine
-- Handles unigram, bigram, and trigram Markov chain learning and generation

local Utils = require(script.Parent.utils)

local Markov = {}
Markov.__index = Markov

--- Create a new Markov engine instance
---@param modelConfig table Model configuration
---@return Markov
function Markov.new(modelConfig)
	local self = setmetatable({}, Markov)
	self.unigram = {}
	self.bigram = {}
	self.trigram = {}
	self.config = modelConfig
	return self
end

--- Learn from text
---@param text string
---@param learningRate? number
function Markov:learn(text, learningRate)
	local tokens = Utils.tokenize(text)
	if #tokens < 2 then return end
	
	local lr = learningRate or 0.05
	local inc = Utils.clamp(math.ceil(lr * 20), 1, 100)
	
	-- Unigram transitions
	for i = 1, #tokens-1 do
		local k = tokens[i]
		if not self.unigram[k] then self.unigram[k] = {} end
		self.unigram[k][tokens[i+1]] = (self.unigram[k][tokens[i+1]] or 0) + inc
	end
	
	-- Bigram transitions (if model supports it)
	if self.config.markovOrder >= 2 then
		for i = 1, #tokens-2 do
			local k = tokens[i].."_"..tokens[i+1]
			if not self.bigram[k] then self.bigram[k] = {} end
			self.bigram[k][tokens[i+2]] = (self.bigram[k][tokens[i+2]] or 0) + inc
		end
	end
	
	-- Trigram transitions (if model supports it)
	if self.config.markovOrder >= 2 and #tokens >= 4 then
		for i = 1, #tokens-3 do
			local k = tokens[i].."_"..tokens[i+1].."_"..tokens[i+2]
			if not self.trigram[k] then self.trigram[k] = {} end
			self.trigram[k][tokens[i+3]] = (self.trigram[k][tokens[i+3]] or 0) + inc
		end
	end
end

--- Sample next token from candidates with temperature and nucleus sampling
---@param nexts table Dictionary of word -> count
---@param temp number Temperature for sampling
---@param topK number Top-K filtering
---@param topP number Nucleus sampling threshold
---@return string?
function Markov:sample(nexts, temp, topK, topP)
	if not nexts then return nil end
	
	temp = temp or 1.0
	local pool, weights, total = {}, {}, 0
	
	-- Apply temperature scaling
	for word, count in pairs(nexts) do
		local w = count ^ (1/temp)
		table.insert(pool, word)
		table.insert(weights, w)
		total += w
	end
	
	if total == 0 then return nil end
	
	-- Top-K filtering
	if topK and topK > 0 and #pool > topK then
		local paired = {}
		for i, w in ipairs(weights) do 
			table.insert(paired, {w=w, p=pool[i]}) 
		end
		table.sort(paired, function(a,b) return a.w > b.w end)
		
		pool, weights, total = {}, {}, 0
		for i = 1, math.min(topK, #paired) do
			table.insert(pool, paired[i].p)
			table.insert(weights, paired[i].w)
			total += paired[i].w
		end
	end
	
	-- Nucleus (top-P) sampling
	if topP and topP < 1.0 and #pool > 1 then
		local paired = {}
		for i, w in ipairs(weights) do 
			table.insert(paired, {w=w/total, p=pool[i]}) 
		end
		table.sort(paired, function(a,b) return a.w > b.w end)
		
		pool, weights, total = {}, {}, 0
		local cumP = 0
		for _, item in ipairs(paired) do
			cumP += item.w
			table.insert(pool, item.p)
			table.insert(weights, item.w)
			total += item.w
			if cumP >= topP then break end
		end
	end
	
	-- Weighted random selection
	local r = math.random() * total
	local cumul = 0
	for i, w in ipairs(weights) do
		cumul += w
		if r <= cumul then return pool[i] end
	end
	
	return pool[#pool]
end

--- Generate text from seed
---@param seed string Starting text
---@param length number Number of tokens to generate
---@param mode table Generation mode settings
---@return string
function Markov:generate(seed, length, mode)
	length = length or 8
	local temp = (mode and mode.temperature) or 0.8
	local useBigram = mode and mode.bigramBoost
	local useTrigram = mode and mode.trigramBoost
	
	local tokens = Utils.tokenize(seed)
	if #tokens < 1 then return "..." end
	
	local t0 = tokens[#tokens-2]
	local t1 = tokens[#tokens-1]
	local current = tokens[#tokens]
	
	-- Find starting point if seed not in memory
	if not current or not self.unigram[current] then
		local keys = {}
		for k in pairs(self.unigram) do 
			table.insert(keys, k) 
		end
		if #keys == 0 then return "..." end
		current = keys[math.random(1, #keys)]
		t0, t1 = nil, nil
	end
	
	local topK = self.config.topKSampling or 40
	local topP = self.config.nucleusSampling or 0.9
	local result = {current}
	
	for _ = 1, length do
		local chosen = nil
		
		-- Try trigram first (most specific)
		if useTrigram and t1 and self.trigram[t1.."_"..current] then
			chosen = self:sample(self.trigram[t1.."_"..current], temp, topK, topP)
		end
		
		-- Fall back to bigram
		if not chosen and useBigram and t1 and self.bigram[t1.."_"..current] then
			chosen = self:sample(self.bigram[t1.."_"..current], temp, topK, topP)
		end
		
		-- Fall back to unigram
		if not chosen then 
			chosen = self:sample(self.unigram[current], temp, topK, topP) 
		end
		
		if not chosen then break end
		
		table.insert(result, chosen)
		t0 = t1
		t1 = current
		current = chosen
	end
	
	return table.concat(result, " ")
end

--- Score text coherence based on learned patterns
---@param text string
---@param mode table Mode settings
---@return number
function Markov:score(text, mode)
	local tokens = Utils.tokenize(text)
	if #tokens < 2 then return 0 end
	
	local score = 0
	local unique = {}
	for _, w in ipairs(tokens) do unique[w] = true end
	
	local div = 0
	for _ in pairs(unique) do div += 1 end
	
	local dw = (mode and mode.diversityWeight) or 0.4
	local cw = (mode and mode.coherenceWeight) or 1.2
	
	-- Diversity component
	score += (div / #tokens) * dw
	
	-- Coherence component (unigram transitions)
	for i = 1, #tokens-1 do
		local nexts = self.unigram[tokens[i]]
		if nexts and nexts[tokens[i+1]] then
			score += math.log(nexts[tokens[i+1]] + 1) * cw
		end
	end
	
	-- Bigram bonus
	if mode and mode.bigramBoost then
		for _, bg in ipairs(Utils.getBigrams(tokens)) do
			if self.bigram[bg] then score += 0.5 end
		end
	end
	
	-- Trigram bonus
	if mode and mode.trigramBoost then
		for _, tg in ipairs(Utils.getTrigrams(tokens)) do
			if self.trigram[tg] then score += 0.8 end
		end
	end
	
	return score
end

--- Count number of unique keys in unigram
---@return number
function Markov:keyCount()
	local n = 0
	for _ in pairs(self.unigram) do n += 1 end
	return n
end

return Markov
