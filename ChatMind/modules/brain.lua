-- brain.lua - Main Brain State Manager
-- Manages all AI components and coordinates learning/generation

local Models = require(script.Parent.models)
local Markov = require(script.Parent.markov)
local Bayes = require(script.Parent.bayes)
local Utils = require(script.Parent.utils)

local Brain = {}
Brain.__index = Brain

--- Create a new brain instance for a model
---@param modelKey string Key of the model to use
---@return Brain
function Brain.new(modelKey)
	local self = setmetatable({}, Brain)
	
	self.modelKey = modelKey or "flash"
	self.config = Models[self.modelKey]
	
	-- Initialize components
	self.markov = Markov.new(self.config)
	self.bayes = Bayes.new()
	
	-- Memory and context
	self.memory = {}
	self.contextTokens = 0
	self.totalInputTokens = 0
	self.totalOutputTokens = 0
	
	-- Sessions
	self.sessions = {}
	self.currentSessionId = nil
	
	-- Sentiment lexicon (simplified)
	self.sentiment = {
		pos = {"good", "great", "awesome", "love", "happy", "yes", "sure", "nice"},
		neg = {"bad", "hate", "sad", "angry", "no", "never", "terrible"}
	}
	
	-- Experts registry (Mixture of Experts)
	self.experts = {
		general = {keywords = {}, responses = {}},
		greeting = {keywords = {"hi", "hello", "hey", "sup", "yo"}, responses = {}},
		farewell = {keywords = {"bye", "goodbye", "see ya", "later"}, responses = {}},
		question = {keywords = {"what", "why", "how", "when", "where", "who"}, responses = {}},
		compliment = {keywords = {"cool", "awesome", "amazing", "great"}, responses = {}},
	}
	
	return self
end

--- Process and learn from input text
---@param text string
---@param intent? string
function Brain:learn(text, intent)
	intent = intent or "general"
	
	-- Learn with Markov chains
	self.markov:learn(text, self.config.learningRate)
	
	-- Learn with Bayes classifier
	self.bayes:learn(text, intent)
	
	-- Update token counts
	local tokens = Utils.countTokens(text)
	self.totalInputTokens += tokens
	self:updateContextTokens(tokens)
end

--- Generate response to input
---@param input string
---@param mode? table Generation mode
---@return string
function Brain:respond(input, mode)
	mode = mode or self.config.modes[self.config.defaultMode]
	
	-- Classify intent
	local intent, confidence = self.bayes:classify(input, self.config.bayesSmoothing)
	
	-- Route to appropriate expert
	local expertResponse = self:getExpertResponse(intent, input)
	if expertResponse then
		return expertResponse
	end
	
	-- Generate with Markov chain
	local candidate = self.markov:generate(input, self.config.maxTokens, mode)
	
	-- Quality checks
	if not self:isCoherent(candidate, mode) then
		candidate = self:getFallbackResponse()
	end
	
	-- Store in memory
	self:storeMemory(input, candidate, intent)
	
	-- Update token counts
	local tokens = Utils.countTokens(candidate)
	self.totalOutputTokens += tokens
	
	return candidate
end

--- Get response from expert system
---@param intent string
---@param input string
---@return string?
function Brain:getExpertResponse(intent, input)
	local expert = self.experts[intent]
	if not expert or #expert.keywords == 0 then return nil end
	
	-- Check if input matches expert keywords
	local inputLower = string.lower(input)
	for _, keyword in ipairs(expert.keywords) do
		if string.find(inputLower, keyword) then
			-- Return learned response or generate one
			if #expert.responses > 0 then
				return expert.responses[math.random(1, #expert.responses)]
			end
			break
		end
	end
	
	return nil
end

--- Check if text is coherent
---@param text string
---@param mode table
---@return boolean
function Brain:isCoherent(text, mode)
	if not text or #text < 3 then return false end
	
	local score = self.markov:score(text, mode)
	local threshold = self.config.coherenceThreshold or 0.4
	
	return score >= threshold
end

--- Store memory of conversation
---@param input string
---@param output string
---@param intent string
function Brain:storeMemory(input, output, intent)
	table.insert(self.memory, {
		input = input,
		output = output,
		intent = intent,
		timestamp = os.time()
	})
	
	-- Limit memory size
	while #self.memory > self.config.memorySlots do
		table.remove(self.memory, 1)
	end
end

--- Get context from memory
---@return string
function Brain:getContext()
	if #self.memory == 0 then return "" end
	
	local recent = self.memory[#self.memory]
	if recent then
		return "Previous: " .. recent.output
	end
	
	return ""
end

--- Update context token count
---@param tokens number
function Brain:updateContextTokens(tokens)
	self.contextTokens += tokens
	
	-- Trim if over limit
	if self.contextTokens > self.config.contextLimit then
		self:trimContext()
	end
end

--- Trim old memories to stay within context limit
function Brain:trimContext()
	while self.contextTokens > self.config.contextLimit and #self.memory > 0 do
		local oldest = table.remove(self.memory, 1)
		if oldest then
			self.contextTokens -= Utils.countTokens(oldest.input .. " " .. oldest.output)
		end
	end
end

--- Get fallback response when generation fails
---@return string
function Brain:getFallbackResponse()
	local fallbacks = {
		"That's interesting!",
		"I see what you mean.",
		"Tell me more about that.",
		"Hmm, let me think about that.",
		"Interesting point!",
	}
	return fallbacks[math.random(1, #fallbacks)]
end

--- Calculate sentiment score of text
---@param text string
---@return number
function Brain:sentimentScore(text)
	local textLower = string.lower(text)
	local score = 0
	
	for _, word in ipairs(self.sentiment.pos) do
		if string.find(textLower, word) then score += 1 end
	end
	
	for _, word in ipairs(self.sentiment.neg) do
		if string.find(textLower, word) then score -= 1 end
	end
	
	return score
end

--- Create a new chat session
---@return string Session ID
function Brain:newSession()
	local sessionId = "session_" .. os.time()
	self.currentSessionId = sessionId
	
	self.sessions[sessionId] = {
		id = sessionId,
		title = "New Chat",
		messages = {},
		createdAt = os.time()
	}
	
	return sessionId
end

--- Add message to current session
---@param text string
---@param role string "user" or "bot"
---@param intent? string
function Brain:addToSession(text, role, intent)
	if not self.currentSessionId then
		self:newSession()
	end
	
	local session = self.sessions[self.currentSessionId]
	if session then
		table.insert(session.messages, {
			role = role,
			text = text,
			intent = intent or "general",
			timestamp = os.time()
		})
		
		-- Auto-generate title from first message
		if #session.messages == 1 and role == "user" then
			session.title = string.sub(text, 1, 30) .. (#text > 30 and "..." or "")
		end
	end
end

--- Get current session
---@return table?
function Brain:getCurrentSession()
	if not self.currentSessionId then return nil end
	return self.sessions[self.currentSessionId]
end

--- Get effective parameters
---@return number
function Brain:getEffectiveParams()
	return self.effectiveParams or self.config.effectiveParams
end

--- Set effective parameters
---@param value number
function Brain:setEffectiveParams(value)
	self.effectiveParams = Utils.clamp(
		value, 
		self.config.effectiveParamsMin, 
		self.config.effectiveParamsMax
	)
end

--- Get learning rate
---@return number
function Brain:getLearningRate()
	return self.learningRate or self.config.learningRate
end

--- Set learning rate
---@param value number
function Brain:setLearningRate(value)
	self.learningRate = Utils.clamp(value, 0.01, 0.5)
end

return Brain
