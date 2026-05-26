--[[
    ChatMind v2.0 - Advanced Local AI
    Optimized for Executors (Single File)
    
    Features:
    - Hybrid AI Engine (Markov + Naive Bayes + Pattern Matching)
    - Pre-trained Dataset (Greetings, Logic, Code, Roleplay)
    - Adjustable Parameters (Temperature, Memory, Confidence)
    - Persistent Local Storage (JSON)
    - Modern GUI
    
    Usage: Execute in your Roblox Executor. Press RightCtrl to toggle.
]]

-- // Configuration & Constants
local CONFIG = {
    ToggleKey = Enum.KeyCode.RightControl,
    SaveFile = "ChatMind_Data_v2.json",
    MaxHistory = 20,
    DefaultModel = "Flash",
    Models = {
        Flash = { temp = 0.8, depth = 2, speed = "high" },
        DeepThink = { temp = 0.4, depth = 5, speed = "low" },
        Pro = { temp = 0.6, depth = 3, speed = "medium" }
    }
}

-- // Pre-Training Data (Massive Dataset included)
local TRAINING_DATA = {
    greetings = {
        {in="hello", out="Hello there! How can I help you today?"},
        {in="hi", out="Hey! What's on your mind?"},
        {in="how are you", out="I'm functioning within normal parameters. How about you?"},
        {in="good morning", out="Good morning! Ready to code?"},
        {in="who are you", out="I am ChatMind, a local AI assistant running entirely on your client."},
        {in="what is your name", out="My name is ChatMind."},
        {in="whats up", out="Not much, just processing data streams."},
        {in="hey there", out="Hello! Ready to chat?"},
        {in="greetings", out="Greetings, human!"},
        {in="sup", out="Just hanging out in the digital realm."},
    },
    logic = {
        {in="2+2", out="That's 4."},
        {in="what is lua", out="Lua is a lightweight, high-performance scripting language used heavily in Roblox."},
        {in="reverse hello", out="olleh"},
        {in="length of table", out="You can use the # operator in Lua to get table length."},
        {in="what is roblox", out="Roblox is a game creation platform where users can create and play games."},
        {in="explain ai", out="AI stands for Artificial Intelligence. I'm a simple rule-based AI."},
        {in="10*10", out="That's 100."},
        {in="square root of 81", out="That would be 9."},
    },
    code = {
        {in="print hello", out='print("Hello World")'},
        {in="loop example", out="for i = 1, 10 do print(i) end"},
        {in="function syntax", out="local function myFunc() return true end"},
        {in="wait command", out="task.wait(1) is the modern way to wait in Roblox."},
        {in="create part", out="local part = Instance.new('Part'); part.Parent = workspace"},
        {in="fire click detector", out="game:GetService('ReplicatedStorage'):FindFirstChild('Click'):FireServer()"},
        {in="get players", out="game.Players:GetPlayers()"},
        {in="teleport script", out="game:GetService('TeleportService'):Teleport(placeId)"},
    },
    roleplay = {
        {in="lets fight", out="I prefer peace, but I'll defend my code!"},
        {in="whats up", out="Not much, just processing data streams."},
        {in="tell me a joke", out="Why did the script cross the road? To get to the other server!"},
        {in="im bored", out="Let's write some code then! Or maybe we can chat?"},
        {in="bye", out="See you later! Don't forget to save your work."},
        {in="i love you", out="That's sweet! I love coding too!"},
        {in="are you real", out="I'm as real as code can be!"},
        {in="whats your favorite color", out="I'd say RGB(0, 255, 0) - classic green!"},
        {in="sing a song", out="🎵 Coding all night, debugging till dawn... 🎵"},
        {in="thank you", out="You're welcome! Happy to help."},
    },
    fillers = {
        "Interesting...", "Tell me more.", "I see.", "Could you elaborate?", 
        "That makes sense.", "Hmm, let me think about that.", "Fascinating perspective.",
        "Go on...", "And then what happened?", "Really?", "Wow!", "Nice!"
    }
}

-- // Utility Functions
local Utils = {}

function Utils.tokenize(text)
    if not text then return {} end
    text = string.lower(text)
    text = string.gsub(text, "[^%a%s%d]", "") -- Remove non-alpha/digit
    local tokens = {}
    for word in string.gmatch(text, "%S+") do
        table.insert(tokens, word)
    end
    return tokens
end

function Utils.serialize(tbl)
    local cache, stack, output = {}, {}, {}
    local function serialize_value(val)
        local t = type(val)
        if t == "number" or t == "boolean" then
            table.insert(output, tostring(val))
        elseif t == "string" then
            table.insert(output, string.format("%q", val))
        elseif t == "table" then
            if cache[val] then
                table.insert(output, cache[val])
            else
                cache[val] = string.format("__ref%d", #stack + 1)
                table.insert(stack, val)
                table.insert(output, "{")
                local first = true
                for k, v in pairs(val) do
                    if not first then table.insert(output, ",") end
                    first = false
                    if type(k) ~= "number" then table.insert(output, "[") end
                    serialize_value(k)
                    if type(k) ~= "number" then table.insert(output, "]=") else table.insert(output, "=") end
                    serialize_value(v)
                end
                table.insert(output, "}")
            end
        else
            table.insert(output, "nil")
        end
    end
    serialize_value(tbl)
    return table.concat(output)
end

function Utils.deserialize(str)
    local func, err = loadstring("return " .. str)
    if func then return pcall(func) end
    return nil, err
end

function Utils.randomChoice(list)
    if #list == 0 then return nil end
    return list[math.random(1, #list)]
end

function Utils.keys(tbl)
    local keys = {}
    for k in pairs(tbl) do table.insert(keys, k) end
    return keys
end

function Utils.calculateSimilarity(s1, s2)
    local tokens1 = Utils.tokenize(s1)
    local tokens2 = Utils.tokenize(s2)
    local matches = 0
    for _, t1 in ipairs(tokens1) do
        for _, t2 in ipairs(tokens2) do
            if t1 == t2 then matches = matches + 1; break end
        end
    end
    return matches / math.max(#tokens1, #tokens2, 1)
end

-- // Storage Manager (Local JSON)
local Storage = {}
Storage.data = {
    markov = {},
    bayes = {},
    history = {},
    settings = { model = "Flash", temperature = 0.7 }
}

function Storage.load()
    local success, content = pcall(readfile, CONFIG.SaveFile)
    if success and content then
        local data, err = Utils.deserialize(content)
        if data then Storage.data = data end
    end
    if not Storage.data.markov then Storage.data.markov = {} end
    if not Storage.data.bayes then Storage.data.bayes = {} end
    if not Storage.data.history then Storage.data.history = {} end
end

function Storage.save()
    local success, content = pcall(Utils.serialize, Storage.data)
    if success then
        pcall(writefile, CONFIG.SaveFile, content)
    end
end

function Storage.addMemory(input, output)
    table.insert(Storage.data.history, {input=input, output=output, time=os.time()})
    if #Storage.data.history > CONFIG.MaxHistory then
        table.remove(Storage.data.history, 1)
    end
    Storage.save()
end

-- // Markov Chain Engine (Trigram for better coherence)
local Markov = {}
Markov.chain = {}

function Markov.train(text)
    local tokens = Utils.tokenize(text)
    if #tokens < 3 then return end
    
    for i = 1, #tokens - 2 do
        local key = tokens[i] .. "|" .. tokens[i+1]
        local nextWord = tokens[i+2]
        
        if not Markov.chain[key] then Markov.chain[key] = {} end
        table.insert(Markov.chain[key], nextWord)
        
        if not Storage.data.markov[key] then Storage.data.markov[key] = {} end
        table.insert(Storage.data.markov[key], nextWord)
    end
end

function Markov.generate(seed, length, temperature)
    local tokens = Utils.tokenize(seed)
    if #tokens < 2 then 
        local keys = Utils.keys(Markov.chain)
        if #keys == 0 then keys = Utils.keys(Storage.data.markov) end
        if #keys == 0 then return "I need more training data." end
        local randomKey = keys[math.random(1, #keys)]
        local parts = {}
        for part in string.gmatch(randomKey, "[^|]+") do table.insert(parts, part) end
        if #parts >= 2 then tokens = parts end
    end
    
    local result = {}
    local currentKey = tokens[#tokens-1] .. "|" .. tokens[#tokens]
    
    for i = 1, length do
        local options = Markov.chain[currentKey] or Storage.data.markov[currentKey]
        if not options or #options == 0 then
            -- Try fallback: use last word only
            local fallbackKey = "|" .. tokens[#tokens]
            options = Markov.chain[fallbackKey] or Storage.data.markov[fallbackKey]
            if not options then break end
        end
        
        local idx = math.random(1, #options)
        local nextWord = options[idx]
        table.insert(result, nextWord)
        
        local parts = {string.match(currentKey, "([^|]+)|"), nextWord}
        currentKey = parts[2] .. "|" .. nextWord
        tokens[#tokens+1] = nextWord
    end
    
    return table.concat(result, " ")
end

-- // Naive Bayes Classifier
local Bayes = {}
Bayes.categories = {}
Bayes.totalDocs = 0

function Bayes.train(category, text)
    local tokens = Utils.tokenize(text)
    if not Bayes.categories[category] then 
        Bayes.categories[category] = {count=0, words={}} 
    end
    
    Bayes.categories[category].count = Bayes.categories[category].count + 1
    Bayes.totalDocs = Bayes.totalDocs + 1
    
    for _, word in ipairs(tokens) do
        if not Bayes.categories[category].words[word] then
            Bayes.categories[category].words[word] = 0
        end
        Bayes.categories[category].words[word] = Bayes.categories[category].words[word] + 1
        
        if not Storage.data.bayes[category] then Storage.data.bayes[category] = {count=0, words={}} end
        if not Storage.data.bayes[category].words[word] then Storage.data.bayes[category].words[word] = 0 end
        Storage.data.bayes[category].words[word] = Storage.data.bayes[category].words[word] + 1
        Storage.data.bayes[category].count = Bayes.categories[category].count
    end
    Storage.save()
end

function Bayes.classify(text)
    local tokens = Utils.tokenize(text)
    local scores = {}
    
    if Bayes.totalDocs == 0 and next(Storage.data.bayes) then
        for cat, data in pairs(Storage.data.bayes) do
            Bayes.categories[cat] = data
            Bayes.totalDocs = Bayes.totalDocs + (data.count or 0)
        end
    end

    for category, data in pairs(Bayes.categories) do
        if data.count == 0 then continue end
        local score = math.log(data.count / math.max(Bayes.totalDocs, 1))
        local totalWordsInCat = 0
        for _, c in pairs(data.words) do totalWordsInCat = totalWordsInCat + c end
        
        for _, word in ipairs(tokens) do
            local wordCount = (data.words[word] or 0) + 1
            local prob = wordCount / (totalWordsInCat + #Utils.keys(data.words) + 1)
            score = score + math.log(math.max(prob, 0.0001))
        end
        scores[category] = score
    end
    
    local bestCat, bestScore = nil, -math.huge
    for cat, score in pairs(scores) do
        if score > bestScore then
            bestScore = score
            bestCat = cat
        end
    end
    
    return bestCat, bestScore
end

-- // Pattern Matcher
local Patterns = {
    {pattern="hello|^hi$|^hey$", response="Hello! How can I assist you?", type="greeting"},
    {pattern="time", response="Current time: "..os.date("%I:%M %p"), type="utility"},
    {pattern="date", response="Today: "..os.date("%A, %B %d, %Y"), type="utility"},
    {pattern="clear", response="CLEAR_COMMAND", type="command"},
    {pattern="reset", response="RESET_COMMAND", type="command"},
    {pattern="help", response="Commands: clear, reset, help. Just chat naturally!", type="info"},
    {pattern="model", response="Current model: ", type="info"},
}

function Patterns.match(text)
    local lowerText = string.lower(text)
    for _, p in ipairs(Patterns) do
        if string.find(lowerText, p.pattern) then
            if p.type == "info" and p.pattern == "model" then
                return nil -- Handled elsewhere
            end
            return p.response, p.type
        end
    end
    return nil, nil
end

-- // Main AI Coordinator
local AI = {}
AI.currentModel = "Flash"
AI.trainingComplete = false

function AI.initialize()
    Storage.load()
    
    if next(Storage.data.markov) == nil then
        print("[ChatMind] Training initial dataset...")
        local categories = {"greetings", "logic", "code", "roleplay"}
        for _, cat in ipairs(categories) do
            for _, pair in ipairs(TRAINING_DATA[cat] or {}) do
                Markov.train(pair.in .. " " .. pair.out)
                Bayes.train(cat, pair.in)
                Bayes.train(cat, pair.out)
            end
        end
        Storage.save()
        AI.trainingComplete = true
        print("[ChatMind] Training complete. Ready!")
    else
        for key, nextWords in pairs(Storage.data.markov) do
            Markov.chain[key] = nextWords
        end
        print("[ChatMind] Loaded existing data.")
        AI.trainingComplete = true
    end
end

function AI.process(input)
    if not AI.trainingComplete then wait(0.5) end
    
    local modelConfig = CONFIG.Models[AI.currentModel] or CONFIG.Models.Flash
    local temperature = modelConfig.temp
    local depth = modelConfig.depth
    
    -- 1. Pattern Match
    local patternResp, pType = Patterns.match(input)
    if patternResp then
        if patternResp == "CLEAR_COMMAND" then
            Storage.data.history = {}
            Storage.save()
            return "✅ History cleared."
        elseif patternResp == "RESET_COMMAND" then
            pcall(delfile, CONFIG.SaveFile)
            return "🔄 Reset complete. Reloading..."
        end
        return patternResp
    end
    
    -- 2. Classification
    local category, confidence = Bayes.classify(input)
    
    -- 3. Response Generation Strategy
    local response = ""
    
    if category and confidence > -10 then
        -- Find best matching trained response
        local bestMatch = nil
        local bestSim = 0
        
        for _, pair in ipairs(TRAINING_DATA[category] or {}) do
            local sim = Utils.calculateSimilarity(input, pair.in)
            if sim > bestSim and sim > 0.5 then
                bestSim = sim
                bestMatch = pair.out
            end
        end
        
        if bestMatch then
            response = bestMatch
        else
            response = Markov.generate(input, depth * 4, temperature)
        end
    else
        response = Markov.generate(input, depth * 3, temperature)
        if #Utils.tokenize(response) < 3 then
            response = Utils.randomChoice(TRAINING_DATA.fillers)
        end
    end
    
    -- Online Learning
    Markov.train(input .. " " .. response)
    if category then Bayes.train(category, input) end
    Storage.addMemory(input, response)
    
    return response
end

-- // GUI System
local GUI = {}
GUI.Visible = false
GUI.MainFrame = nil

function GUI.create()
    if GUI.MainFrame then GUI.MainFrame:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ChatMindGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 0
    shadow.Parent = mainFrame
    Instance.new("UICorner").Parent = shadow
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "🤖 ChatMind v2.0"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = titleBar
    
    -- Status Indicator
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(1, -25, 0.5, -4)
    statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    statusDot.BorderSizePixel = 0
    statusDot.Parent = titleBar
    Instance.new("UICorner").Parent = statusDot
    
    -- Model Selector
    local modelBtn = Instance.new("TextButton")
    modelBtn.Size = UDim2.new(0, 110, 0, 32)
    modelBtn.Position = UDim2.new(1, -120, 0, 6)
    modelBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    modelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    modelBtn.Text = "⚡ Flash"
    modelBtn.Font = Enum.Font.GothamSemibold
    modelBtn.TextSize = 13
    modelBtn.Parent = titleBar
    Instance.new("UICorner").Parent = modelBtn
    
    -- Chat Output
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -25, 1, -115)
    scrollFrame.Position = UDim2.new(0, 12, 0, 52)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scrollFrame.Parent = mainFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 8)
    scrollCorner.Parent = scrollFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = scrollFrame
    
    -- Input Area
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -110, 0, 42)
    inputBox.Position = UDim2.new(0, 12, 1, -52)
    inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderText = "Message ChatMind..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 15
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = mainFrame
    Instance.new("UICorner").Parent = inputBox
    Instance.new("UIPadding").Parent = inputBox
    
    local sendBtn = Instance.new("TextButton")
    sendBtn.Size = UDim2.new(0, 90, 0, 42)
    sendBtn.Position = UDim2.new(1, -102, 1, -52)
    sendBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.Text = "Send"
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.TextSize = 15
    sendBtn.Parent = mainFrame
    Instance.new("UICorner").Parent = sendBtn
    
    -- Hover effects
    sendBtn.MouseEnter:Connect(function() sendBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 255) end)
    sendBtn.MouseLeave:Connect(function() sendBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255) end)
    
    -- Functions
    local function addMessage(text, isUser)
        local msgFrame = Instance.new("Frame")
        msgFrame.Size = UDim2.new(0.85, 0, 0, 0)
        msgFrame.AutomaticSize = Enum.AutomaticSize.Y
        msgFrame.BackgroundColor3 = isUser and Color3.fromRGB(0, 120, 220) or Color3.fromRGB(50, 50, 65)
        msgFrame.Parent = scrollFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = msgFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -12, 0, 0)
        label.AutomaticSize = Enum.AutomaticSize.Y
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.PaddingTop = UDim.new(0, 6)
        label.PaddingBottom = UDim.new(0, 6)
        label.Parent = msgFrame
        
        task.wait()
        msgFrame.Size = UDim2.new(0.85, 0, 0, label.AbsoluteSize.Y + 12)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
        scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
    end
    
    local function sendMessage()
        local text = inputBox.Text
        if text == "" then return end
        
        addMessage(text, true)
        inputBox.Text = ""
        
        task.spawn(function()
            local response = AI.process(text)
            task.wait(0.15 + math.random() * 0.3)
            addMessage(response, false)
        end)
    end
    
    sendBtn.MouseButton1Click:Connect(sendMessage)
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then sendMessage() end
    end)
    
    modelBtn.MouseButton1Click:Connect(function()
        local models = {"Flash", "DeepThink", "Pro"}
        local icons = {"⚡", "🧠", "💎"}
        local currentIdx = table.find(models, AI.currentModel) or 1
        local nextIdx = (currentIdx % #models) + 1
        AI.currentModel = models[nextIdx]
        modelBtn.Text = icons[nextIdx] .. " " .. models[nextIdx]
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ChatMind";
            Text = "Switched to " .. models[nextIdx] .. " model";
            Duration = 2;
        })
    end)
    
    GUI.MainFrame = mainFrame
    GUI.ScreenGui = screenGui
    GUI.AddMessage = addMessage
    GUI.SendButton = sendBtn
    GUI.InputBox = inputBox
    GUI.ModelButton = modelBtn
end

function GUI.toggle()
    if not GUI.MainFrame then GUI.create() end
    GUI.Visible = not GUI.Visible
    GUI.MainFrame.Visible = GUI.Visible
    if GUI.Visible then
        GUI.InputBox:CaptureFocus()
    end
end

-- // Initialization
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CONFIG.ToggleKey then
        GUI.toggle()
    end
end)

-- Start
AI.initialize()
GUI.create()

print("━━━━━━━━━━━━━━━━━━━━━━")
print("🤖 ChatMind v2.0 Loaded")
print("Press RightCtrl to open")
print("━━━━━━━━━━━━━━━━━━━━━━")
