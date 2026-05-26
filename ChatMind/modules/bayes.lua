-- bayes.lua - Naive Bayes Classifier
-- Handles text classification and intent detection

local Utils = require(script.Parent.utils)

local Bayes = {}
Bayes.__index = Bayes

--- Create a new Bayes classifier instance
---@return Bayes
function Bayes.new()
	local self = setmetatable({}, Bayes)
	self.classCounts = {}
	self.wordCounts = {}
	self.totalDocs = 0
	self.vocab = {}
	self.docFreq = {}  -- For TF-IDF
	return self
end

--- Learn from text with a class label
---@param text string
---@param class string Class/category label
---@param cap? number Token cap
function Bayes:learn(text, class, cap)
	local tokens = Utils.tokenize(text, cap, true)
	
	-- Update class counts
	self.classCounts[class] = (self.classCounts[class] or 0) + 1
	self.totalDocs += 1
	
	-- Initialize word counts for class if needed
	if not self.wordCounts[class] then 
		self.wordCounts[class] = {} 
	end
	
	-- Count words
	for _, w in ipairs(tokens) do
		self.wordCounts[class][w] = (self.wordCounts[class][w] or 0) + 1
		self.vocab[w] = true
	end
	
	-- Update document frequency for TF-IDF
	if not self.docFreq[class] then 
		self.docFreq[class] = {} 
	end
	for _, w in ipairs(tokens) do
		self.docFreq[class][w] = (self.docFreq[class][w] or 0) + 1
	end
end

--- Classify text into most likely class
---@param text string
---@param smoothing? number Laplace smoothing parameter
---@return string, number  -- class, confidence
function Bayes:classify(text, smoothing)
	local tokens = Utils.tokenize(text, nil, true)
	smoothing = smoothing or 1.0
	
	-- Calculate vocabulary size
	local vocabSize = 0
	for _ in pairs(self.vocab) do vocabSize += 1 end
	
	if vocabSize == 0 then return "general", 0 end
	
	local bestClass, bestScore = "general", -math.huge
	local scores = {}
	
	-- Calculate log probability for each class
	for class, count in pairs(self.classCounts) do
		local score = math.log(count / self.totalDocs)
		local wc = self.wordCounts[class] or {}
		
		-- Total word count in class
		local total = 0
		for _, c in pairs(wc) do total += c end
		
		-- Add word probabilities with smoothing
		for _, w in ipairs(tokens) do
			score += math.log(((wc[w] or 0) + smoothing) / (total + smoothing * vocabSize))
		end
		
		scores[class] = score
		if score > bestScore then 
			bestScore = score 
			bestClass = class 
		end
	end
	
	-- Convert to confidence using softmax-like normalization
	local expSum = 0
	for _, s in pairs(scores) do 
		expSum += math.exp(s - bestScore) 
	end
	
	return bestClass, 1 / expSum
end

--- Get TF-IDF score for word in class
---@param word string
---@param class string
---@return number
function Bayes:tfidf(word, class)
	if not self.docFreq[class] or not self.docFreq[class][word] then 
		return 0 
	end
	
	-- Term frequency
	local tf = self.docFreq[class][word]
	
	-- Inverse document frequency
	local docsWithWord = 0
	for _, freqs in pairs(self.docFreq) do
		if freqs[word] then docsWithWord += 1 end
	end
	
	local idf = math.log(self.totalDocs / (docsWithWord + 1)) + 1
	
	return tf * idf
end

--- Get similarity between text and class
---@param text string
---@param class string
---@return number
function Bayes:similarity(text, class)
	local tokens = Utils.tokenize(text, nil, true)
	if #tokens == 0 then return 0 end
	
	local totalScore = 0
	for _, w in ipairs(tokens) do
		totalScore += self:tfidf(w, class)
	end
	
	return totalScore / #tokens
end

--- Get vocabulary size
---@return number
function Bayes:vocabSize()
	local size = 0
	for _ in pairs(self.vocab) do size += 1 end
	return size
end

--- Clear all learned data
function Bayes:clear()
	self.classCounts = {}
	self.wordCounts = {}
	self.totalDocs = 0
	self.vocab = {}
	self.docFreq = {}
end

return Bayes
