# ChatMind Client

A modular, client-side only chat AI system for Roblox built with Lua. Features Markov chains, Naive Bayes classification, and Mixture of Experts (MoE) architecture.

## 🚀 Features

- **Multiple AI Models**: Flash, DeepThink, and Pro models with different capabilities
- **Markov Chain Engine**: Unigram, bigram, and trigram text generation
- **Naive Bayes Classifier**: Intent detection and text classification
- **Mixture of Experts**: Specialized response handlers for greetings, questions, etc.
- **Session Management**: Persistent chat sessions with auto-save
- **Memory System**: Context-aware responses with configurable memory slots
- **Client-Side Only**: No server dependencies, runs entirely on the client
- **Modular Architecture**: Easy to extend and customize

## 📁 Project Structure

```
ChatMind/
├── init.lua                 # Main module entry point
├── main.client.lua          # Client script (place in StarterPlayerScripts)
├── modules/
│   ├── models.lua           # Model configurations
│   ├── utils.lua            # Utility functions
│   ├── markov.lua           # Markov chain engine
│   ├── bayes.lua            # Naive Bayes classifier
│   ├── brain.lua            # Main AI coordinator
│   └── storage.lua          # Data persistence
└── README.md                # This file
```

## 🛠️ Installation

### Method 1: Manual Installation

1. Create a folder named `ChatMind` in your Roblox game's `StarterPlayer/StarterPlayerScripts`
2. Copy all files from this repository into that folder
3. The script will automatically start when the player joins

### Method 2: Module Approach

1. Place the `ChatMind` folder in `ReplicatedStorage` or `ServerStorage`
2. Require the module from a LocalScript:

```lua
local ChatMind = require(game.ReplicatedStorage.ChatMind)
-- ChatMind is now ready to use
```

## 🎮 Usage

### Basic Controls

- **Toggle Chat Window**: Press `RightCtrl` key
- **Send Message**: Type in the input box and press Enter or click ➤
- **Switch Models**: Click the model tag button (FLASH/DEEP/PRO) in the title bar

### API Usage (Advanced)

If you want to integrate ChatMind into your own scripts:

```lua
local Brain = require(script.Parent.modules.brain)
local Storage = require(script.Parent.modules.storage)

-- Create a brain instance
local brain = Brain.new("flash")

-- Learn from text
brain:learn("Hello! How are you?", "greeting")

-- Generate a response
local response = brain:respond("Hi there!")
print(response)

-- Save progress
local storage = Storage.new()
storage:saveBrain(brain, "flash")
```

## ⚙️ Configuration

### Model Selection

Edit `main.client.lua` to change the default model:

```lua
local ActiveModelKey = "flash"  -- Options: "flash", "deepthink", "pro"
```

### Model Comparison

| Model | Speed | Quality | Memory | Best For |
|-------|-------|---------|--------|----------|
| **Flash** | ⚡⚡⚡ Fast | ⭐⭐ Good | 8 slots | Quick responses |
| **DeepThink** | ⚡⚡ Medium | ⭐⭐⭐⭐ Excellent | 20 slots | Complex conversations |
| **Pro** | ⚡ Slow | ⭐⭐⭐⭐⭐ Best | 30 slots | Extended interactions |

### Generation Modes

Each model has multiple modes:

**Flash Model:**
- `spark` - Ultra-fast, minimal tokens
- `sparking_thinking` - Balanced speed/quality
- `think` - More thoughtful responses

**DeepThink Model:**
- `deepthink` - Deep analysis mode
- `extended_dt` - Maximum quality, slower

**Pro Model:**
- `lightning` - Fast fusion mode
- `thinking` - Balanced with web support
- `extended` - Maximum capability

## 🔧 Customization

### Adding Custom Seed Data

Edit the `SeedData` table in `main.client.lua`:

```lua
local SeedData = {
    {t="your custom training text here", c="category"},
    {t="more examples improve responses", c="category"},
}
```

### Adding New Experts

In `modules/brain.lua`, add to the experts registry:

```lua
self.experts = {
    custom = {
        keywords = {"keyword1", "keyword2"},
        responses = {"Custom response 1", "Custom response 2"}
    },
}
```

### Changing Colors

Edit the GUI colors in `buildGUI()` function:

```lua
main.BackgroundColor3 = Color3.fromRGB(31, 31, 31)  -- Background
sendBtn.BackgroundColor3 = Color3.fromRGB(25, 195, 125)  -- Send button
```

## 💾 Data Persistence

ChatMind automatically saves:
- Learned Markov chains
- Bayes classifier data
- Chat sessions
- Model settings

Data is stored in `ChatMindData/` folder with these files:
- `cm1flash.json` - Flash model data
- `cm1deepthink.json` - DeepThink model data
- `cm1pro.json` - Pro model data

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│           main.client.lua               │
│  (Initialization & GUI Management)      │
└───────────────┬─────────────────────────┘
                │
        ┌───────▼────────┐
        │    Brain       │
        │  (Coordinator) │
        └───────┬────────┘
                │
    ┌───────────┼───────────┐
    │           │           │
┌───▼───┐  ┌────▼────┐  ┌──▼───┐
│Markov │  │ Bayes   │  │Expert│
│Engine │  │Classifier│  │System│
└───────┘  └─────────┘  └──────┘
```

## 📝 Requirements

- Roblox client with script execution capability
- `writefile`/`readfile` support for data persistence (most executors)
- CoreGui access for UI rendering

## ⚠️ Limitations

- Client-side only: Data resets if executor doesn't support file I/O
- Learning is session-based: Long-term learning requires file persistence
- No internet connectivity: All processing is local
- Limited by executor capabilities

## 🐛 Troubleshooting

**Chat window not appearing:**
- Check if `RightCtrl` hotkey works
- Ensure CoreGui access is available
- Verify script is running in StarterPlayerScripts

**Data not saving:**
- Confirm `writefile` is supported by your executor
- Check for permission errors in the console

**Poor response quality:**
- Add more seed data for better initial responses
- Use DeepThink or Pro model for better quality
- Allow time for the model to learn from conversations

## 📄 License

This project is provided as-is for educational purposes. Modify and distribute as needed.

## 🤝 Contributing

Feel free to:
- Add new models or modes
- Improve the GUI
- Enhance the AI algorithms
- Fix bugs and optimize performance

## 📞 Support

For issues or questions, check the console output for error messages. Most issues can be diagnosed through the printed logs.

---

**Enjoy chatting with ChatMind!** 💬🧠
