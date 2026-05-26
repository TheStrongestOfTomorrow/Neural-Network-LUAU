-- ChatMind Client - Single File Version for Executors
-- A client-side only modular chat AI system for Roblox
-- Copy and paste this entire file into your executor

--------------------------------------------------------------------------------
-- MODEL CONFIGURATIONS
--------------------------------------------------------------------------------

local Models = {
    flash = {
        name = "Flash",
        description = "Fast, efficient responses for quick interactions",
        defaultMode = "markov",
        modes = {
            markov = { enabled = true, weight = 0.6 },
            bayes = { enabled = true, weight = 0.3 },
            patterns = { enabled = true, weight = 0.1 },
        },
        settings = {
            creativity = 0.7,
            coherence = 0.8,
            responseLength = "medium",
        }
    },
    deepthink = {
        name = "DeepThink",
        description = "Advanced reasoning with deeper analysis",
        defaultMode = "bayes",
        modes = {
            markov = { enabled = true, weight = 0.3 },
            bayes = { enabled = true, weight = 0.5 },
            patterns = { enabled = true, weight = 0.2 },
        },
        settings = {
            creativity = 0.5,
            coherence = 0.9,
            responseLength = "long",
        }
    },
    pro = {
        name = "Pro",
        description = "Balanced performance with MoE architecture",
        defaultMode = "moe",
        modes = {
            markov = { enabled = true, weight = 0.4 },
            bayes = { enabled = true, weight = 0.4 },
            patterns = { enabled = true, weight = 0.2 },
        },
        settings = {
            creativity = 0.6,
            coherence = 0.85,
            responseLength = "medium",
        }
    },
}

--------------------------------------------------------------------------------
-- UTILITY FUNCTIONS
--------------------------------------------------------------------------------

local Utils = {}

function Utils.split(text, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    for match in string.gmatch(text, pattern) do
        table.insert(result, match)
    end
    return result
end

function Utils.trim(text)
    return text:match("^%s*(.-)%s*$")
end

function Utils.choice(list)
    if #list == 0 then return nil end
    return list[math.random(1, #list)]
end

function Utils.isEmpty(str)
    return str == nil or str == "" or Utils.trim(str) == ""
end

function Utils.tokenize(text)
    if not text then return {} end
    text = string.lower(Utils.trim(text))
    text = text:gsub("[%p%c]", " ")
    local tokens = {}
    for token in text:gmatch("%S+") do
        table.insert(tokens, token)
    end
    return tokens
end

function Utils.extractKeywords(text, stopWords)
    stopWords = stopWords or {}
    local tokens = Utils.tokenize(text)
    local keywords = {}
    local seen = {}
    
    for _, token in ipairs(tokens) do
        if not stopWords[token] and not seen[token] then
            table.insert(keywords, token)
            seen[token] = true
        end
    end
    
    return keywords
end

function Utils.calculateSimilarity(text1, text2)
    local words1 = Utils.tokenize(text1)
    local words2 = Utils.tokenize(text2)
    
    if #words1 == 0 or #words2 == 0 then return 0 end
    
    local wordSet = {}
    for _, word in ipairs(words1) do wordSet[word] = (wordSet[word] or 0) + 1 end
    for _, word in ipairs(words2) do wordSet[word] = (wordSet[word] or 0) + 1 end
    
    local intersection = 0
    for word, count in pairs(wordSet) do
        if count > 1 then
            intersection = intersection + math.min(count - 1, 1)
        end
    end
    
    return intersection / (#words1 + #words2 - intersection)
end

return Utils
