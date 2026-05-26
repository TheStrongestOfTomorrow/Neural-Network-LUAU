-- utils.lua - Utility Functions
-- Common utility functions for tokenization, math operations, and helpers

local Utils = {}

local t_insert = table.insert
local s_lower = string.lower
local s_gsub = string.gsub
local s_gmatch = string.gmatch
local m_ceil = math.ceil
local m_max = math.max
local m_log = math.log
local m_exp = math.exp
local m_huge = math.huge
local m_clamp = math.clamp
local m_floor = math.floor
local m_random = math.random
local m_min = math.min
local t_concat = table.concat

-- Stop words for filtering common words
Utils.StopWords = {
	["the"]=true, ["a"]=true, ["an"]=true, ["is"]=true, ["it"]=true,
	["in"]=true, ["on"]=true, ["at"]=true, ["to"]=true, ["of"]=true,
	["and"]=true, ["or"]=true, ["but"]=true, ["so"]=true, ["for"]=true,
}

--- Count approximate tokens in text
---@param text string
---@return number
function Utils.countTokens(text)
	if not text or #text == 0 then return 0 end
	local n = 0
	for _ in text:gmatch("%S+") do n += 1 end
	return m_ceil(n * 1.3)
end

--- Tokenize text into words
---@param text string
---@param cap? number Maximum number of tokens
---@param removeStop? boolean Whether to remove stop words
---@return string[]
function Utils.tokenize(text, cap, removeStop)
	local tokens = {}
	local cleaned = s_lower(s_gsub(text, "[%p%c]", ""))
	local count = 0
	for w in s_gmatch(cleaned, "%S+") do
		if not removeStop or not Utils.StopWords[w] then
			t_insert(tokens, w)
			count += 1
			if cap and count >= cap then break end
		end
	end
	return tokens
end

--- Extract bigrams from token list
---@param tokens string[]
---@return string[]
function Utils.getBigrams(tokens)
	local bg = {}
	for i = 1, #tokens-1 do 
		t_insert(bg, tokens[i].."_"..tokens[i+1]) 
	end
	return bg
end

--- Extract trigrams from token list
---@param tokens string[]
---@return string[]
function Utils.getTrigrams(tokens)
	local tg = {}
	for i = 1, #tokens-2 do 
		t_insert(tg, tokens[i].."_"..tokens[i+1].."_"..tokens[i+2]) 
	end
	return tg
end

--- Clamp a value between min and max
---@param val number
---@param minVal number
---@param maxVal number
---@return number
function Utils.clamp(val, minVal, maxVal)
	return m_max(minVal, m_min(maxVal, val))
end

--- Linear interpolation
---@param a number
---@param b number
---@param t number
---@return number
function Utils.lerp(a, b, t)
	return a + (b - a) * t
end

--- Safe JSON encode
---@param data any
---@return string?, boolean
function Utils.safeJSONEncode(data)
	local HttpService = game:GetService("HttpService")
	local ok, result = pcall(HttpService.JSONEncode, HttpService, data)
	if ok then return result, true end
	return nil, false
end

--- Safe JSON decode
---@param str string
---@return any?, boolean
function Utils.safeJSONDecode(str)
	local HttpService = game:GetService("HttpService")
	local ok, result = pcall(HttpService.JSONDecode, HttpService, str)
	if ok then return result, true end
	return nil, false
end

return Utils
