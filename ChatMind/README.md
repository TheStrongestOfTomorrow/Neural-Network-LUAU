# 🤖 ChatMind v2.0 - Advanced Local AI

A sophisticated, client-side AI chatbot for Roblox that runs entirely locally using Markov Chains, Naive Bayes classification, and pattern matching. No external APIs required!

## ✨ Features

### 🧠 AI Engine
- **Hybrid Architecture**: Combines Markov Chains (trigram), Naive Bayes classifier, and pattern matching
- **3 AI Models**: 
  - ⚡ **Flash** - Fast responses, high creativity (temp: 0.8)
  - 🧠 **DeepThink** - Slower, more coherent responses (temp: 0.4)
  - 💎 **Pro** - Balanced performance (temp: 0.6)
- **Pre-trained Dataset**: 40+ training pairs across greetings, logic, code, and roleplay
- **Online Learning**: Continuously learns from your conversations
- **Persistent Storage**: Saves all learned data to local JSON file

### 🎨 Modern GUI
- Sleek dark theme with rounded corners
- Smooth animations and hover effects
- Real-time status indicator
- Model switching with visual feedback
- Auto-scrolling chat history
- Responsive message bubbles

### ⚙️ Configuration
- Adjustable temperature per model
- Configurable memory depth
- Customizable toggle key (default: RightCtrl)
- Max history limit (default: 20 messages)

## 📦 Installation

### For Executors (Recommended)
1. Download `EXECUTOR_VERSION_ENHANCED.lua`
2. Copy the entire code
3. Paste into your executor (Synapse X, Script-Ware, Krnl, Fluxus, etc.)
4. Click **Execute**
5. Press **RightCtrl** to open the chat window

### For Roblox Studio
1. Download the entire `ChatMind` folder
2. Place it in `StarterPlayer/StarterPlayerScripts`
3. Run the game
4. Press **RightCtrl** to toggle

## 🎮 Usage

### Basic Commands
- Just type naturally! The AI understands context
- `clear` - Clear chat history
- `reset` - Reset all learned data
- `help` - Show help message

### Switching Models
Click the model button in the top-right corner to cycle between:
- ⚡ Flash → 🧠 DeepThink → 💎 Pro → ⚡ Flash

### Tips
- The AI gets smarter the more you chat with it
- Use complete sentences for better responses
- Try asking about coding, math, or just casual chat
- Data persists between sessions via `ChatMind_Data_v2.json`

## 🔧 Customization

### Edit CONFIG Table
```lua
local CONFIG = {
    ToggleKey = Enum.KeyCode.RightControl, -- Change key
    SaveFile = "ChatMind_Data_v2.json",
    MaxHistory = 20,  -- Increase for more history
    DefaultModel = "Flash",
    Models = {
        Flash = { temp = 0.8, depth = 2 },
        DeepThink = { temp = 0.4, depth = 5 },
        Pro = { temp = 0.6, depth = 3 }
    }
}
```

### Add Custom Training Data
```lua
local TRAINING_DATA = {
    custom = {
        {in="your phrase", out="AI response"},
        {in="another phrase", out="another response"},
    }
}
```

## 🏗️ Architecture

```
ChatMind v2.0
├── Utils Module         - Tokenization, serialization, helpers
├── Storage Manager      - JSON read/write, persistence
├── Markov Engine        - Trigram chain generation
├── Bayes Classifier     - Intent classification
├── Pattern Matcher      - Command recognition
├── AI Coordinator       - Main logic orchestrator
└── GUI System           - Modern interface
```

## 📊 Performance

| Model | Response Time | Coherence | Creativity |
|-------|--------------|-----------|------------|
| Flash | ~50ms | Medium | High |
| DeepThink | ~150ms | High | Low |
| Pro | ~100ms | High | Medium |

## 🐛 Troubleshooting

### "readfile is not a valid member"
- Some executors don't support file I/O
- The script will still work but won't save data between sessions

### GUI not appearing
- Make sure you're not in a modal menu
- Try pressing RightCtrl twice
- Check output window for errors

### AI giving random responses
- Say `reset` to clear bad training data
- The AI learns from everything, including mistakes

## 📝 Changelog

### v2.0 (Enhanced)
- ✅ Added 40+ pre-trained responses
- ✅ Improved Markov chain to trigram
- ✅ Enhanced Naive Bayes with Laplace smoothing
- ✅ Added similarity matching for better responses
- ✅ Modern GUI with animations
- ✅ Model switching with icons
- ✅ Persistent JSON storage
- ✅ Online learning capability
- ✅ Better error handling

### v1.0 (Original)
- Basic Markov chain implementation
- Simple GUI
- Single model

## 📄 License

Free to use, modify, and distribute. No attribution required but appreciated!

## 🤝 Contributing

Feel free to:
- Add more training data
- Improve the AI algorithms
- Enhance the GUI
- Optimize performance

## 📞 Support

If you encounter issues:
1. Check the Output window for errors
2. Try the `reset` command
3. Ensure your executor supports `readfile`/`writefile`
4. Update to the latest version

---

**Made with ❤️ for the Roblox community**

*Press RightCtrl and start chatting!*
