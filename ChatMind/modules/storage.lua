-- storage.lua - Data Persistence Module
-- Handles saving and loading data to/from files

local Utils = require(script.Parent.utils)

local Storage = {}
Storage.__index = Storage

--- Create a new storage manager
---@return Storage
function Storage.new()
	local self = setmetatable({}, Storage)
	self.savePath = "ChatMindData/"
	return self
end

--- Check if file exists
---@param path string
---@return boolean
function Storage:fileExists(path)
	if not isfile then return false end
	return isfile(path)
end

--- Read file content
---@param path string
---@return string?
function Storage:readFile(path)
	if not self:fileExists(path) then return nil end
	
	local file, err = readfile(path)
	if not file then 
		warn("Failed to read file:", err)
		return nil 
	end
	
	return file
end

--- Write content to file
---@param path string
---@param content string
---@return boolean
function Storage:writeFile(path, content)
	if not writefile then 
		warn("writefile not available")
		return false 
	end
	
	local ok, err = pcall(writefile, path, content)
	if not ok then 
		warn("Failed to write file:", err)
		return false 
	end
	
	return true
end

--- Ensure directory exists (create if needed)
---@param path string
function Storage:ensureDirectory(path)
	-- Roblox doesn't have mkdir, but we can try to write a dummy file
	if not writefile then return end
	
	-- Try to write to the path - if it fails due to missing dir, create it
	local ok = pcall(writefile, path .. ".dir", "")
	if not ok then
		-- Directory creation might not be supported in all environments
		warn("Could not ensure directory:", path)
	end
end

--- Save brain data to file
---@param brain table Brain instance
---@param modelKey string
---@return boolean
function Storage:saveBrain(brain, modelKey)
	if not writefile then return false end
	
	local Models = require(script.Parent.models)
	local config = Models[modelKey]
	
	local data = {
		version = 2,
		modelKey = modelKey,
		markov = {
			unigram = brain.markov.unigram,
			bigram = brain.markov.bigram,
			trigram = brain.markov.trigram,
		},
		bayes = {
			classCounts = brain.bayes.classCounts,
			wordCounts = brain.bayes.wordCounts,
			totalDocs = brain.bayes.totalDocs,
			vocab = brain.bayes.vocab,
		},
		sessions = brain.sessions,
		currentSessionId = brain.currentSessionId,
		effectiveParams = brain.effectiveParams,
		learningRate = brain.learningRate,
		stats = {
			totalInputTokens = brain.totalInputTokens,
			totalOutputTokens = brain.totalOutputTokens,
		}
	}
	
	local ok, json = Utils.safeJSONEncode(data)
	if not ok then 
		warn("Failed to encode brain data")
		return false 
	end
	
	local path = self.savePath .. config.saveFile
	return self:writeFile(path, json)
end

--- Load brain data from file
---@param modelKey string
---@return table?
function Storage:loadBrain(modelKey)
	local Models = require(script.Parent.models)
	local config = Models[modelKey]
	
	local path = self.savePath .. config.saveFile
	local content = self:readFile(path)
	
	if not content then return nil end
	
	local ok, data = Utils.safeJSONDecode(content)
	if not ok or not data then return nil end
	
	return data
end

--- Compress session for storage
---@param session table
---@param modelKey string
---@return string?
function Storage:compressSession(session, modelKey)
	local data = { 
		v = 2, 
		m = modelKey, 
		t = session.title, 
		msgs = {} 
	}
	
	for _, msg in ipairs(session.messages) do
		table.insert(data.msgs, { 
			r = msg.role == "bot" and "b" or "u", 
			t = msg.text 
		})
	end
	
	local ok, str = Utils.safeJSONEncode(data)
	if ok then return str end
	return nil
end

--- Decompress session from storage
---@param compressed string
---@return table?
function Storage:decompressSession(compressed)
	local ok, data = Utils.safeJSONDecode(compressed)
	if not ok or not data then return nil end
	
	local session = {
		id = "imported_" .. os.time(),
		title = data.t or "Imported Chat",
		messages = {},
		createdAt = os.time()
	}
	
	for _, msg in ipairs(data.msgs or {}) do
		table.insert(session.messages, {
			role = msg.r == "b" and "bot" or "user",
			text = msg.t or "",
			timestamp = os.time()
		})
	end
	
	return session
end

--- Clear all saved data
---@param modelKey string
function Storage:clearData(modelKey)
	local Models = require(script.Parent.models)
	local config = Models[modelKey]
	
	local path = self.savePath .. config.saveFile
	-- We can't delete files in Roblox, but we can overwrite with empty data
	self:writeFile(path, "{}")
end

--- Export session to text format
---@param session table
---@return string
function Storage:exportToText(session)
	local lines = {}
	table.insert(lines, "Chat: " .. session.title)
	table.insert(lines, "=" .. string.rep("=", #session.title + 6))
	table.insert(lines, "")
	
	for _, msg in ipairs(session.messages) do
		local prefix = msg.role == "bot" and "Bot" or "You"
		table.insert(lines, prefix .. ": " .. msg.text)
	end
	
	return table.concat(lines, "\n")
end

return Storage
