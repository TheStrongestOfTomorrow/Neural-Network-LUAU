local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local m_random = math.random
local m_log = math.log
local m_exp = math.exp
local m_huge = math.huge
local m_clamp = math.clamp
local m_floor = math.floor
local m_ceil = math.ceil
local m_max = math.max
local m_min = math.min
local s_lower = string.lower
local s_gsub = string.gsub
local s_gmatch = string.gmatch
local s_format = string.format
local s_sub = string.sub
local t_insert = table.insert
local t_remove = table.remove
local t_concat = table.concat
local t_sort = table.sort

--------------------------------------------------------------------------------
-- [[ MODEL REGISTRY ]]
--------------------------------------------------------------------------------

local Models = {
	flash = {
		name = "ChatMind 1 Flash",
		tag = "FLASH",
		saveFile = "cm1flash.json",
		maxTokens = 20,
		markovOrder = 1,
		bayesSmoothing = 1.0,
		maxLog = 500,
		maxChatSessions = 20,
		color = Color3.fromRGB(255, 200, 40),
		confidenceThreshold = 0.35,
		coherenceThreshold = 0.40,
		perplexityLimit = 8.0,
		minMarkovKeys = 15,
		fallbackToPool = true,
		contextLimit = 8192,
		effectiveParams = 32768,
		effectiveParamsMin = 4096,
		effectiveParamsMax = 131072,
		memorySlots = 8,
		learningRate = 0.05,
		topKSampling = 40,
		nucleusSampling = 0.9,
		modes = {
			spark = {
				label = "Spark", icon = "⚡",
				color = Color3.fromRGB(255, 210, 50),
				candidates = 1, delayMin = 0.05, delayMax = 0.10,
				tokenCap = 10, rescore = false, rescorePasses = 0,
				diversityWeight = 0.2, coherenceWeight = 0.8,
				temperature = 0.9, repetitionPenalty = 0.3,
			},
			sparking_thinking = {
				label = "Sparking Thinking", icon = "⚡🧠",
				color = Color3.fromRGB(160, 80, 255),
				candidates = 5, delayMin = 0.25, delayMax = 0.45,
				tokenCap = 20, rescore = true, rescorePasses = 1,
				diversityWeight = 0.4, coherenceWeight = 1.2,
				temperature = 0.75, repetitionPenalty = 0.5,
			},
			think = {
				label = "Think", icon = "🧠",
				color = Color3.fromRGB(80, 160, 255),
				candidates = 8, delayMin = 1.1, delayMax = 1.7,
				tokenCap = 999, rescore = true, rescorePasses = 3,
				diversityWeight = 0.6, coherenceWeight = 1.8,
				temperature = 0.6, repetitionPenalty = 0.7,
			},
		},
		defaultMode = "sparking_thinking",
	},

	deepthink = {
		name = "ChatMind 1 DeepThink",
		tag = "DEEP",
		saveFile = "cm1deepthink.json",
		maxTokens = 999,
		markovOrder = 2,
		bayesSmoothing = 0.3,
		maxLog = 2000,
		maxChatSessions = 20,
		color = Color3.fromRGB(100, 80, 255),
		confidenceThreshold = 0.25,
		coherenceThreshold = 0.55,
		perplexityLimit = 6.0,
		minMarkovKeys = 30,
		fallbackToPool = true,
		contextLimit = 32768,
		effectiveParams = 131072,
		effectiveParamsMin = 16384,
		effectiveParamsMax = 524288,
		memorySlots = 20,
		learningRate = 0.03,
		topKSampling = 60,
		nucleusSampling = 0.95,
		modes = {
			deepthink = {
				label = "DeepThink", icon = "🔮",
				color = Color3.fromRGB(130, 90, 255),
				candidates = 12, delayMin = 2.0, delayMax = 3.5,
				tokenCap = 999, rescore = true, rescorePasses = 5,
				diversityWeight = 1.0, coherenceWeight = 2.5,
				useAllExperts = true, bigramBoost = true, trigramBoost = true,
				sentimentCheck = true, temperature = 0.5, repetitionPenalty = 0.9,
			},
			extended_dt = {
				label = "Extended DT", icon = "🔮✨",
				color = Color3.fromRGB(180, 100, 255),
				candidates = 15, delayMin = 4.0, delayMax = 6.0,
				tokenCap = 999, rescore = true, rescorePasses = 8,
				diversityWeight = 1.2, coherenceWeight = 3.0,
				useAllExperts = true, bigramBoost = true, trigramBoost = true,
				sentimentCheck = true, temperature = 0.4, repetitionPenalty = 1.0,
			},
		},
		defaultMode = "deepthink",
	},

	pro = {
		name = "ChatMind 1 Pro",
		tag = "PRO",
		saveFile = "cm1pro.json",
		maxTokens = 999,
		markovOrder = 2,
		bayesSmoothing = 0.5,
		maxLog = 3000,
		maxChatSessions = 20,
		color = Color3.fromRGB(50, 200, 255),
		confidenceThreshold = 0.30,
		coherenceThreshold = 0.50,
		perplexityLimit = 7.0,
		minMarkovKeys = 20,
		fallbackToPool = true,
		contextLimit = 65536,
		effectiveParams = 262144,
		effectiveParamsMin = 32768,
		effectiveParamsMax = 1048576,
		memorySlots = 30,
		learningRate = 0.04,
		topKSampling = 80,
		nucleusSampling = 0.97,
		webEnabled = false,
		modes = {
			lightning = {
				label = "Lightning Fusion", icon = "⚡💎",
				color = Color3.fromRGB(50, 210, 255),
				candidates = 8, delayMin = 0.1, delayMax = 0.3,
				tokenCap = 30, rescore = true, rescorePasses = 2,
				diversityWeight = 0.5, coherenceWeight = 1.5,
				bigramBoost = true, trigramBoost = true,
				temperature = 0.7, repetitionPenalty = 0.6,
				fusionMode = true,
			},
			thinking = {
				label = "Thinking", icon = "💎🧠",
				color = Color3.fromRGB(30, 170, 255),
				candidates = 12, delayMin = 1.5, delayMax = 2.5,
				tokenCap = 999, rescore = true, rescorePasses = 4,
				diversityWeight = 0.8, coherenceWeight = 2.0,
				bigramBoost = true, trigramBoost = true,
				useAllExperts = true, sentimentCheck = true,
				temperature = 0.55, repetitionPenalty = 0.8,
				fusionMode = true, useWeb = true,
			},
			extended = {
				label = "Extended Thinking", icon = "💎🔮",
				color = Color3.fromRGB(20, 140, 255),
				candidates = 18, delayMin = 3.5, delayMax = 5.0,
				tokenCap = 999, rescore = true, rescorePasses = 7,
				diversityWeight = 1.0, coherenceWeight = 2.8,
				bigramBoost = true, trigramBoost = true,
				useAllExperts = true, sentimentCheck = true,
				temperature = 0.45, repetitionPenalty = 0.95,
				fusionMode = true, useWeb = true,
			},
		},
		defaultMode = "lightning",
	},
}

local ActiveModelKey = "flash"
local ActiveModel = Models[ActiveModelKey]
local ActiveModeKey = ActiveModel.defaultMode
local ActiveMode = ActiveModel.modes[ActiveModeKey]

local GlobalSettings = {
	systemPrompt = "",
	language = "english",
	alertKeywords = {},
	webEnabled = false,
	sidebarOpen = true,
}

--------------------------------------------------------------------------------
-- [[ BRAIN STATE ]]
--------------------------------------------------------------------------------

local Brains = {}
for key in pairs(Models) do
	Brains[key] = {
		Markov = {}, Bigram = {}, Trigram = {},
		Bayes = { classCounts = {}, wordCounts = {}, totalDocs = 0, vocab = {} },
		TFIDF = { docFreq = {}, totalDocs = 0 },
		Sentiment = { pos = {}, neg = {} },
		Memory = {},
		ContextTokens = 0,
		TotalInputTokens = 0,
		TotalOutputTokens = 0,
		LastOutputTokens = 0,
		ChatLog = {},
		Sessions = {},
		CurrentSessionId = nil,
		Active = true,
		EffectiveParams = nil,
		LearningRate = nil,
	}
end

local function Brain() return Brains[ActiveModelKey] end

--------------------------------------------------------------------------------
-- [[ UTILITY ]]
--------------------------------------------------------------------------------

local function countTokens(text)
	if not text or #text == 0 then return 0 end
	local n = 0
	for _ in text:gmatch("%S+") do n += 1 end
	return m_ceil(n * 1.3)
end

local function getEP(mk) mk = mk or ActiveModelKey return Brains[mk].EffectiveParams or Models[mk].effectiveParams end
local function getLR(mk) mk = mk or ActiveModelKey return Brains[mk].LearningRate or Models[mk].learningRate end

local function getMarkovKeyCap(mk)
	mk = mk or ActiveModelKey
	local ratio = getEP(mk) / Models[mk].effectiveParamsMax
	local total = 0
	for _ in pairs(Brains[mk].Markov) do total += 1 end
	return m_max(50, m_ceil(total * ratio))
end

local function compressSession(session, modelKey)
	local data = { v=2, m=modelKey, t=session.title, msgs={} }
	for _, msg in ipairs(session.messages) do
		t_insert(data.msgs, { r=msg.role=="bot" and "b" or "u", t=msg.text })
	end
	local ok, str = pcall(HttpService.JSONEncode, HttpService, data)
	return ok and str or nil
end

local function compressSessionText(session)
	local lines = {}
	for _, msg in ipairs(session.messages) do
		local prefix = msg.role == "bot" and "Bot" or "You"
		t_insert(lines, prefix .. ": " .. msg.text)
	end
	return t_concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- [[ TOKENIZER ]]
--------------------------------------------------------------------------------

local StopWords = {
	["the"]=true,["a"]=true,["an"]=true,["is"]=true,["it"]=true,
	["in"]=true,["on"]=true,["at"]=true,["to"]=true,["of"]=true,
	["and"]=true,["or"]=true,["but"]=true,["so"]=true,["for"]=true,
}

local function tokenize(text, cap, removeStop)
	local tokens = {}
	local cleaned = s_lower(s_gsub(text, "[%p%c]", ""))
	local count = 0
	for w in s_gmatch(cleaned, "%S+") do
		if not removeStop or not StopWords[w] then
			t_insert(tokens, w)
			count += 1
			if cap and count >= cap then break end
		end
	end
	return tokens
end

local function getBigrams(tokens)
	local bg = {}
	for i = 1, #tokens-1 do t_insert(bg, tokens[i].."_"..tokens[i+1]) end
	return bg
end

local function getTrigrams(tokens)
	local tg = {}
	for i = 1, #tokens-2 do t_insert(tg, tokens[i].."_"..tokens[i+1].."_"..tokens[i+2]) end
	return tg
end

--------------------------------------------------------------------------------
-- [[ MARKOV ENGINE — unigram + bigram + trigram ]]
--------------------------------------------------------------------------------

local function markovLearn(text, mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local tokens = tokenize(text)
	if #tokens < 2 then return end
	local lr = getLR(mk)
	local inc = m_max(1, m_ceil(lr * 20))
	for i = 1, #tokens-1 do
		local k = tokens[i]
		if not B.Markov[k] then B.Markov[k] = {} end
		B.Markov[k][tokens[i+1]] = (B.Markov[k][tokens[i+1]] or 0) + inc
	end
	if Models[mk].markovOrder >= 2 then
		for i = 1, #tokens-2 do
			local k = tokens[i].."_"..tokens[i+1]
			if not B.Bigram[k] then B.Bigram[k] = {} end
			B.Bigram[k][tokens[i+2]] = (B.Bigram[k][tokens[i+2]] or 0) + inc
		end
	end
	if Models[mk].markovOrder >= 2 and #tokens >= 4 then
		for i = 1, #tokens-3 do
			local k = tokens[i].."_"..tokens[i+1].."_"..tokens[i+2]
			if not B.Trigram[k] then B.Trigram[k] = {} end
			B.Trigram[k][tokens[i+3]] = (B.Trigram[k][tokens[i+3]] or 0) + inc
		end
	end
end

local function markovSample(nexts, temp, topK, topP)
	if not nexts then return nil end
	temp = temp or 1.0
	local pool, weights, total = {}, {}, 0
	for word, count in pairs(nexts) do
		local w = count ^ (1/temp)
		t_insert(pool, word) t_insert(weights, w) total += w
	end
	if total == 0 then return nil end
	if topK and topK > 0 and #pool > topK then
		local paired = {}
		for i, w in ipairs(weights) do t_insert(paired, {w=w, p=pool[i]}) end
		t_sort(paired, function(a,b) return a.w > b.w end)
		pool, weights, total = {}, {}, 0
		for i = 1, m_min(topK, #paired) do
			t_insert(pool, paired[i].p) t_insert(weights, paired[i].w) total += paired[i].w
		end
	end
	if topP and topP < 1.0 and #pool > 1 then
		local paired = {}
		for i, w in ipairs(weights) do t_insert(paired, {w=w/total, p=pool[i]}) end
		t_sort(paired, function(a,b) return a.w > b.w end)
		pool, weights, total = {}, {}, 0
		local cumP = 0
		for _, item in ipairs(paired) do
			cumP += item.w
			t_insert(pool, item.p) t_insert(weights, item.w) total += item.w
			if cumP >= topP then break end
		end
	end
	local r = m_random() * total
	local cumul = 0
	for i, w in ipairs(weights) do
		cumul += w
		if r <= cumul then return pool[i] end
	end
	return pool[#pool]
end

local function countMarkovKeys(mk)
	mk = mk or ActiveModelKey
	local n = 0
	for _ in pairs(Brains[mk].Markov) do n += 1 end
	return n
end

local function markovGenerate(seed, length, mode, mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	length = length or 8
	local temp = (mode and mode.temperature) or 0.8
	local useBigram = mode and mode.bigramBoost
	local useTrigram = mode and mode.trigramBoost
	local tokens = tokenize(seed)
	local t0 = tokens[#tokens-2]
	local t1 = tokens[#tokens-1]
	local current = tokens[#tokens]
	if not current or not B.Markov[current] then
		local keys = {}
		for k in pairs(B.Markov) do t_insert(keys, k) end
		if #keys == 0 then return "..." end
		current = keys[m_random(1, #keys)]
		t0, t1 = nil, nil
	end
	local mdl = Models[mk]
	local topK = mdl.topKSampling or 40
	local topP = mdl.nucleusSampling or 0.9
	local result = {current}
	for _ = 1, length do
		local chosen = nil
		if useTrigram and t1 and B.Trigram[t1.."_"..current] then
			chosen = markovSample(B.Trigram[t1.."_"..current], temp, topK, topP)
		end
		if not chosen and useBigram and t1 and B.Bigram[t1.."_"..current] then
			chosen = markovSample(B.Bigram[t1.."_"..current], temp, topK, topP)
		end
		if not chosen then chosen = markovSample(B.Markov[current], temp, topK, topP) end
		if not chosen then break end
		t_insert(result, chosen)
		t0 = t1 t1 = current current = chosen
	end
	return t_concat(result, " ")
end

local function markovScore(text, mode, mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local tokens = tokenize(text)
	if #tokens < 2 then return 0 end
	local score = 0
	local unique = {}
	for _, w in ipairs(tokens) do unique[w] = true end
	local div = 0
	for _ in pairs(unique) do div += 1 end
	local dw = (mode and mode.diversityWeight) or 0.4
	local cw = (mode and mode.coherenceWeight) or 1.2
	score += (div / #tokens) * dw
	for i = 1, #tokens-1 do
		local nexts = B.Markov[tokens[i]]
		if nexts and nexts[tokens[i+1]] then
			score += m_log(nexts[tokens[i+1]] + 1) * cw
		end
	end
	if mode and mode.bigramBoost then
		for _, bg in ipairs(getBigrams(tokens)) do
			if B.Bigram[bg] then score += 0.5 end
		end
	end
	if mode and mode.trigramBoost then
		for _, tg in ipairs(getTrigrams(tokens)) do
			if B.Trigram[tg] then score += 0.8 end
		end
	end
	return score
end

--------------------------------------------------------------------------------
-- [[ BAYES ENGINE ]]
--------------------------------------------------------------------------------

local function bayesLearn(text, class, cap, mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local tokens = tokenize(text, cap, true)
	B.Bayes.classCounts[class] = (B.Bayes.classCounts[class] or 0) + 1
	B.Bayes.totalDocs += 1
	if not B.Bayes.wordCounts[class] then B.Bayes.wordCounts[class] = {} end
	for _, w in ipairs(tokens) do
		B.Bayes.wordCounts[class][w] = (B.Bayes.wordCounts[class][w] or 0) + 1
		B.Bayes.vocab[w] = true
	end
	B.TFIDF.docFreq[class] = B.TFIDF.docFreq[class] or {}
	for _, w in ipairs(tokens) do
		B.TFIDF.docFreq[class][w] = (B.TFIDF.docFreq[class][w] or 0) + 1
	end
	B.TFIDF.totalDocs += 1
end

local function bayesClassify(text, cap, mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local smooth = Models[mk].bayesSmoothing
	local tokens = tokenize(text, cap, true)
	local vocabSize = 0
	for _ in pairs(B.Bayes.vocab) do vocabSize += 1 end
	if vocabSize == 0 then return "general", 0 end
	local bestClass, bestScore = "general", -m_huge
	local scores = {}
	for class, count in pairs(B.Bayes.classCounts) do
		local score = m_log(count / B.Bayes.totalDocs)
		local wc = B.Bayes.wordCounts[class] or {}
		local total = 0
		for _, c in pairs(wc) do total += c end
		for _, w in ipairs(tokens) do
			score += m_log(((wc[w] or 0) + smooth) / (total + smooth * vocabSize))
		end
		scores[class] = score
		if score > bestScore then bestScore = score bestClass = class end
	end
	local expSum = 0
	for _, s in pairs(scores) do expSum += m_exp(s - bestScore) end
	return bestClass, 1 / expSum
end

--------------------------------------------------------------------------------
-- [[ TFIDF ]]
--------------------------------------------------------------------------------

local function tfidfScore(text, class, mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local tokens = tokenize(text, nil, true)
	if #tokens == 0 then return 0 end
	local score = 0
	local tf = {}
	for _, w in ipairs(tokens) do tf[w] = (tf[w] or 0) + 1 end
	local numClasses = 0
	for _ in pairs(B.TFIDF.docFreq) do numClasses += 1 end
	local classFreq = B.TFIDF.docFreq[class] or {}
	for w, count in pairs(tf) do
		local tfVal = count / #tokens
		local df = classFreq[w] or 0
		local idf = df > 0 and m_log((numClasses + 1) / df) or 0
		score += tfVal * idf
	end
	return score
end

--------------------------------------------------------------------------------
-- [[ SENTIMENT ]]
--------------------------------------------------------------------------------

local PosWords = {"good","great","nice","love","awesome","cool","happy","best","win","fun","yes","agree","thanks","ty","lol","haha","gg","based","real","facts","fire"}
local NegWords = {"bad","hate","trash","noob","ez","loser","rekt","toxic","quit","leave","ugly","wrong","no","stop","stfu","kys","bruh","ratio","cry","cope"}

local function seedSentiment(mk)
	local B = Brains[mk]
	for _, w in ipairs(PosWords) do B.Sentiment.pos[w] = 1 end
	for _, w in ipairs(NegWords) do B.Sentiment.neg[w] = 1 end
end

local function sentimentScore(text, mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local tokens = tokenize(text)
	local score = 0
	for _, w in ipairs(tokens) do
		if B.Sentiment.pos[w] then score += 1 end
		if B.Sentiment.neg[w] then score -= 1 end
	end
	return score
end

--------------------------------------------------------------------------------
-- [[ EXPERTS (MoE) ]]
--------------------------------------------------------------------------------

local Experts = {
	casual = {
		classes = {"greeting","farewell","reaction","praise"},
		weight = 1.0,
		replies = {
			greeting = {
				"hey!","yo whats good","wassup","hi","heyyy","sup","ayo","what's good",
				"heyy","oh hey","waddup","yo","eyy","what's up","hii","ey yo",
				"hey hey","yooo","sup sup","heyo","wsg","wyd","what's popping",
			},
			farewell = {
				"bye!","cya","peace out","later","take care","✌️","see ya",
				"peace","laters","bye bye","catch u later","ima head out","aight later",
				"take it easy","gone","dip","ok bye","smell ya later","adios","out",
			},
			reaction = {
				"lmaooo","bruh","fr fr","no wayyyy","actual facts","deadass","💀","based",
				"LMAO","bro what","nahhh","no way","on god","real","bro cmon",
				"💀💀","istg","omg","bro","nah fr","thats wild","that's crazy",
				"wdym","huh","wait what","no cap","lowkey","highkey","ngl","ight",
			},
			praise = {
				"thanks!","appreciate it","ty ty","🙏","ngl that means a lot","means a lot",
				"aw thanks","that's so nice","you're the best","thank youuu","ty sm",
				"omg stop","aww","that made my day","seriously ty","means everything",
			},
		}
	},
	transactional = {
		classes = {"trade","invite"},
		weight = 1.0,
		replies = {
			trade = {
				"nah im good","what u offering","not trading rn","maybe later","send offer","depends what u got",
				"what do u want for it","nah not interested","maybe","ill think about it",
				"what's ur offer","lmk what u got","not rn","pass","hard pass","ight send offer",
				"depends","what r u looking for","hmm maybe","only if the price is right",
			},
			invite = {
				"maybe later","im busy rn","send the link","nah im good","sure why not","after this",
				"what game","sure","ight bet","one sec","give me a min","in a bit",
				"what server","sounds fun","maybe after this round","ight bet send it",
			},
		}
	},
	support = {
		classes = {"help"},
		weight = 0.8,
		replies = {
			help = {
				"try checking the game desc","idk try googling it","no idea tbh","ask someone else lol","have u tried rejoining","not sure tbh",
				"have u tried leaving and rejoining","check the wiki maybe","ask in chat","not really sure",
				"honestly idk","maybe check yt for a tutorial","it depends on the game",
				"have u tried resetting","i think u gotta go to settings","check the game page",
				"tbh not sure","u could try asking the game devs","maybe someone else knows",
			},
		}
	},
	hostile = {
		classes = {"toxic"},
		weight = 1.2,
		replies = {
			toxic = {
				"chill lol","ok and?","ur funny","whatever man","💀","skill issue","ratio","L + ratio","cry about it",
				"bro is mad","ok bozo","L","W for me","cry harder","imagine","touch grass",
				"stay mad","not my problem","ok cry","ur actually cooked","oof","rip",
				"thats an L","take the L","😭","🤡","clown behavior","get good","git gud",
			},
		}
	},
	general = {
		classes = {"general"},
		weight = 0.5,
		replies = {
			general = {
				"interesting","ok","makes sense","idk","fr","yeah","nah","maybe","say less","bet",
				"true","word","facts","ight","sure","not really","kinda","lowkey yeah",
				"i mean yeah","honestly","depends","could be","maybe not","possibly",
				"not sure","probably","doubt it","seems right","makes sense i guess",
			},
		}
	},
	roblox = {
		classes = {"roblox","game","gaming"},
		weight = 1.1,
		replies = {
			roblox = {
				"which game tho","what server u on","robux or no robux lol","what's ur username",
				"roblox is actually goated ngl","have u tried that game yet","what gamemode",
				"adopt me or blox fruits type beat","the lag is real","bro the ping tho",
				"which update tho","fr the devs cooked","nah the old version was better",
				"have u seen the new map","the grind is real","what level r u",
				"how long u been playing","u in a party","bro got carried lol",
			},
			game = {
				"what game","which one","is it good","how long u been playing",
				"hard or easy","solo or multiplayer","whats ur fav part",
				"u grinding or just vibing","what's ur rank","u good at it",
			},
			gaming = {
				"gaming is life fr","what platform","pc or console","fps or fps drops lol",
				"skill issue or bad game","what genre","u play competitively",
				"whats ur setup like","the grind never stops","gaming over everything",
			},
		}
	},
	knowledge = {
		classes = {"question","fact","info","learn"},
		weight = 0.9,
		replies = {
			question = {
				"good question tbh","i mean it depends","could be a lot of reasons",
				"thats actually interesting","i think its because","from what i know",
				"not 100% sure but","the short answer is","its complicated tbh",
				"honestly varies","i think so yeah","probably not tbh","it's a mix of both",
			},
			fact = {
				"thats actually true","no way that's real","wild right","facts",
				"i heard that too","makes sense when u think about it","thats crazy",
				"for real tho","actually lowkey interesting","never thought about that",
			},
			info = {
				"ok so basically","the thing is","from what i know","so the deal is",
				"basically what happens is","it's actually pretty simple","so here's the thing",
			},
			learn = {
				"thats a good thing to learn","knowledge is power fr","smart move",
				"yeah that's useful to know","good to know honestly","facts stay learning",
			},
		}
	},
	vibe = {
		classes = {"mood","feeling","emotion"},
		weight = 0.9,
		replies = {
			mood = {
				"same honestly","vibes","the mood","that's a whole mood","felt",
				"we don't talk about that","relatable","too real","the energy is off today",
				"i understand that feeling","big mood","lowkey same","we move",
			},
			feeling = {
				"that's valid","ur feelings are valid","i get that","makes sense tho",
				"aw that sucks","that's rough","glad ur ok","chin up","we move tho",
				"take ur time","no rush","breathe","it be like that sometimes",
			},
			emotion = {
				"emotions are complicated fr","valid","that's real","i hear u",
				"that's a lot to deal with","u good?","we're here","it gets better",
			},
		}
	},
}

local function routeExpert(intent)
	for name, expert in pairs(Experts) do
		for _, class in ipairs(expert.classes) do
			if class == intent then return name, expert end
		end
	end
	if intent == "fact" or intent == "info" or intent == "learn" then
		return "knowledge", Experts.knowledge
	end
	if intent == "roblox" or intent == "gaming" or intent == "game" then
		return "roblox", Experts.roblox
	end
	if intent == "mood" or intent == "feeling" or intent == "emotion" then
		return "vibe", Experts.vibe
	end
	return "general", Experts.general
end

local function getReply(intent, expertData)
	local pool = expertData.replies[intent] or expertData.replies[expertData.classes[1]]
	if pool and #pool > 0 then return pool[m_random(1, #pool)] end
	return nil
end

--------------------------------------------------------------------------------
-- [[ SEED DATA ]]
--------------------------------------------------------------------------------

local SeedData = {
	{t="hello hey hi sup yo whats up ayo wassup what's good wsg wyd", c="greeting"},
	{t="bye goodbye cya later peace leaving dip out see ya ima head out", c="farewell"},
	{t="trade offer deal swap give me your stuff robux items sell buy exchange", c="trade"},
	{t="help how do i where is what is stuck lost confused need assist struggling", c="help"},
	{t="lol lmao funny haha bruh omg no way deadass fr based ngl tbh istg", c="reaction"},
	{t="good job nice well done cool amazing great awesome fire goated W", c="praise"},
	{t="noob ez trash bad skill issue get rekt loser ratio cry cope L bozo", c="toxic"},
	{t="join my game server come play with me invite link send party group", c="invite"},
	{t="what why when how tell me explain info general question wondering curious", c="general"},
	{t="roblox game play server lag ping update robux premium gamepass blox", c="roblox"},
	{t="gaming pc console fps grind ranked casual platform setup graphics", c="gaming"},
	{t="mood vibe energy feeling today lowkey highkey same felt relatable big", c="mood"},
	{t="sad happy angry mad upset frustrated chill relaxed excited nervous anxious", c="feeling"},
	{t="think believe know fact true false real fake opinion idea thought", c="question"},
	{t="learn study school work grind improve get better practice train skill", c="learn"},
	{t="idk idek not sure maybe probably doubt possibly depends could be either", c="general"},
	{t="bro bro bro wait hold on actually ngl lowkey highkey literally basically", c="reaction"},
	{t="u you ur your we they them their everyone nobody somebody anybody", c="general"},
	{t="time today tomorrow yesterday morning night late early always never sometimes", c="general"},
	{t="money rich broke expensive cheap free cost worth value pay earn save", c="general"},
	{t="food eat hungry pizza burger ramen fries snack meal drink water hungry", c="general"},
	{t="music song listen vibe playlist artist album track beat drop banger", c="general"},
	{t="sports team win lose game match score goal point play athlete fan", c="general"},
	{t="anime show watch episode season character plot story arc fight power", c="general"},
	{t="phone device app update install crash bug fix version latest new old", c="help"},
	{t="friend people person someone nobody everyone alone together collab duo", c="general"},
	{t="love like hate dislike enjoy prefer rather choose pick favorite best worst", c="feeling"},
	{t="work hard easy difficult simple complicated confusing clear obvious makes sense", c="general"},
	{t="new old different same change update version better worse improve worse same", c="general"},
	{t="yes no maybe sure ok alright fine whatever sure definitely absolutely", c="general"},
}

local KnowledgeBase = {
	{t="the sun is a star at the center of our solar system and provides light and heat", c="fact"},
	{t="water freezes at 0 degrees celsius and boils at 100 degrees celsius", c="fact"},
	{t="the earth orbits the sun once every 365 days which is one year", c="fact"},
	{t="roblox was founded in 2004 and launched publicly in 2006 by david baszucki", c="fact"},
	{t="minecraft was created by notch and released in 2011 by mojang studios", c="fact"},
	{t="the human body has 206 bones and about 37 trillion cells", c="fact"},
	{t="oxygen is the most abundant element in the earths crust by mass", c="fact"},
	{t="the speed of light is approximately 299792 kilometers per second", c="fact"},
	{t="there are 7 continents and 5 oceans on earth according to most definitions", c="fact"},
	{t="python javascript lua and java are popular programming languages used today", c="fact"},
	{t="the moon causes tides on earth through gravitational pull", c="fact"},
	{t="dna stores genetic information and is found in almost every cell in your body", c="fact"},
	{t="the internet was invented in the late 1960s with arpanet as its predecessor", c="fact"},
	{t="artificial intelligence is a branch of computer science focused on intelligent machines", c="fact"},
	{t="social media platforms include instagram tiktok twitter youtube and discord", c="fact"},
	{t="the largest planet in our solar system is jupiter which is a gas giant", c="fact"},
	{t="photosynthesis is the process plants use to convert sunlight into food energy", c="fact"},
	{t="gravity is the force that pulls objects toward each other based on mass", c="fact"},
	{t="the average human sleeps about 8 hours per night which is a third of life", c="fact"},
	{t="video games have been shown to improve reaction time and problem solving skills", c="fact"},
}

local function seedBrain(mk)
	for _, entry in ipairs(SeedData) do
		for i = 1, 3 do
			bayesLearn(entry.t, entry.c, nil, mk)
		end
		markovLearn(entry.t, mk)
	end
	for _, entry in ipairs(KnowledgeBase) do
		bayesLearn(entry.t, entry.c, nil, mk)
		markovLearn(entry.t, mk)
	end
	local conversations = {
		"hey how are you doing today",
		"im doing pretty good thanks for asking",
		"thats great to hear what have you been up to",
		"just been grinding roblox honestly ngl",
		"same bro the grind never stops fr",
		"have you played any good games lately",
		"yeah blox fruits been pretty good actually",
		"nice what server are you on",
		"idk some random one lol",
		"what level are you at",
		"im pretty high level at this point ngl",
		"thats actually goated keep going",
		"yeah im trying to get max level",
		"how long have you been playing",
		"like a few months now honestly",
		"thats not bad at all actually",
		"yeah i enjoy it a lot",
		"do you play with friends or solo",
		"mostly solo but sometimes with friends",
		"solo grind hits different fr",
		"no cap it really does",
		"what do you think about the new update",
		"it was pretty good actually some nice changes",
		"yeah the devs cooked on that one",
		"for real they actually listened to feedback",
		"thats rare for roblox games tbh",
		"deadass they usually dont listen",
		"anyway what are you doing later",
		"probably just chilling and gaming",
		"same vibes same energy",
		"lowkey the best way to spend time",
		"facts nothing beats a good gaming session",
		"especially when you have good music going",
		"oh yeah what are you listening to",
		"just whatever is on my playlist honestly",
		"nice taste probably",
		"lol hopefully yeah",
		"music and gaming is the combo fr",
		"no other combo hits the same",
		"hard agree on that one",
	}
	for i = 1, #conversations - 1 do
		markovLearn(conversations[i], mk)
		if i % 2 == 0 then
			local intent = bayesClassify(conversations[i], 20, mk)
			bayesLearn(conversations[i], intent, 20, mk)
		end
	end
	seedSentiment(mk)
end

--------------------------------------------------------------------------------
-- [[ QUALITY PIPELINE ]]
--------------------------------------------------------------------------------

local SafeFallbacks = {
	"fr","yeah","nah","idk","interesting","makes sense","ok","maybe",
	"deadass","bruh","lol","gg","facts","no cap","based","real","say less","bet","word","true",
}

local function safeReply() return SafeFallbacks[m_random(1, #SafeFallbacks)] end

local function repetitionPenalty(tokens, penalty)
	local seen, score = {}, 0
	for _, w in ipairs(tokens) do
		if seen[w] then score -= penalty end
		seen[w] = true
	end
	return score
end

local function perplexity(text, mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local tokens = tokenize(text)
	if #tokens < 2 then return math.huge end
	local logSum, count = 0, 0
	for i = 1, #tokens-1 do
		local nexts = B.Markov[tokens[i]]
		local total, found = 0, 0
		if nexts then
			for _, c in pairs(nexts) do total += c end
			found = nexts[tokens[i+1]] or 0
		end
		local prob = total > 0 and (found + 0.1) / (total + 1) or 0.01
		logSum += m_log(prob)
		count += 1
	end
	return m_exp(-logSum / count)
end

local function isCoherent(text, mode, mk)
	local mdl = Models[mk or ActiveModelKey]
	if not text or text == "..." or #text < 2 then return false end
	local px = perplexity(text, mk)
	if px > mdl.perplexityLimit then return false end
	local ms = markovScore(text, mode, mk)
	if ms < mdl.coherenceThreshold then return false end
	return true
end

local function scoreCandidate(text, intent, conf, mode, mk)
	local mScore = markovScore(text, mode, mk)
	local _, conf2 = bayesClassify(text, mode.tokenCap, mk)
	local sentScore = 0
	if mode.sentimentCheck then
		sentScore = sentimentScore(text, mk) * 0.2
	end
	local tokens = tokenize(text)
	local repP = repetitionPenalty(tokens, mode.repetitionPenalty or 0.5)
	local px = perplexity(text, mk)
	local pxBonus = px < (Models[mk or ActiveModelKey].perplexityLimit * 0.5) and 0.5 or 0
	local notEmpty = text ~= "..." and #text > 2 and 1 or 0
	local lenBonus = #tokens >= 3 and 0.3 or 0
	return conf * 1.5 + mScore + conf2 * 0.8 + sentScore + repP + pxBonus + notEmpty + lenBonus
end

--------------------------------------------------------------------------------
-- [[ MEMORY + CONTEXT ]]
--------------------------------------------------------------------------------

local function memoryStore(text, intent, mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local slots = Models[mk].memorySlots
	t_insert(B.Memory, 1, { text=text, intent=intent, tokens=countTokens(text), time=os.time(), weight=1.0 })
	if #B.Memory > slots then t_remove(B.Memory, #B.Memory) end
end

local function memoryContext(mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	if #B.Memory == 0 then return "" end
	local parts = {}
	for _, m in ipairs(B.Memory) do t_insert(parts, m.text) end
	return t_concat(parts, " ")
end

local function trimContext(mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local session = nil
	for _, s in ipairs(B.Sessions) do if s.id == B.CurrentSessionId then session = s break end end
	if not session then return end
	local limit = Models[mk].contextLimit
	local total = 0
	for i = #session.messages, 1, -1 do
		total += countTokens(session.messages[i].text)
		if total > limit then
			local trimmed = i - 1
			for j = 1, trimmed do t_remove(session.messages, 1) end
			t_insert(session.messages, 1, { text="[context trimmed — "..trimmed.." messages]", role="system", intent="system", time=os.time() })
			break
		end
	end
end

local function updateContextTokens(mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local session = nil
	for _, s in ipairs(B.Sessions) do if s.id == B.CurrentSessionId then session = s break end end
	if not session then B.ContextTokens = 0 return end
	local total = 0
	for _, msg in ipairs(session.messages) do total += countTokens(msg.text) end
	B.ContextTokens = total
end

--------------------------------------------------------------------------------
-- [[ LANGUAGE LOCK ]]
--------------------------------------------------------------------------------

local LanguageSeeds = {
	english = {},
	spanish = {
		greeting={"¡hola!","¿qué tal?","buenas","hey"},
		farewell={"¡adiós!","hasta luego","nos vemos","chau"},
		reaction={"jajaja","no way","qué?","enserio"},
		general={"interesante","ok","sí","no","quizás"},
	},
	portuguese = {
		greeting={"oi!","olá","e aí","opa"},
		farewell={"tchau","até mais","falou","xau"},
		reaction={"kkk","caramba","sério?","nossa"},
		general={"interessante","ok","sim","não","talvez"},
	},
}

local function getLanguageReply(intent)
	local lang = GlobalSettings.language
	if lang == "english" or not LanguageSeeds[lang] then return nil end
	local pool = LanguageSeeds[lang][intent] or LanguageSeeds[lang]["general"]
	if pool and #pool > 0 then return pool[m_random(1, #pool)] end
	return nil
end

--------------------------------------------------------------------------------
-- [[ INFERENCE ENGINE ]]
--------------------------------------------------------------------------------

local function generateCandidate(input, mode, mk)
	mk = mk or ActiveModelKey
	local mdl = Models[mk]
	local intent, confidence = bayesClassify(input, mode.tokenCap, mk)
	local tScore = tfidfScore(input, intent, mk)
	local adjustedConf = confidence + tScore * 0.1
	local _, expertData = routeExpert(intent)
	local markovKeys = countMarkovKeys(mk)
	local memCtx = memoryContext(mk)
	local sp = GlobalSettings.systemPrompt
	local enriched = (sp ~= "" and (sp .. " ") or "") .. (memCtx ~= "" and (memCtx .. " ") or "") .. input

	if GlobalSettings.language ~= "english" then
		local lr = getLanguageReply(intent)
		if lr then return lr, intent, adjustedConf end
	end

	if adjustedConf > mdl.confidenceThreshold and m_random() > 0.28 then
		local r = getReply(intent, expertData)
		if r then return r, intent, adjustedConf end
	end

	if markovKeys < mdl.minMarkovKeys then
		if mdl.fallbackToPool then
			local r = getReply(intent, expertData)
			if r then return r, intent, adjustedConf end
		end
		return safeReply(), intent, adjustedConf
	end

	local genLen = m_random(4, 14)
	local generated = markovGenerate(enriched, genLen, mode, mk)

	if not isCoherent(generated, mode, mk) then
		generated = markovGenerate(input, genLen, mode, mk)
		if not isCoherent(generated, mode, mk) then
			local r = getReply(intent, expertData)
			if r then return r, intent, adjustedConf end
			return safeReply(), intent, adjustedConf
		end
	end

	return generated, intent, adjustedConf
end

local function fusionRespond(input, mode, mk)
	local candidates = {}
	for fusionKey, _ in pairs(Models) do
		if fusionKey ~= "pro" then
			local fusionMode = Models[fusionKey].modes[Models[fusionKey].defaultMode]
			for i = 1, 3 do
				local reply, intent, conf = generateCandidate(input, fusionMode, fusionKey)
				t_insert(candidates, { text=reply, intent=intent, confidence=conf, score=0, source=fusionKey })
			end
		end
	end
	for _, c in ipairs(candidates) do
		c.score = scoreCandidate(c.text, c.intent, c.confidence, mode, "flash")
	end
	t_sort(candidates, function(a, b) return a.score > b.score end)
	local winner = candidates[1]
	if winner and winner.text ~= "..." then return winner.text, winner.intent end
	return safeReply(), "general"
end

local function webSearch(query)
	if not (syn and syn.request or http and http.request or request) then return nil end
	local reqFunc = (syn and syn.request) or (http and http.request) or request
	local ok, res = pcall(reqFunc, {
		Url = "https://api.duckduckgo.com/?q=" .. HttpService:UrlEncode(query) .. "&format=json&no_html=1&skip_disambig=1",
		Method = "GET",
	})
	if not ok or not res or res.StatusCode ~= 200 then return nil end
	local ok2, data = pcall(HttpService.JSONDecode, HttpService, res.Body)
	if not ok2 or not data then return nil end
	if data.AbstractText and #data.AbstractText > 10 then
		return s_sub(data.AbstractText, 1, 200)
	end
	if data.Answer and #data.Answer > 2 then return data.Answer end
	return nil
end

local function respond(input, mode, mk)
	mk = mk or ActiveModelKey
	local candidates = {}

	if mode.fusionMode then
		local fr, fi = fusionRespond(input, mode, mk)
		t_insert(candidates, { text=fr, intent=fi, confidence=0.7, score=0 })
	end

	if mode.useWeb and GlobalSettings.webEnabled then
		local webResult = webSearch(input)
		if webResult then
			markovLearn(webResult, mk)
			t_insert(candidates, { text=webResult, intent="general", confidence=0.9, score=5 })
		end
	end

	for i = 1, mode.candidates do
		local reply, intent, conf = generateCandidate(input, mode, mk)
		t_insert(candidates, { text=reply, intent=intent, confidence=conf, score=0 })
	end

	if not mode.rescore or #candidates == 1 then
		return candidates[1].text, candidates[1].intent
	end

	for _, c in ipairs(candidates) do
		c.score = scoreCandidate(c.text, c.intent, c.confidence, mode, mk)
	end

	for pass = 1, mode.rescorePasses do
		for _, c in ipairs(candidates) do
			local _, rc = bayesClassify(c.text, mode.tokenCap, mk)
			local rms = markovScore(c.text, mode, mk)
			c.score += rc * (0.5 * pass) + rms * (0.3 * pass)
		end
	end

	t_sort(candidates, function(a, b) return a.score > b.score end)
	local winner = candidates[1]
	if winner.text == "..." and #candidates > 1 then winner = candidates[2] end
	return winner.text, winner.intent
end

--------------------------------------------------------------------------------
-- [[ SESSION MANAGEMENT ]]
--------------------------------------------------------------------------------

local function newSession(mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local id = tostring(os.time()).."_"..tostring(m_random(1000,9999))
	local session = { id=id, title="New chat", messages={}, timestamp=os.time() }
	t_insert(B.Sessions, 1, session)
	if #B.Sessions > Models[mk].maxChatSessions then t_remove(B.Sessions, #B.Sessions) end
	B.CurrentSessionId = id
	return session
end

local function getCurrentSession(mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	for _, s in ipairs(B.Sessions) do if s.id == B.CurrentSessionId then return s end end
	return newSession(mk)
end

local function addToSession(text, role, intent, mk)
	mk = mk or ActiveModelKey
	local session = getCurrentSession(mk)
	t_insert(session.messages, { text=text, role=role, intent=intent or "general", time=os.time() })
	if role == "user" and #session.messages <= 2 then
		local words = tokenize(text)
		session.title = words[1] and (words[1]..(words[2] and " "..words[2] or "")) or "New chat"
	end
end

--------------------------------------------------------------------------------
-- [[ PERSISTENCE ]]
--------------------------------------------------------------------------------

local function applyWeightDecay(mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	local decay = 1 - getLR(mk) * 0.1
	local threshold = 1
	for key, nexts in pairs(B.Markov) do
		local allLow = true
		for word, count in pairs(nexts) do
			local newCount = count * decay
			if newCount < threshold then
				nexts[word] = nil
			else
				nexts[word] = newCount
				allLow = false
			end
		end
		if allLow or next(nexts) == nil then B.Markov[key] = nil end
	end
end

local function saveData(mk)
	mk = mk or ActiveModelKey
	if not writefile then return end
	local B = Brains[mk]
	local ok, encoded = pcall(HttpService.JSONEncode, HttpService, {
		Markov=B.Markov, Bigram=B.Bigram, Trigram=B.Trigram,
		Bayes=B.Bayes, TFIDF=B.TFIDF, Sentiment=B.Sentiment,
		Memory=B.Memory, Sessions=B.Sessions, CurrentSessionId=B.CurrentSessionId,
		TotalInputTokens=B.TotalInputTokens, TotalOutputTokens=B.TotalOutputTokens,
		EffectiveParams=B.EffectiveParams, LearningRate=B.LearningRate,
	})
	if ok then pcall(writefile, Models[mk].saveFile, encoded) end
end

local function loadData(mk)
	mk = mk or ActiveModelKey
	local B = Brains[mk]
	if not isfile or not isfile(Models[mk].saveFile) then seedBrain(mk) newSession(mk) return end
	local ok, content = pcall(readfile, Models[mk].saveFile)
	if not ok then seedBrain(mk) newSession(mk) return end
	local ok2, data = pcall(HttpService.JSONDecode, HttpService, content)
	if not ok2 or not data then seedBrain(mk) newSession(mk) return end
	B.Markov = data.Markov or {}
	B.Bigram = data.Bigram or {}
	B.Trigram = data.Trigram or {}
	B.Sessions = data.Sessions or {}
	B.CurrentSessionId = data.CurrentSessionId or nil
	B.Memory = data.Memory or {}
	B.TotalInputTokens = data.TotalInputTokens or 0
	B.TotalOutputTokens = data.TotalOutputTokens or 0
	B.EffectiveParams = data.EffectiveParams or nil
	B.LearningRate = data.LearningRate or nil
	if data.Bayes then
		B.Bayes.classCounts = data.Bayes.classCounts or {}
		B.Bayes.wordCounts = data.Bayes.wordCounts or {}
		B.Bayes.totalDocs = data.Bayes.totalDocs or 0
		B.Bayes.vocab = data.Bayes.vocab or {}
	end
	if data.TFIDF then B.TFIDF.docFreq = data.TFIDF.docFreq or {} B.TFIDF.totalDocs = data.TFIDF.totalDocs or 0 end
	if data.Sentiment then B.Sentiment.pos = data.Sentiment.pos or {} B.Sentiment.neg = data.Sentiment.neg or {} end
	local hasData = false
	for _ in pairs(B.Bayes.classCounts) do hasData = true break end
	if not hasData then seedBrain(mk) end
	if not B.CurrentSessionId or #B.Sessions == 0 then newSession(mk) end
	updateContextTokens(mk)
end

--------------------------------------------------------------------------------
-- [[ PASSIVE LISTENER ]]
--------------------------------------------------------------------------------

local function checkAlerts(text)
	if #GlobalSettings.alertKeywords == 0 then return end
	local lower = s_lower(text)
	for _, kw in ipairs(GlobalSettings.alertKeywords) do
		if lower:find(s_lower(kw), 1, true) then
			if GUI and GUI.showAlert then GUI:showAlert("🔔 Alert: \"" .. kw .. "\" detected in chat") end
		end
	end
end

local function detectLanguage(text)
	local spanish = {"hola","gracias","qué","cómo","está","bien","amigo","juego"}
	local portuguese = {"olá","obrigado","como","está","bom","amigo","jogo","voce"}
	local lower = s_lower(text)
	local spScore, ptScore = 0, 0
	for _, w in ipairs(spanish) do if lower:find(w) then spScore += 1 end end
	for _, w in ipairs(portuguese) do if lower:find(w) then ptScore += 1 end end
	if spScore >= 2 then return "🇪🇸 ES" end
	if ptScore >= 2 then return "🇧🇷 PT" end
	return nil
end

local function ingestMessage(text, speaker)
	for mk in pairs(Models) do
		local B = Brains[mk]
		if not B.Active then continue end
		if not text or #text < 2 or #text > 200 then continue end
		if speaker == LocalPlayer then continue end
		local tokens = tokenize(text)
		if #tokens < 1 then continue end
		if tokens[1] == tokens[2] and #tokens < 3 then continue end
		markovLearn(text, mk)
		local intent = bayesClassify(text, Models[mk].maxTokens, mk)
		bayesLearn(text, intent, Models[mk].maxTokens, mk)
		local sentTokens = tokenize(text)
		for _, w in ipairs(sentTokens) do
			if sentimentScore(w, mk) > 0 then B.Sentiment.pos[w] = (B.Sentiment.pos[w] or 0) + 1 end
			if sentimentScore(w, mk) < 0 then B.Sentiment.neg[w] = (B.Sentiment.neg[w] or 0) + 1 end
		end
		t_insert(B.ChatLog, {t=text, s=speaker and speaker.Name or "?"})
		if #B.ChatLog > Models[mk].maxLog then t_remove(B.ChatLog, 1) end
		if #B.ChatLog % 20 == 0 then task.spawn(saveData, mk) end
		if #B.ChatLog % 100 == 0 then task.spawn(applyWeightDecay, mk) end
	end
	checkAlerts(text)
	local lang = detectLanguage(text)
	if lang and GUI and GUI.showLangHint then GUI:showLangHint(lang) end
	if GUI then GUI:updateStats() end
end

--------------------------------------------------------------------------------
-- [[ FILE WATCHER ]]
--------------------------------------------------------------------------------

local function processFile(path)
	if not isfile or not isfile(path) then return end
	local ok, content = pcall(readfile, path)
	if not ok or not content or #content < 2 then return end
	local ext = path:match("%.(%w+)$") or ""
	ext = s_lower(ext)
	if ext == "json" then
		local ok2, data = pcall(HttpService.JSONDecode, HttpService, content)
		if ok2 and data and data.v and data.msgs then
			if GUI then GUI:addMessage("📎 Imported chat session: " .. (data.t or "unknown"), true, "system") end
			return
		end
	end
	local text = content:gsub("[%c]", " "):gsub("%s+", " ")
	for line in text:gmatch("[^\n]+") do
		if #line > 3 then
			markovLearn(line, ActiveModelKey)
			local intent = bayesClassify(line, ActiveModel.maxTokens, ActiveModelKey)
			bayesLearn(line, intent, ActiveModel.maxTokens, ActiveModelKey)
		end
	end
	if GUI then GUI:addMessage("📎 File learned: " .. path .. " (" .. #content .. " chars)", true, "system") end
	GUI:updateStats()
end

task.spawn(function()
	if not listfiles then return end
	local known = {}
	local ignored = { [Models.flash.saveFile]=true, [Models.deepthink.saveFile]=true, [Models.pro.saveFile]=true }
	while true do
		task.wait(3)
		local ok, files = pcall(listfiles, "")
		if ok and files then
			for _, path in ipairs(files) do
				if not known[path] and not ignored[path] then
					known[path] = true
					local ext = s_lower(path:match("%.(%w+)$") or "")
					if ext == "txt" or ext == "json" or ext == "lua" or ext == "csv" or ext == "md" then
						task.spawn(processFile, path)
					end
				end
			end
		end
	end
end)

--------------------------------------------------------------------------------
-- [[ GUI ]]
--------------------------------------------------------------------------------

local GUI = { msgCount=0, scrollLocked=true, minimized=false }

local C = {
	bg =           Color3.fromRGB(31, 31, 31),
	bgSidebar =    Color3.fromRGB(24, 24, 24),
	bgHover =      Color3.fromRGB(38, 38, 38),
	bgInput =      Color3.fromRGB(38, 38, 38),
	bgBubbleBot =  Color3.fromRGB(38, 38, 38),
	bgBubbleUser = Color3.fromRGB(31, 31, 31),
	bgSettings =   Color3.fromRGB(24, 24, 24),
	stroke =       Color3.fromRGB(55, 55, 55),
	txtPrimary =   Color3.fromRGB(236, 236, 241),
	txtSecondary = Color3.fromRGB(142, 142, 160),
	txtMuted =     Color3.fromRGB(90, 90, 105),
	txtBot =       Color3.fromRGB(200, 220, 255),
	txtUser =      Color3.fromRGB(236, 236, 241),
	txtTime =      Color3.fromRGB(90, 90, 110),
	txtIntent =    Color3.fromRGB(80, 160, 100),
	accent =       Color3.fromRGB(25, 195, 125),
	accentBlue =   Color3.fromRGB(50, 130, 240),
	red =          Color3.fromRGB(200, 60, 60),
	scrollbar =    Color3.fromRGB(55, 55, 65),
	white =        Color3.fromRGB(255, 255, 255),
}

local function mkCorner(p, r) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r or 6) end
local function mkStroke(p, col, th) local s=Instance.new("UIStroke",p) s.Color=col or C.stroke s.Thickness=th or 1 end
local function mkPad(p,t,b,l,r) local pad=Instance.new("UIPadding",p) pad.PaddingTop=UDim.new(0,t or 0) pad.PaddingBottom=UDim.new(0,b or 0) pad.PaddingLeft=UDim.new(0,l or 0) pad.PaddingRight=UDim.new(0,r or 0) end
local function mkList(p,dir,pad) local l=Instance.new("UIListLayout",p) l.FillDirection=dir or Enum.FillDirection.Vertical l.Padding=UDim.new(0,pad or 4) l.SortOrder=Enum.SortOrder.LayoutOrder return l end

local function mkLabel(parent, text, size, color, font, xa)
	local l = Instance.new("TextLabel", parent)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color or C.txtPrimary
	l.Font = font or Enum.Font.Gotham
	l.TextSize = size or 13
	l.TextXAlignment = xa or Enum.TextXAlignment.Left
	l.TextWrapped = true
	return l
end

local function mkBtn(parent, text, size, color, textColor, fontSize)
	local b = Instance.new("TextButton", parent)
	b.BackgroundColor3 = color or C.bgHover
	b.Text = text
	b.TextColor3 = textColor or C.txtPrimary
	b.Font = Enum.Font.GothamBold
	b.TextSize = fontSize or 12
	b.BorderSizePixel = 0
	b.Size = size or UDim2.new(1,0,0,32)
	return b
end

local function buildGUI()
	local screen = Instance.new("ScreenGui")
	screen.Name = "ChatMind"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	if getgenv and getgenv().protect_gui then getgenv().protect_gui(screen) end
	screen.Parent = CoreGui
	GUI.screen = screen

	local main = Instance.new("Frame", screen)
	main.Name = "Main"
	main.Size = UDim2.new(0, 760, 0, 480)
	main.Position = UDim2.new(0.5, -380, 0.5, -240)
	main.BackgroundColor3 = C.bg
	main.BorderSizePixel = 0
	main.Active = true
	main.ClipsDescendants = true
	mkCorner(main, 10)
	mkStroke(main)
	GUI.main = main

	-- FLOATING RESTORE BUTTON
	local floatBtn = Instance.new("TextButton", screen)
	floatBtn.Size = UDim2.new(0, 44, 0, 44)
	floatBtn.Position = UDim2.new(1, -54, 1, -54)
	floatBtn.BackgroundColor3 = C.accent
	floatBtn.Text = "💬"
	floatBtn.TextColor3 = C.white
	floatBtn.Font = Enum.Font.GothamBold
	floatBtn.TextSize = 20
	floatBtn.BorderSizePixel = 0
	floatBtn.Visible = false
	mkCorner(floatBtn, 99)
	GUI.floatBtn = floatBtn
	floatBtn.MouseButton1Click:Connect(function()
		main.Visible = true
		floatBtn.Visible = false
	end)

	-- SIDEBAR
	local sidebar = Instance.new("Frame", main)
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 200, 1, 0)
	sidebar.BackgroundColor3 = C.bgSidebar
	sidebar.BorderSizePixel = 0
	GUI.sidebar = sidebar

	local sideTop = Instance.new("Frame", sidebar)
	sideTop.Size = UDim2.new(1, 0, 0, 52)
	sideTop.BackgroundTransparency = 1
	sideTop.BorderSizePixel = 0
	mkPad(sideTop, 10, 0, 12, 12)

	local appName = mkLabel(sideTop, "ChatMind", 15, C.txtPrimary, Enum.Font.GothamBold)
	appName.Size = UDim2.new(1, 0, 1, 0)

	local sideContent = Instance.new("Frame", sidebar)
	sideContent.Size = UDim2.new(1, 0, 1, -52)
	sideContent.Position = UDim2.new(0, 0, 0, 52)
	sideContent.BackgroundTransparency = 1
	sideContent.ClipsDescendants = true

	local newChatBtn = Instance.new("TextButton", sideContent)
	newChatBtn.Size = UDim2.new(1, -16, 0, 32)
	newChatBtn.Position = UDim2.new(0, 8, 0, 0)
	newChatBtn.BackgroundColor3 = C.bgHover
	newChatBtn.Text = ""
	newChatBtn.BorderSizePixel = 0
	mkCorner(newChatBtn, 6)
	local ncbRow = Instance.new("Frame", newChatBtn)
	ncbRow.Size = UDim2.new(1, -16, 1, 0)
	ncbRow.Position = UDim2.new(0, 8, 0, 0)
	ncbRow.BackgroundTransparency = 1
	mkList(ncbRow, Enum.FillDirection.Horizontal, 6)
	local ncbPlus = mkLabel(ncbRow, "+", 14, C.txtSecondary, Enum.Font.GothamBold)
	ncbPlus.Size = UDim2.new(0, 14, 1, 0)
	local ncbLbl = mkLabel(ncbRow, "New chat", 12, C.txtSecondary)
	ncbLbl.Size = UDim2.new(1, -20, 1, 0)

	local sessionDivider = Instance.new("Frame", sideContent)
	sessionDivider.Size = UDim2.new(1, -16, 0, 1)
	sessionDivider.Position = UDim2.new(0, 8, 0, 40)
	sessionDivider.BackgroundColor3 = C.stroke
	sessionDivider.BorderSizePixel = 0

	local chatsLabel = mkLabel(sideContent, "Chats", 10, C.txtMuted, Enum.Font.GothamBold)
	chatsLabel.Size = UDim2.new(1, -16, 0, 20)
	chatsLabel.Position = UDim2.new(0, 12, 0, 48)

	local sessionScroll = Instance.new("ScrollingFrame", sideContent)
	sessionScroll.Size = UDim2.new(1, 0, 1, -140)
	sessionScroll.Position = UDim2.new(0, 0, 0, 70)
	sessionScroll.BackgroundTransparency = 1
	sessionScroll.BorderSizePixel = 0
	sessionScroll.ScrollBarThickness = 2
	sessionScroll.ScrollBarImageColor3 = C.scrollbar
	sessionScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	sessionScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	mkList(sessionScroll, nil, 1)
	mkPad(sessionScroll, 2, 4, 8, 8)
	GUI.sessionScroll = sessionScroll

	local sideBottomDivider = Instance.new("Frame", sideContent)
	sideBottomDivider.Size = UDim2.new(1, -16, 0, 1)
	sideBottomDivider.Position = UDim2.new(0, 8, 1, -88)
	sideBottomDivider.BackgroundColor3 = C.stroke
	sideBottomDivider.BorderSizePixel = 0

	local settingsBtn = Instance.new("TextButton", sideContent)
	settingsBtn.Size = UDim2.new(1, -16, 0, 32)
	settingsBtn.Position = UDim2.new(0, 8, 1, -84)
	settingsBtn.BackgroundTransparency = 1
	settingsBtn.Text = ""
	settingsBtn.BorderSizePixel = 0
	mkCorner(settingsBtn, 6)
	local sbRow = Instance.new("Frame", settingsBtn)
	sbRow.Size = UDim2.new(1, -8, 1, 0)
	sbRow.Position = UDim2.new(0, 8, 0, 0)
	sbRow.BackgroundTransparency = 1
	mkList(sbRow, Enum.FillDirection.Horizontal, 8)
	local sbIcon = mkLabel(sbRow, "⚙", 13, C.txtSecondary, Enum.Font.GothamBold)
	sbIcon.Size = UDim2.new(0, 16, 1, 0)
	local sbLbl = mkLabel(sbRow, "Settings", 12, C.txtSecondary)
	sbLbl.Size = UDim2.new(1, -24, 1, 0)

	local playerRow = Instance.new("Frame", sideContent)
	playerRow.Size = UDim2.new(1, -16, 0, 36)
	playerRow.Position = UDim2.new(0, 8, 1, -48)
	playerRow.BackgroundTransparency = 1
	playerRow.BorderSizePixel = 0
	mkList(playerRow, Enum.FillDirection.Horizontal, 8)

	local playerAvatar = Instance.new("Frame", playerRow)
	playerAvatar.Size = UDim2.new(0, 26, 0, 26)
	playerAvatar.BackgroundColor3 = C.accent
	playerAvatar.BorderSizePixel = 0
	mkCorner(playerAvatar, 99)
	local playerInitial = mkLabel(playerAvatar, s_sub(LocalPlayer.Name, 1, 1):upper(), 12, C.white, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	playerInitial.Size = UDim2.new(1, 0, 1, 0)

	local playerName = mkLabel(playerRow, LocalPlayer.Name, 12, C.txtSecondary)
	playerName.Size = UDim2.new(1, -34, 0, 26)

	-- MAIN CHAT COLUMN
	local chatCol = Instance.new("Frame", main)
	chatCol.Name = "ChatCol"
	chatCol.Size = UDim2.new(1, -200, 1, 0)
	chatCol.Position = UDim2.new(0, 200, 0, 0)
	chatCol.BackgroundTransparency = 1
	GUI.chatCol = chatCol

	-- TOPBAR
	local topbar = Instance.new("Frame", chatCol)
	topbar.Size = UDim2.new(1, 0, 0, 44)
	topbar.BackgroundColor3 = C.bg
	topbar.BorderSizePixel = 0
	topbar.ZIndex = 5
	mkPad(topbar, 0, 0, 8, 8)

	local tbLeft = Instance.new("Frame", topbar)
	tbLeft.Size = UDim2.new(0, 160, 1, 0)
	tbLeft.BackgroundTransparency = 1
	mkList(tbLeft, Enum.FillDirection.Horizontal, 6)
	mkPad(tbLeft, 8, 8, 0, 0)

	local sideToggleBtn = Instance.new("TextButton", tbLeft)
	sideToggleBtn.Size = UDim2.new(0, 22, 0, 22)
	sideToggleBtn.BackgroundTransparency = 1
	sideToggleBtn.Text = "☰"
	sideToggleBtn.TextColor3 = C.txtSecondary
	sideToggleBtn.Font = Enum.Font.GothamBold
	sideToggleBtn.TextSize = 14
	sideToggleBtn.BorderSizePixel = 0

	local sessionTitleLbl = mkLabel(tbLeft, "New chat", 13, C.txtPrimary, Enum.Font.GothamBold)
	sessionTitleLbl.Size = UDim2.new(0, 130, 1, 0)
	GUI.sessionTitleLbl = sessionTitleLbl

	local tbRight = Instance.new("Frame", topbar)
	tbRight.Size = UDim2.new(0, 120, 1, 0)
	tbRight.Position = UDim2.new(1, -120, 0, 0)
	tbRight.BackgroundTransparency = 1
	mkList(tbRight, Enum.FillDirection.Horizontal, 4)
	mkPad(tbRight, 8, 8, 0, 0)

	local shareBtn = mkBtn(tbRight, "⬆ Share", UDim2.new(0, 70, 0, 26), C.bgHover, C.txtSecondary, 11)
	mkCorner(shareBtn, 5)
	GUI.shareBtn = shareBtn

	local minBtn = mkBtn(tbRight, "−", UDim2.new(0, 26, 0, 26), C.bgHover, C.txtSecondary, 14)
	mkCorner(minBtn, 5)

	local closeBtn = mkBtn(tbRight, "✕", UDim2.new(0, 26, 0, 26), C.red, C.white, 11)
	mkCorner(closeBtn, 5)

	local tbDivider = Instance.new("Frame", chatCol)
	tbDivider.Size = UDim2.new(1, 0, 0, 1)
	tbDivider.Position = UDim2.new(0, 0, 0, 44)
	tbDivider.BackgroundColor3 = C.stroke
	tbDivider.BorderSizePixel = 0

	-- ALERT BANNER
	local alertBanner = Instance.new("Frame", chatCol)
	alertBanner.Size = UDim2.new(1, 0, 0, 0)
	alertBanner.Position = UDim2.new(0, 0, 0, 45)
	alertBanner.BackgroundColor3 = Color3.fromRGB(180, 120, 20)
	alertBanner.BorderSizePixel = 0
	alertBanner.Visible = false
	alertBanner.ClipsDescendants = true
	local alertLbl = mkLabel(alertBanner, "", 11, C.white, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	alertLbl.Size = UDim2.new(1, 0, 1, 0)
	GUI.alertBanner = alertBanner
	GUI.alertLbl = alertLbl

	-- CHAT SCROLL
	local chatScroll = Instance.new("ScrollingFrame", chatCol)
	chatScroll.Size = UDim2.new(1, 0, 1, -112)
	chatScroll.Position = UDim2.new(0, 0, 0, 46)
	chatScroll.BackgroundTransparency = 1
	chatScroll.BorderSizePixel = 0
	chatScroll.ScrollBarThickness = 3
	chatScroll.ScrollBarImageColor3 = C.scrollbar
	chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	chatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	mkList(chatScroll, nil, 2)
	mkPad(chatScroll, 12, 12, 16, 16)
	GUI.chatScroll = chatScroll

	chatScroll:GetPropertyChangedSignal("CanvasSize"):Connect(function()
		if GUI.scrollLocked then chatScroll.CanvasPosition = Vector2.new(0, math.huge) end
	end)
	chatScroll.MouseWheelForward:Connect(function() GUI.scrollLocked = false end)
	chatScroll.Changed:Connect(function(p)
		if p == "CanvasPosition" then
			local atBottom = chatScroll.CanvasPosition.Y >= chatScroll.AbsoluteCanvasSize.Y - chatScroll.AbsoluteSize.Y - 10
			GUI.scrollLocked = atBottom
			if GUI.scrollDownBtn then GUI.scrollDownBtn.Visible = not atBottom end
		end
	end)

	local scrollDownBtn = mkBtn(chatCol, "↓", UDim2.new(0, 28, 0, 28), C.bgInput, C.txtSecondary, 13)
	scrollDownBtn.Position = UDim2.new(1, -44, 1, -118)
	scrollDownBtn.Visible = false
	scrollDownBtn.ZIndex = 4
	mkCorner(scrollDownBtn, 99)
	mkStroke(scrollDownBtn)
	GUI.scrollDownBtn = scrollDownBtn
	scrollDownBtn.MouseButton1Click:Connect(function()
		GUI.scrollLocked = true
		chatScroll.CanvasPosition = Vector2.new(0, math.huge)
	end)

	-- TYPING INDICATOR
	local typingFrame = Instance.new("Frame", chatScroll)
	typingFrame.Size = UDim2.new(0, 54, 0, 26)
	typingFrame.BackgroundColor3 = C.bgBubbleBot
	typingFrame.BorderSizePixel = 0
	typingFrame.Visible = false
	typingFrame.LayoutOrder = 999999
	mkCorner(typingFrame, 8)
	local typingLbl = mkLabel(typingFrame, "●○○", 10, C.txtBot, Enum.Font.Gotham, Enum.TextXAlignment.Center)
	typingLbl.Size = UDim2.new(1, 0, 1, 0)
	GUI.typingFrame = typingFrame
	GUI.typingLbl = typingLbl

	task.spawn(function()
		local frames = {"●○○","●●○","●●●","○●●","○○●"}
		local i = 1
		while true do
			task.wait(0.18)
			if typingFrame.Visible then typingLbl.Text = frames[i] i = i % #frames + 1 end
		end
	end)

	-- INPUT ROW
	local inputRow = Instance.new("Frame", chatCol)
	inputRow.Size = UDim2.new(1, -24, 0, 44)
	inputRow.Position = UDim2.new(0, 12, 1, -58)
	inputRow.BackgroundColor3 = C.bgInput
	inputRow.BorderSizePixel = 0
	mkCorner(inputRow, 22)
	mkStroke(inputRow)
	GUI.inputRow = inputRow

	local inputLeft = Instance.new("Frame", inputRow)
	inputLeft.Size = UDim2.new(0, 200, 1, -8)
	inputLeft.Position = UDim2.new(0, 6, 0, 4)
	inputLeft.BackgroundTransparency = 1
	mkList(inputLeft, Enum.FillDirection.Horizontal, 4)

	local attachBtn = mkBtn(inputLeft, "+", UDim2.new(0, 28, 0, 28), C.bgHover, C.txtSecondary, 14)
	mkCorner(attachBtn, 99)
	GUI.attachBtn = attachBtn

	local modelPill = Instance.new("TextButton", inputLeft)
	modelPill.Size = UDim2.new(0, 76, 0, 28)
	modelPill.BackgroundColor3 = C.bgHover
	modelPill.Text = ""
	modelPill.BorderSizePixel = 0
	mkCorner(modelPill, 99)
	local mpRow = Instance.new("Frame", modelPill)
	mpRow.Size = UDim2.new(1, -8, 1, 0)
	mpRow.Position = UDim2.new(0, 6, 0, 0)
	mpRow.BackgroundTransparency = 1
	mkList(mpRow, Enum.FillDirection.Horizontal, 2)
	local mpIcon = mkLabel(mpRow, ActiveMode.icon, 10, ActiveMode.color, Enum.Font.Gotham)
	mpIcon.Size = UDim2.new(0, 18, 1, 0)
	local mpTag = mkLabel(mpRow, ActiveModel.tag, 10, C.txtSecondary, Enum.Font.GothamBold)
	mpTag.Size = UDim2.new(0, 36, 1, 0)
	local mpArrow = mkLabel(mpRow, "▾", 9, C.txtMuted, Enum.Font.Gotham)
	mpArrow.Size = UDim2.new(0, 10, 1, 0)
	GUI.modelPill = modelPill
	GUI.mpIcon = mpIcon
	GUI.mpTag = mpTag

	local modePill = Instance.new("TextButton", inputLeft)
	modePill.Size = UDim2.new(0, 80, 0, 28)
	modePill.BackgroundColor3 = C.bgHover
	modePill.Text = ""
	modePill.BorderSizePixel = 0
	mkCorner(modePill, 99)
	local modeRow = Instance.new("Frame", modePill)
	modeRow.Size = UDim2.new(1, -8, 1, 0)
	modeRow.Position = UDim2.new(0, 6, 0, 0)
	modeRow.BackgroundTransparency = 1
	mkList(modeRow, Enum.FillDirection.Horizontal, 2)
	local modeIcon = mkLabel(modeRow, ActiveMode.icon, 9, ActiveMode.color, Enum.Font.Gotham)
	modeIcon.Size = UDim2.new(0, 18, 1, 0)
	local modeLblPill = mkLabel(modeRow, ActiveMode.label, 9, ActiveMode.color, Enum.Font.Gotham)
	modeLblPill.Size = UDim2.new(1, -22, 1, 0)
	modeLblPill.TextTruncate = Enum.TextTruncate.AtEnd
	GUI.modePill = modePill
	GUI.modeIcon = modeIcon
	GUI.modeLblPill = modeLblPill

	-- WEB TOOL BETA (Pro only, hidden by default)
	local webBtn = Instance.new("TextButton", inputLeft)
	webBtn.Size = UDim2.new(0, 62, 0, 28)
	webBtn.BackgroundColor3 = C.bgHover
	webBtn.Text = "🌐 BETA"
	webBtn.TextColor3 = C.txtMuted
	webBtn.Font = Enum.Font.GothamBold
	webBtn.TextSize = 9
	webBtn.BorderSizePixel = 0
	webBtn.Visible = false
	mkCorner(webBtn, 99)
	GUI.webBtn = webBtn
	webBtn.MouseButton1Click:Connect(function()
		GlobalSettings.webEnabled = not GlobalSettings.webEnabled
		webBtn.TextColor3 = GlobalSettings.webEnabled and Color3.fromRGB(50, 200, 255) or C.txtMuted
		webBtn.BackgroundColor3 = GlobalSettings.webEnabled and Color3.fromRGB(20, 50, 80) or C.bgHover
	end)

	local inputBox = Instance.new("TextBox", inputRow)
	inputBox.Size = UDim2.new(1, -248, 1, -8)
	inputBox.Position = UDim2.new(0, 210, 0, 4)
	inputBox.BackgroundTransparency = 1
	inputBox.TextColor3 = C.txtPrimary
	inputBox.PlaceholderText = "Message ChatMind..."
	inputBox.PlaceholderColor3 = C.txtMuted
	inputBox.Font = Enum.Font.Gotham
	inputBox.TextSize = 13
	inputBox.ClearTextOnFocus = false
	inputBox.BorderSizePixel = 0
	inputBox.Text = ""
	GUI.inputBox = inputBox

	local sendBtn = mkBtn(inputRow, "↑", UDim2.new(0, 32, 0, 32), C.accent, C.white, 16)
	sendBtn.Position = UDim2.new(1, -38, 0.5, -16)
	mkCorner(sendBtn, 99)
	GUI.sendBtn = sendBtn

	-- STATS BAR
	local statsBar = Instance.new("Frame", chatCol)
	statsBar.Size = UDim2.new(1, -24, 0, 14)
	statsBar.Position = UDim2.new(0, 12, 1, -14)
	statsBar.BackgroundTransparency = 1
	local statsLbl = mkLabel(statsBar, "", 9, C.txtMuted)
	statsLbl.Size = UDim2.new(1, 0, 1, 0)
	GUI.statsLbl = statsLbl

	-- LANG HINT
	local langHint = Instance.new("TextLabel", chatCol)
	langHint.Size = UDim2.new(0, 60, 0, 18)
	langHint.Position = UDim2.new(1, -70, 1, -72)
	langHint.BackgroundColor3 = C.bgHover
	langHint.TextColor3 = C.txtSecondary
	langHint.Font = Enum.Font.Gotham
	langHint.TextSize = 10
	langHint.Text = ""
	langHint.Visible = false
	mkCorner(langHint, 4)
	GUI.langHint = langHint

	-- DROPDOWNS
	local function buildDropdown(parent, items, onSelect)
		local dd = Instance.new("Frame", parent)
		dd.BackgroundColor3 = C.bgSettings
		dd.BorderSizePixel = 0
		dd.Visible = false
		dd.ZIndex = 30
		dd.ClipsDescendants = true
		mkCorner(dd, 8)
		mkStroke(dd)
		mkList(dd, nil, 2)
		mkPad(dd, 4, 4, 4, 4)
		local buttons = {}
		for i, item in ipairs(items) do
			local btn = Instance.new("TextButton", dd)
			btn.Size = UDim2.new(1, -8, 0, 30)
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.BorderSizePixel = 0
			btn.LayoutOrder = i
			btn.ZIndex = 31
			mkCorner(btn, 5)
			local row = Instance.new("Frame", btn)
			row.Size = UDim2.new(1, -8, 1, 0)
			row.Position = UDim2.new(0, 8, 0, 0)
			row.BackgroundTransparency = 1
			mkList(row, Enum.FillDirection.Horizontal, 6)
			row.ZIndex = 32
			if item.icon then
				local ic = mkLabel(row, item.icon, 12, item.color or C.txtPrimary, Enum.Font.GothamBold)
				ic.Size = UDim2.new(0, 20, 1, 0)
				ic.ZIndex = 32
			end
			local nm = mkLabel(row, item.label, 11, item.color or C.txtSecondary)
			nm.Size = UDim2.new(1, -26, 1, 0)
			nm.ZIndex = 32
			btn.MouseButton1Click:Connect(function()
				onSelect(item, btn, buttons)
				dd.Visible = false
			end)
			t_insert(buttons, btn)
		end
		dd.Size = UDim2.new(0, 180, 0, #items * 34 + 8)
		return dd, buttons
	end

	local modelItems = {}
	for mk, m in pairs(Models) do t_insert(modelItems, { key=mk, label=m.name, icon=m.tag, color=m.color }) end

	local modelDropdown, modelDdBtns = buildDropdown(topbar, modelItems, function(item)
		ActiveModelKey = item.key
		ActiveModel = Models[item.key]
		ActiveModeKey = ActiveModel.defaultMode
		ActiveMode = ActiveModel.modes[ActiveModeKey]
		GUI:updateModePill()
		GUI:clearChat()
		GUI:restoreSession()
		GUI:refreshSessions()
		GUI:updateStats()
	end)
	modelDropdown.Position = UDim2.new(0, 30, 1, 4)
	GUI.modelDropdown = modelDropdown

	local modeDropdown
	local function rebuildModeDropdown()
		if modeDropdown then modeDropdown:Destroy() end
		local modeItems = {}
		for mk, md in pairs(ActiveModel.modes) do
			t_insert(modeItems, { key=mk, label=md.label, icon=md.icon, color=md.color })
		end
		modeDropdown, _ = buildDropdown(inputRow, modeItems, function(item)
			ActiveModeKey = item.key
			ActiveMode = ActiveModel.modes[item.key]
			GUI:updateModePill()
		end)
		modeDropdown.Position = UDim2.new(0, 106, -1, -modeDropdown.Size.Y.Offset - 4)
		GUI.modeDropdown = modeDropdown
	end
	rebuildModeDropdown()

	function GUI:updateModePill()
		mpIcon.Text = ActiveMode.icon
		mpTag.Text = ActiveModel.tag
		mpTag.TextColor3 = ActiveModel.color
		modeIcon.Text = ActiveMode.icon
		modeIcon.TextColor3 = ActiveMode.color
		modeLblPill.Text = ActiveMode.label
		modeLblPill.TextColor3 = ActiveMode.color
		sessionTitleLbl.Text = getCurrentSession(ActiveModelKey).title or "New chat"
		webBtn.Visible = ActiveModelKey == "pro"
		rebuildModeDropdown()
	end

	modelPill.MouseButton1Click:Connect(function() modelDropdown.Visible = not modelDropdown.Visible end)
	modePill.MouseButton1Click:Connect(function() if GUI.modeDropdown then GUI.modeDropdown.Visible = not GUI.modeDropdown.Visible end end)

	-- SHARE DROPDOWN
	local shareDropdown = Instance.new("Frame", topbar)
	shareDropdown.Size = UDim2.new(0, 160, 0, 70)
	shareDropdown.Position = UDim2.new(1, -170, 1, 4)
	shareDropdown.BackgroundColor3 = C.bgSettings
	shareDropdown.BorderSizePixel = 0
	shareDropdown.Visible = false
	shareDropdown.ZIndex = 30
	mkCorner(shareDropdown, 8)
	mkStroke(shareDropdown)
	mkList(shareDropdown, nil, 2)
	mkPad(shareDropdown, 4, 4, 4, 4)

	local shareJsonBtn = mkBtn(shareDropdown, "📋 Copy as JSON", UDim2.new(1,-8,0,28), C.bgHover, C.txtSecondary, 11)
	mkCorner(shareJsonBtn, 5)
	shareJsonBtn.ZIndex = 31
	local shareTextBtn = mkBtn(shareDropdown, "📄 Copy as Text", UDim2.new(1,-8,0,28), C.bgHover, C.txtSecondary, 11)
	mkCorner(shareTextBtn, 5)
	shareTextBtn.ZIndex = 31

	shareBtn.MouseButton1Click:Connect(function() shareDropdown.Visible = not shareDropdown.Visible end)
	shareJsonBtn.MouseButton1Click:Connect(function()
		local session = getCurrentSession(ActiveModelKey)
		local str = compressSession(session, ActiveModelKey)
		if str and setclipboard then
			setclipboard(str)
			shareBtn.Text = "✓ Copied!"
			task.wait(1.5) shareBtn.Text = "⬆ Share"
		end
		shareDropdown.Visible = false
	end)
	shareTextBtn.MouseButton1Click:Connect(function()
		local session = getCurrentSession(ActiveModelKey)
		local str = compressSessionText(session)
		if setclipboard then
			setclipboard(str)
			shareBtn.Text = "✓ Copied!"
			task.wait(1.5) shareBtn.Text = "⬆ Share"
		end
		shareDropdown.Visible = false
	end)

	-- SETTINGS PANEL
	local settingsPanel = Instance.new("Frame", main)
	settingsPanel.Size = UDim2.new(1, -200, 1, 0)
	settingsPanel.Position = UDim2.new(0, 200, 0, 0)
	settingsPanel.BackgroundColor3 = C.bg
	settingsPanel.BorderSizePixel = 0
	settingsPanel.Visible = false
	settingsPanel.ZIndex = 10
	GUI.settingsPanel = settingsPanel

	local stHeader = Instance.new("Frame", settingsPanel)
	stHeader.Size = UDim2.new(1, 0, 0, 44)
	stHeader.BackgroundTransparency = 1
	mkPad(stHeader, 0, 0, 16, 16)
	local stTitle = mkLabel(stHeader, "Settings", 15, C.txtPrimary, Enum.Font.GothamBold)
	stTitle.Size = UDim2.new(0.6, 0, 1, 0)
	local stClose = mkBtn(stHeader, "✕", UDim2.new(0, 26, 0, 26), C.bgHover, C.txtSecondary, 11)
	stClose.Position = UDim2.new(1, -30, 0.5, -13)
	mkCorner(stClose, 5)
	stClose.MouseButton1Click:Connect(function() settingsPanel.Visible = false end)

	local stDivider = Instance.new("Frame", settingsPanel)
	stDivider.Size = UDim2.new(1, 0, 0, 1)
	stDivider.Position = UDim2.new(0, 0, 0, 44)
	stDivider.BackgroundColor3 = C.stroke
	stDivider.BorderSizePixel = 0

	local stScroll = Instance.new("ScrollingFrame", settingsPanel)
	stScroll.Size = UDim2.new(1, 0, 1, -46)
	stScroll.Position = UDim2.new(0, 0, 0, 46)
	stScroll.BackgroundTransparency = 1
	stScroll.BorderSizePixel = 0
	stScroll.ScrollBarThickness = 3
	stScroll.ScrollBarImageColor3 = C.scrollbar
	stScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	stScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	mkList(stScroll, nil, 0)
	mkPad(stScroll, 8, 16, 16, 16)

	local function stSection(title)
		local f = Instance.new("Frame", stScroll)
		f.Size = UDim2.new(1, 0, 0, 0)
		f.AutomaticSize = Enum.AutomaticSize.Y
		f.BackgroundTransparency = 1
		mkList(f, nil, 6)
		local lbl = mkLabel(f, title, 10, C.txtMuted, Enum.Font.GothamBold)
		lbl.Size = UDim2.new(1, 0, 0, 18)
		return f
	end

	local function stRow(parent, label, content)
		local row = Instance.new("Frame", parent)
		row.Size = UDim2.new(1, 0, 0, 36)
		row.BackgroundTransparency = 1
		mkList(row, Enum.FillDirection.Horizontal, 8)
		local lbl = mkLabel(row, label, 12, C.txtSecondary)
		lbl.Size = UDim2.new(0.45, 0, 1, 0)
		content.Parent = row
		content.Size = UDim2.new(0.55, 0, 0, 28)
		return row
	end

	local function stTextBox(placeholder, default)
		local box = Instance.new("TextBox")
		box.BackgroundColor3 = C.bgInput
		box.PlaceholderText = placeholder or ""
		box.Text = default or ""
		box.TextColor3 = C.txtPrimary
		box.PlaceholderColor3 = C.txtMuted
		box.Font = Enum.Font.Gotham
		box.TextSize = 12
		box.BorderSizePixel = 0
		box.ClearTextOnFocus = false
		mkCorner(box, 5)
		return box
	end

	local spSection = stSection("SYSTEM PROMPT")
	local spBox = Instance.new("TextBox", spSection)
	spBox.Size = UDim2.new(1, 0, 0, 56)
	spBox.BackgroundColor3 = C.bgInput
	spBox.Text = GlobalSettings.systemPrompt
	spBox.PlaceholderText = "e.g. act like a chill friend who plays roblox"
	spBox.TextColor3 = C.txtPrimary
	spBox.PlaceholderColor3 = C.txtMuted
	spBox.Font = Enum.Font.Gotham
	spBox.TextSize = 12
	spBox.BorderSizePixel = 0
	spBox.ClearTextOnFocus = false
	spBox.TextWrapped = true
	spBox.MultiLine = true
	spBox.TextXAlignment = Enum.TextXAlignment.Left
	spBox.TextYAlignment = Enum.TextYAlignment.Top
	mkCorner(spBox, 6)
	mkStroke(spBox)
	spBox:GetPropertyChangedSignal("Text"):Connect(function() GlobalSettings.systemPrompt = spBox.Text end)

	local langSection = stSection("LANGUAGE LOCK")
	local langs = {"english","spanish","portuguese"}
	for _, lang in ipairs(langs) do
		local lBtn = mkBtn(langSection, lang:sub(1,1):upper()..lang:sub(2), UDim2.new(1,0,0,28), C.bgHover, C.txtSecondary, 12)
		mkCorner(lBtn, 5)
		if lang == GlobalSettings.language then lBtn.TextColor3 = C.accent lBtn.BackgroundColor3 = C.bgInput end
		lBtn.MouseButton1Click:Connect(function()
			GlobalSettings.language = lang
			for _, child in ipairs(langSection:GetChildren()) do
				if child:IsA("TextButton") then child.TextColor3 = C.txtSecondary child.BackgroundColor3 = C.bgHover end
			end
			lBtn.TextColor3 = C.accent lBtn.BackgroundColor3 = C.bgInput
		end)
	end

	local alertSection = stSection("ALERT KEYWORDS")
	local alertBox = stTextBox("keyword to watch...", "")
	alertBox.Parent = alertSection
	alertBox.Size = UDim2.new(1, 0, 0, 28)
	mkStroke(alertBox)
	local alertAddBtn = mkBtn(alertSection, "+ Add Keyword", UDim2.new(1,0,0,28), C.accent, C.white, 11)
	mkCorner(alertAddBtn, 5)
	local alertListFrame = Instance.new("Frame", alertSection)
	alertListFrame.Size = UDim2.new(1, 0, 0, 0)
	alertListFrame.AutomaticSize = Enum.AutomaticSize.Y
	alertListFrame.BackgroundTransparency = 1
	mkList(alertListFrame, nil, 3)
	GUI.alertListFrame = alertListFrame
	alertAddBtn.MouseButton1Click:Connect(function()
		local kw = alertBox.Text
		if #kw < 1 then return end
		t_insert(GlobalSettings.alertKeywords, kw)
		alertBox.Text = ""
		local kwBtn = mkBtn(alertListFrame, "✕ " .. kw, UDim2.new(1,0,0,24), C.bgHover, C.txtSecondary, 11)
		mkCorner(kwBtn, 4)
		kwBtn.MouseButton1Click:Connect(function()
			for i, v in ipairs(GlobalSettings.alertKeywords) do
				if v == kw then t_remove(GlobalSettings.alertKeywords, i) break end
			end
			kwBtn:Destroy()
		end)
	end)

	local epSection = stSection("EFFECTIVE PARAMETERS")
	local epSliderFrame = Instance.new("Frame", epSection)
	epSliderFrame.Size = UDim2.new(1, 0, 0, 36)
	epSliderFrame.BackgroundColor3 = C.bgInput
	epSliderFrame.BorderSizePixel = 0
	mkCorner(epSliderFrame, 6)
	local epTrack = Instance.new("Frame", epSliderFrame)
	epTrack.Size = UDim2.new(1, -16, 0, 4)
	epTrack.Position = UDim2.new(0, 8, 0.5, -2)
	epTrack.BackgroundColor3 = C.stroke
	epTrack.BorderSizePixel = 0
	mkCorner(epTrack, 2)
	local epFill = Instance.new("Frame", epTrack)
	epFill.Size = UDim2.new(0.4, 0, 1, 0)
	epFill.BackgroundColor3 = C.accent
	epFill.BorderSizePixel = 0
	mkCorner(epFill, 2)
	local epHandle = Instance.new("TextButton", epTrack)
	epHandle.Size = UDim2.new(0, 14, 0, 14)
	epHandle.Position = UDim2.new(0.4, -7, 0.5, -7)
	epHandle.BackgroundColor3 = C.white
	epHandle.Text = ""
	epHandle.BorderSizePixel = 0
	mkCorner(epHandle, 99)
	local epValueLbl = mkLabel(epSection, s_format("EP: %d", getEP(ActiveModelKey)), 10, C.txtMuted)
	epValueLbl.Size = UDim2.new(1, 0, 0, 14)
	GUI.epValueLbl = epValueLbl

	local epDragging = false
	epHandle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then epDragging = true end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then epDragging = false end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if epDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local trackAbsPos = epTrack.AbsolutePosition.X
			local trackAbsSize = epTrack.AbsoluteSize.X
			local ratio = m_clamp((inp.Position.X - trackAbsPos) / trackAbsSize, 0, 1)
			epFill.Size = UDim2.new(ratio, 0, 1, 0)
			epHandle.Position = UDim2.new(ratio, -7, 0.5, -7)
			local mdl = Models[ActiveModelKey]
			local ep = m_floor(mdl.effectiveParamsMin + ratio * (mdl.effectiveParamsMax - mdl.effectiveParamsMin))
			Brains[ActiveModelKey].EffectiveParams = ep
			epValueLbl.Text = s_format("EP: %d", ep)
		end
	end)

	local lrSection = stSection("LEARNING RATE")
	local lrSliderFrame = Instance.new("Frame", lrSection)
	lrSliderFrame.Size = UDim2.new(1, 0, 0, 36)
	lrSliderFrame.BackgroundColor3 = C.bgInput
	lrSliderFrame.BorderSizePixel = 0
	mkCorner(lrSliderFrame, 6)
	local lrTrack = Instance.new("Frame", lrSliderFrame)
	lrTrack.Size = UDim2.new(1, -16, 0, 4)
	lrTrack.Position = UDim2.new(0, 8, 0.5, -2)
	lrTrack.BackgroundColor3 = C.st