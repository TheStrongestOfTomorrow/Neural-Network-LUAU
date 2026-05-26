-- main.client.lua - Main Client Entry Point
-- Initializes and runs the ChatMind AI client

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local Models = require(script.Parent.modules.models)
local Brain = require(script.Parent.modules.brain)
local Storage = require(script.Parent.modules.storage)
local Utils = require(script.Parent.modules.utils)

--------------------------------------------------------------------------------
-- CONFIGURATION
--------------------------------------------------------------------------------

local LocalPlayer = Players.LocalPlayer
local ActiveModelKey = "flash"
local ActiveModeKey = nil
local GlobalSettings = {
	systemPrompt = "",
	language = "english",
	alertKeywords = {},
	webEnabled = false,
	sidebarOpen = true,
}

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local brain = nil
local storage = Storage.new()
local gui = {}

--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------

local function initialize()
	-- Create brain instance
	brain = Brain.new(ActiveModelKey)
	ActiveModeKey = Models[ActiveModelKey].defaultMode
	
	-- Try to load saved data
	local savedData = storage:loadBrain(ActiveModelKey)
	if savedData then
		-- Restore markov chains
		if savedData.markov then
			for k, v in pairs(savedData.markov.unigram or {}) do
				brain.markov.unigram[k] = v
			end
			for k, v in pairs(savedData.markov.bigram or {}) do
				brain.markov.bigram[k] = v
			end
			for k, v in pairs(savedData.markov.trigram or {}) do
				brain.markov.trigram[k] = v
			end
		end
		
		-- Restore bayes classifier
		if savedData.bayes then
			brain.bayes.classCounts = savedData.bayes.classCounts or {}
			brain.bayes.wordCounts = savedData.bayes.wordCounts or {}
			brain.bayes.totalDocs = savedData.bayes.totalDocs or 0
			brain.bayes.vocab = savedData.bayes.vocab or {}
		end
		
		-- Restore sessions
		if savedData.sessions then
			brain.sessions = savedData.sessions
			brain.currentSessionId = savedData.currentSessionId
		end
		
		-- Restore settings
		if savedData.effectiveParams then
			brain:setEffectiveParams(savedData.effectiveParams)
		end
		if savedData.learningRate then
			brain:setLearningRate(savedData.learningRate)
		end
		
		print("[ChatMind] Data loaded successfully")
	else
		-- Seed with initial data
		seedBrain()
		brain:newSession()
		print("[ChatMind] Initialized with seed data")
	end
	
	-- Build GUI
	buildGUI()
	
	-- Start listening
	setupListeners()
end

--------------------------------------------------------------------------------
-- SEED DATA
--------------------------------------------------------------------------------

local SeedData = {
	{t="hello hi hey greetings good morning good afternoon good evening", c="greeting"},
	{t="bye goodbye see you later farewell take care", c="farewell"},
	{t="thank thanks thank you appreciate it youre awesome", c="gratitude"},
	{t="yes yeah yup sure okay alright definitely absolutely", c="affirmation"},
	{t="no nope nah not really never dont think so", c="negation"},
	{t="how are you hows it going whats up what are you doing", c="question"},
	{t="im fine im good im great im okay im doing well", c="response"},
	{t="what is your name who are you what should i call you", c="identity"},
	{t="my name is chatmind i am chatmind call me chatmind", c="identity"},
	{t="nice to meet you pleasure to meet you glad to meet you", c="greeting"},
}

function seedBrain()
	for _, item in ipairs(SeedData) do
		brain:learn(item.t, item.c)
	end
end

--------------------------------------------------------------------------------
-- CHAT LISTENERS
--------------------------------------------------------------------------------

local function setupListeners()
	-- Listen for TextChatService messages (if available)
	if TextChatService and TextChatService.TextMessageReceived then
		TextChatService.TextMessageReceived:Connect(function(message)
			if message.TextSource and message.TextSource.Name ~= LocalPlayer.Name then
				processIncomingMessage(message.TextContent, message.TextSource.Name)
			end
		end)
	end
	
	-- Also listen for legacy chat
	if Players.Chatted then
		Players.Chatted:Connect(function(message, player)
			if player and player ~= LocalPlayer then
				processIncomingMessage(message, player.Name)
			end
		end)
	end
end

local function processIncomingMessage(text, speaker)
	-- Check for alert keywords
	for _, keyword in ipairs(GlobalSettings.alertKeywords) do
		if string.find(string.lower(text), string.lower(keyword)) then
			-- Could trigger notification here
			print("[Alert] Keyword detected:", keyword)
		end
	end
	
	-- Learn from conversation (passive learning)
	brain:learn(text, "general")
end

--------------------------------------------------------------------------------
-- RESPONSE GENERATION
--------------------------------------------------------------------------------

local function generateResponse(input)
	input = input or ""
	
	-- Get current mode
	local mode = Models[ActiveModelKey].modes[ActiveModeKey]
	
	-- Generate response
	local response = brain:respond(input, mode)
	
	-- Add to session
	brain:addToSession(input, "user")
	brain:addToSession(response, "bot")
	
	return response
end

--------------------------------------------------------------------------------
-- GUI (Simplified Version)
--------------------------------------------------------------------------------

local function buildGUI()
	-- Create ScreenGui
	local screen = Instance.new("ScreenGui")
	screen.Name = "ChatMind"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = CoreGui
	
	-- Main frame
	local main = Instance.new("Frame", screen)
	main.Name = "Main"
	main.Size = UDim2.new(0, 400, 0, 300)
	main.Position = UDim2.new(0.5, -200, 0.5, -150)
	main.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
	main.BorderSizePixel = 0
	main.Active = true
	main.Visible = false  -- Start hidden, toggle with hotkey
	
	local corner = Instance.new("UICorner", main)
	corner.CornerRadius = UDim.new(0, 10)
	
	local stroke = Instance.new("UIStroke", main)
	stroke.Color = Color3.fromRGB(55, 55, 55)
	stroke.Thickness = 1
	
	-- Title bar
	local titleBar = Instance.new("Frame", main)
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.BackgroundTransparency = 1
	titleBar.BorderSizePixel = 0
	
	local titleLabel = Instance.new("TextLabel", titleBar)
	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "ChatMind - " .. Models[ActiveModelKey].name
	titleLabel.TextColor3 = Color3.fromRGB(236, 236, 241)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Model selector
	local modelBtn = Instance.new("TextButton", titleBar)
	modelBtn.Size = UDim2.new(0, 50, 0, 30)
	modelBtn.Position = UDim2.new(1, -55, 0.5, -15)
	modelBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	modelBtn.Text = Models[ActiveModelKey].tag
	modelBtn.TextColor3 = Color3.fromRGB(236, 236, 241)
	modelBtn.Font = Enum.Font.GothamBold
	modelBtn.TextSize = 11
	
	local btnCorner = Instance.new("UICorner", modelBtn)
	btnCorner.CornerRadius = UDim.new(0, 5)
	
	-- Chat area
	local chatScroll = Instance.new("ScrollingFrame", main)
	chatScroll.Size = UDim2.new(1, -16, 1, -92)
	chatScroll.Position = UDim2.new(0, 8, 0, 44)
	chatScroll.BackgroundTransparency = 1
	chatScroll.BorderSizePixel = 0
	chatScroll.ScrollBarThickness = 4
	chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	chatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	
	local listLayout = Instance.new("UIListLayout", chatScroll)
	listLayout.Padding = UDim.new(0, 8)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	-- Input area
	local inputFrame = Instance.new("Frame", main)
	inputFrame.Size = UDim2.new(1, -16, 0, 40)
	inputFrame.Position = UDim2.new(0, 8, 1, -48)
	inputFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	
	local inputCorner = Instance.new("UICorner", inputFrame)
	inputCorner.CornerRadius = UDim.new(0, 6)
	
	local textBox = Instance.new("TextBox", inputFrame)
	textBox.Size = UDim2.new(1, -50, 1, 0)
	textBox.BackgroundTransparency = 1
	textBox.Text = ""
	textBox.PlaceholderText = "Type a message..."
	textBox.TextColor3 = Color3.fromRGB(236, 236, 241)
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 13
	textBox.ClearTextOnFocus = false
	
	local sendBtn = Instance.new("TextButton", inputFrame)
	sendBtn.Size = UDim2.new(0, 40, 1, -8)
	sendBtn.Position = UDim2.new(1, -44, 0.5, -16)
	sendBtn.BackgroundColor3 = Color3.fromRGB(25, 195, 125)
	sendBtn.Text = "➤"
	sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	sendBtn.Font = Enum.Font.GothamBold
	sendBtn.TextSize = 16
	
	local sendCorner = Instance.new("UICorner", sendBtn)
	sendCorner.CornerRadius = UDim.new(0, 5)
	
	-- Store references
	gui.screen = screen
	gui.main = main
	gui.chatScroll = chatScroll
	gui.textBox = textBox
	gui.modelBtn = modelBtn
	
	-- Event handlers
	sendBtn.MouseButton1Click:Connect(function()
		local text = textBox.Text
		if #text > 0 then
			addChatMessage(textBox.Text, "user")
			local response = generateResponse(text)
			addChatMessage(response, "bot")
			textBox.Text = ""
		end
	end
	
	textBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			sendBtn.MouseButton1Click:Fire()
		end
	end)
	
	modelBtn.MouseButton1Click:Connect(function()
		cycleModel()
	end)
	
	-- Hotkey to toggle visibility
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.RightControl then
			main.Visible = not main.Visible
		end
	end)
end

local function addChatMessage(text, role)
	if not gui.chatScroll then return end
	
	local msgFrame = Instance.new("Frame")
	msgFrame.Size = UDim2.new(1, -8, 0, 0)
	msgFrame.AutomaticSize = Enum.AutomaticSize.Y
	msgFrame.BackgroundTransparency = 1
	
	local bgColor = role == "bot" and 
		Color3.fromRGB(38, 38, 38) or 
		Color3.fromRGB(25, 195, 125)
	
	local textColor = role == "bot" and 
		Color3.fromRGB(200, 220, 255) or 
		Color3.fromRGB(255, 255, 255)
	
	local bgFrame = Instance.new("Frame", msgFrame)
	bgFrame.BackgroundColor3 = bgColor
	bgFrame.BorderSizePixel = 0
	bgFrame.Size = UDim2.new(role == "bot" and 0.85 or 0.85, 0, 1, 0)
	bgFrame.Position = UDim2.new(role == "bot" and 0 or 0.15, 0, 0, 0)
	
	local corner = Instance.new("UICorner", bgFrame)
	corner.CornerRadius = UDim.new(0, 8)
	
	local label = Instance.new("TextLabel", bgFrame)
	label.Size = UDim2.new(1, -12, 1, -8)
	label.Position = UDim2.new(0, 6, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = textColor
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextWrapped = true
	label.TextXAlignment = role == "bot" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
	
	msgFrame.Parent = gui.chatScroll
	gui.chatScroll.CanvasSize = UDim2.new(0, 0, 0, gui.chatScroll.UIListLayout.AbsoluteContentSize.Y + 16)
	gui.chatScroll:ScrollBottom()
end

local function cycleModel()
	local modelKeys = {"flash", "deepthink", "pro"}
	local currentIndex = 1
	for i, key in ipairs(modelKeys) do
		if key == ActiveModelKey then
			currentIndex = i
			break
		end
	end
	
	local nextIndex = (currentIndex % #modelKeys) + 1
	ActiveModelKey = modelKeys[nextIndex]
	ActiveModeKey = Models[ActiveModelKey].defaultMode
	
	-- Update brain
	brain = Brain.new(ActiveModelKey)
	
	-- Update button
	gui.modelBtn.Text = Models[ActiveModelKey].tag
	
	-- Save data
	storage:saveBrain(brain, ActiveModelKey)
end

--------------------------------------------------------------------------------
-- AUTO-EXECUTE
--------------------------------------------------------------------------------

initialize()

print("[ChatMind] Client initialized successfully!")
print("Press RightCtrl to toggle chat window")
