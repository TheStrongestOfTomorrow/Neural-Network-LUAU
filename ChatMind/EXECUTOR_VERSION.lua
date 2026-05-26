-- ============================================================================
-- ChatMind - Single File Executor Version
-- Copy ALL of this code and paste it into your executor
-- Press RightCtrl to toggle the chat window
-- ============================================================================

if getgenv().ChatMindLoaded then warn("[ChatMind] Already loaded!"); return end
getgenv().ChatMindLoaded = true

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Utils
local Utils = {}
Utils.StopWords = {["the"]=true,["a"]=true,["an"]=true,["is"]=true,["it"]=true,["in"]=true,["on"]=true,["at"]=true,["to"]=true,["of"]=true,["and"]=true,["or"]=true,["but"]=true}
function Utils.tokenize(text, cap, removeStop)
    local tokens = {}
    local cleaned = string.lower(string.gsub(text or "", "[%p%c]", " "))
    local count = 0
    for w in string.gmatch(cleaned, "%S+") do
        if not removeStop or not Utils.StopWords[w] then
            table.insert(tokens, w)
            count = count + 1
            if cap and count >= cap then break end
        end
    end
    return tokens
end
function Utils.clamp(v, mn, mx) return math.max(mn, math.min(mx, v)) end

-- Models
local Models = {
    flash = {name="Flash", tag="FLASH", maxTokens=15, markovOrder=1, learningRate=0.05, topK=40, nucleus=0.9, memorySlots=8, modes={markov={temperature=0.8, bigramBoost=false, trigramBoost=false}}},
    deepthink = {name="DeepThink", tag="DEEP", maxTokens=30, markovOrder=2, learningRate=0.03, topK=60, nucleus=0.95, memorySlots=20, modes={deepthink={temperature=0.5, bigramBoost=true, trigramBoost=true}}},
    pro = {name="Pro", tag="PRO", maxTokens=40, markovOrder=2, learningRate=0.04, topK=80, nucleus=0.97, memorySlots=30, modes={lightning={temperature=0.7, bigramBoost=true, trigramBoost=true}}}
}

-- Markov
local Markov = {}
Markov.__index = Markov
function Markov.new(cfg)
    local self = setmetatable({}, Markov)
    self.unigram, self.bigram, self.trigram, self.config = {}, {}, {}, cfg
    return self
end
function Markov:learn(text, lr)
    local tokens = Utils.tokenize(text)
    if #tokens < 2 then return end
    local inc = Utils.clamp(math.ceil((lr or 0.05) * 20), 1, 100)
    for i = 1, #tokens-1 do
        local k = tokens[i]
        if not self.unigram[k] then self.unigram[k] = {} end
        self.unigram[k][tokens[i+1]] = (self.unigram[k][tokens[i+1]] or 0) + inc
    end
    if self.config.markovOrder >= 2 then
        for i = 1, #tokens-2 do
            local k = tokens[i].."_"..tokens[i+1]
            if not self.bigram[k] then self.bigram[k] = {} end
            self.bigram[k][tokens[i+2]] = (self.bigram[k][tokens[i+2]] or 0) + inc
        end
        for i = 1, #tokens-3 do
            local k = tokens[i].."_"..tokens[i+1].."_"..tokens[i+2]
            if not self.trigram[k] then self.trigram[k] = {} end
            self.trigram[k][tokens[i+3]] = (self.trigram[k][tokens[i+3]] or 0) + inc
        end
    end
end
function Markov:sample(nexts, temp, topK)
    if not nexts then return nil end
    temp = temp or 1.0
    local pool, weights, total = {}, {}, 0
    for word, count in pairs(nexts) do
        local w = count ^ (1/temp)
        table.insert(pool, word); table.insert(weights, w); total = total + w
    end
    if total == 0 then return nil end
    if topK and topK > 0 and #pool > topK then
        local paired = {}
        for i, w in ipairs(weights) do table.insert(paired, {w=w, p=pool[i]}) end
        table.sort(paired, function(a,b) return a.w > b.w end)
        pool, weights, total = {}, {}, 0
        for i = 1, math.min(topK, #paired) do
            table.insert(pool, paired[i].p); table.insert(weights, paired[i].w); total = total + paired[i].w
        end
    end
    local r = math.random() * total
    local cumul = 0
    for i, w in ipairs(weights) do
        cumul = cumul + w
        if r <= cumul then return pool[i] end
    end
    return pool[#pool]
end
function Markov:generate(seed, length, mode)
    length = length or 8
    local temp = (mode and mode.temperature) or 0.8
    local useBi = mode and mode.bigramBoost
    local useTri = mode and mode.trigramBoost
    local tokens = Utils.tokenize(seed)
    if #tokens < 1 then return "..." end
    local t1 = tokens[#tokens-1]
    local cur = tokens[#tokens]
    if not cur or not self.unigram[cur] then
        local keys = {}
        for k in pairs(self.unigram) do table.insert(keys, k) end
        if #keys == 0 then return "..." end
        cur = keys[math.random(1, #keys)]; t1 = nil
    end
    local result = {cur}
    for _ = 1, length do
        local chosen = nil
        if useTri and t1 and self.trigram[t1.."_"..cur] then
            chosen = self:sample(self.trigram[t1.."_"..cur], temp, self.config.topK)
        elseif not chosen and useBi and t1 and self.bigram[t1.."_"..cur] then
            chosen = self:sample(self.bigram[t1.."_"..cur], temp, self.config.topK)
        elseif not chosen then
            chosen = self:sample(self.unigram[cur], temp, self.config.topK)
        end
        if not chosen then break end
        table.insert(result, chosen); t1 = cur; cur = chosen
    end
    return table.concat(result, " ")
end

-- Bayes
local Bayes = {}
Bayes.__index = Bayes
function Bayes.new()
    local self = setmetatable({}, Bayes)
    self.classCounts, self.wordCounts, self.totalDocs, self.vocab = {}, {}, 0, {}
    return self
end
function Bayes:learn(text, class)
    local tokens = Utils.tokenize(text, nil, true)
    self.classCounts[class] = (self.classCounts[class] or 0) + 1
    self.totalDocs = self.totalDocs + 1
    if not self.wordCounts[class] then self.wordCounts[class] = {} end
    for _, w in ipairs(tokens) do
        self.wordCounts[class][w] = (self.wordCounts[class][w] or 0) + 1
        self.vocab[w] = true
    end
end
function Bayes:classify(text)
    local tokens = Utils.tokenize(text, nil, true)
    local vocabSize = 0
    for _ in pairs(self.vocab) do vocabSize = vocabSize + 1 end
    if vocabSize == 0 then return "general" end
    local bestClass, bestScore = "general", -math.huge
    for class, count in pairs(self.classCounts) do
        local score = math.log(count / self.totalDocs)
        local wc = self.wordCounts[class] or {}
        local total = 0
        for _, c in pairs(wc) do total = total + c end
        for _, w in ipairs(tokens) do
            score = score + math.log(((wc[w] or 0) + 1) / (total + vocabSize))
        end
        if score > bestScore then bestScore = score; bestClass = class end
    end
    return bestClass
end

-- Storage
local Storage = {}
function Storage.save(data, key)
    if not writefile then return false end
    local ok, json = pcall(game:GetService("HttpService").JSONEncode, game:GetService("HttpService"), data)
    if not ok then return false end
    pcall(writefile, "ChatMind_"..key..".json", json)
    return true
end
function Storage.load(key)
    if not readfile or not isfile then return nil end
    if not isfile("ChatMind_"..key..".json") then return nil end
    local ok, content = pcall(readfile, "ChatMind_"..key..".json")
    if not ok then return nil end
    local ok, data = pcall(game:GetService("HttpService").JSONDecode, game:GetService("HttpService"), content)
    return ok and data or nil
end

-- Brain
local Brain = {}
Brain.__index = Brain
function Brain.new(modelKey)
    local self = setmetatable({}, Brain)
    self.modelKey = modelKey or "flash"
    self.config = Models[self.modelKey]
    self.markov = Markov.new(self.config)
    self.bayes = Bayes.new()
    self.memory, self.sessions, self.currentSessionId = {}, {}, nil
    self.experts = {
        greeting = {keywords = {"hi","hello","hey","sup","yo"}, responses = {"Hello!", "Hey there!", "Hi! How can I help?"}},
        farewell = {keywords = {"bye","goodbye","see ya","later"}, responses = {"Bye!", "See you later!", "Take care!"}},
        question = {keywords = {"what","why","how","when","where"}, responses = {}},
    }
    return self
end
function Brain:learn(text, intent)
    self.markov:learn(text, self.config.learningRate)
    self.bayes:learn(text, intent or "general")
end
function Brain:respond(input, mode)
    mode = mode or self.config.modes[self.config.defaultMode or next(self.config.modes)]
    local inputLower = string.lower(input)
    for _, expert in pairs(self.experts) do
        for _, kw in ipairs(expert.keywords) do
            if string.find(inputLower, kw) and #expert.responses > 0 then
                return expert.responses[math.random(1, #expert.responses)]
            end
        end
    end
    local response = self.markov:generate(input, self.config.maxTokens, mode)
    if not response or #response < 3 then
        local fallbacks = {"Interesting!", "Tell me more.", "I see.", "Hmm, go on."}
        response = fallbacks[math.random(1, #fallbacks)]
    end
    table.insert(self.memory, {input=input, output=response})
    while #self.memory > self.config.memorySlots do table.remove(self.memory, 1) end
    return response
end

-- State
local ActiveModel = "flash"
local brain = Brain.new(ActiveModel)
local gui = {}

-- Seed data
local seeds = {
    {t="hello hi hey greetings good morning", c="greeting"},
    {t="bye goodbye see you later farewell", c="farewell"},
    {t="thank thanks thank you appreciate", c="gratitude"},
    {t="yes yeah yup sure okay alright", c="affirmation"},
    {t="no nope nah not really", c="negation"},
    {t="how are you hows it going whats up", c="question"},
}
for _, s in ipairs(seeds) do brain:learn(s.t, s.c) end

-- GUI
local function addMessage(text, role)
    if not gui.chatScroll then return end
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 0); frame.AutomaticSize = Enum.AutomaticSize.Y; frame.BackgroundTransparency = 1
    local bg = Instance.new("Frame", frame)
    bg.BackgroundColor3 = role == "bot" and Color3.fromRGB(38,38,38) or Color3.fromRGB(25,195,125)
    bg.BorderSizePixel = 0; bg.Size = UDim2.new(0.85, 0, 1, 0); bg.Position = UDim2.new(role=="bot" and 0 or 0.15,0,0,0)
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,-12,1,-8); lbl.Position = UDim2.new(0,6,0,4); lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = role=="bot" and Color3.fromRGB(200,220,255) or Color3.new(1,1,1)
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13; lbl.TextWrapped = true
    lbl.TextXAlignment = role=="bot" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    frame.Parent = gui.chatScroll
    gui.chatScroll.CanvasSize = UDim2.new(0,0,0,gui.chatScroll.UIListLayout.AbsoluteContentSize.Y+16)
    gui.chatScroll:ScrollBottom()
end

local function buildGUI()
    local screen = Instance.new("ScreenGui"); screen.Name = "ChatMind"; screen.ResetOnSpawn = false; screen.Parent = CoreGui
    local main = Instance.new("Frame", screen)
    main.Size = UDim2.new(0,400,0,300); main.Position = UDim2.new(0.5,-200,0.5,-150)
    main.BackgroundColor3 = Color3.fromRGB(31,31,31); main.BorderSizePixel = 0; main.Visible = false
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(55,55,55); stroke.Thickness = 1
    
    local titleBar = Instance.new("Frame", main); titleBar.Size = UDim2.new(1,0,0,40); titleBar.BackgroundTransparency = 1
    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1,-60,1,0); title.BackgroundTransparency = 1
    title.Text = "ChatMind - "..Models[ActiveModel].name; title.TextColor3 = Color3.new(236/255,236/255,241/255)
    title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.TextXAlignment = Enum.TextXAlignment.Left
    
    local modelBtn = Instance.new("TextButton", titleBar)
    modelBtn.Size = UDim2.new(0,50,0,30); modelBtn.Position = UDim2.new(1,-55,0.5,-15)
    modelBtn.BackgroundColor3 = Color3.fromRGB(38,38,38); modelBtn.Text = Models[ActiveModel].tag
    modelBtn.TextColor3 = Color3.new(236/255,236/255,241/255); modelBtn.Font = Enum.Font.GothamBold; modelBtn.TextSize = 11
    Instance.new("UICorner", modelBtn).CornerRadius = UDim.new(0,5)
    
    local chatScroll = Instance.new("ScrollingFrame", main)
    chatScroll.Size = UDim2.new(1,-16,1,-92); chatScroll.Position = UDim2.new(0,8,0,44)
    chatScroll.BackgroundTransparency = 1; chatScroll.BorderSizePixel = 0
    chatScroll.ScrollBarThickness = 4; chatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local listLayout = Instance.new("UIListLayout", chatScroll); listLayout.Padding = UDim.new(0,8)
    
    local inputFrame = Instance.new("Frame", main)
    inputFrame.Size = UDim2.new(1,-16,0,40); inputFrame.Position = UDim2.new(0,8,1,-48)
    inputFrame.BackgroundColor3 = Color3.fromRGB(38,38,38)
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0,6)
    
    local textBox = Instance.new("TextBox", inputFrame)
    textBox.Size = UDim2.new(1,-50,1,0); textBox.BackgroundTransparency = 1
    textBox.Text = ""; textBox.PlaceholderText = "Type a message..."
    textBox.TextColor3 = Color3.new(236/255,236/255,241/255); textBox.Font = Enum.Font.Gotham; textBox.TextSize = 13
    textBox.ClearTextOnFocus = false
    
    local sendBtn = Instance.new("TextButton", inputFrame)
    sendBtn.Size = UDim2.new(0,40,1,-8); sendBtn.Position = UDim2.new(1,-44,0.5,-16)
    sendBtn.BackgroundColor3 = Color3.fromRGB(25,195,125); sendBtn.Text = "➤"
    sendBtn.TextColor3 = Color3.new(1,1,1); sendBtn.Font = Enum.Font.GothamBold; sendBtn.TextSize = 16
    Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0,5)
    
    gui.main, gui.chatScroll, gui.textBox, gui.modelBtn = main, chatScroll, textBox, modelBtn
    
    local function send()
        local text = textBox.Text
        if #text > 0 then
            addMessage(text, "user")
            local mode = Models[ActiveModel].modes[Models[ActiveModel].defaultMode or next(Models[ActiveModel].modes)]
            local response = brain:respond(text, mode)
            addMessage(response, "bot")
            textBox.Text = ""
            Storage.save({unigram=brain.markov.unigram, bigram=brain.markov.bigram, trigram=brain.markov.trigram}, ActiveModel)
        end
    end
    
    sendBtn.MouseButton1Click:Connect(send)
    textBox.FocusLost:Connect(function(ep) if ep then send() end end)
    
    modelBtn.MouseButton1Click:Connect(function()
        local keys = {"flash","deepthink","pro"}
        local idx = 1
        for i,k in ipairs(keys) do if k==ActiveModel then idx=i break end end
        ActiveModel = keys[(idx % #keys)+1]
        brain = Brain.new(ActiveModel)
        gui.modelBtn.Text = Models[ActiveModel].tag
        local d = Storage.load(ActiveModel)
        if d then
            for k,v in pairs(d.unigram or {}) do brain.markov.unigram[k]=v end
            for k,v in pairs(d.bigram or {}) do brain.markov.bigram[k]=v end
            for k,v in pairs(d.trigram or {}) do brain.markov.trigram[k]=v end
        end
    end)
    
    UserInputService.InputBegan:Connect(function(inp, proc)
        if proc then return end
        if inp.KeyCode == Enum.KeyCode.RightControl then main.Visible = not main.Visible end
    end)
end

-- Init
buildGUI()
local d = Storage.load(ActiveModel)
if d then
    for k,v in pairs(d.unigram or {}) do brain.markov.unigram[k]=v end
    for k,v in pairs(d.bigram or {}) do brain.markov.bigram[k]=v end
    for k,v in pairs(d.trigram or {}) do brain.markov.trigram[k]=v end
    print("[ChatMind] Data loaded!")
else
    print("[ChatMind] Initialized!")
end
print("[ChatMind] Ready! Press RightCtrl to toggle chat")
