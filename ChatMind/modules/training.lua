-- ============================================================================
-- ChatMind v2.0 - Pre-trained Corpus
-- Extensive training data for immediate intelligence
-- ============================================================================

return {
    -- Greetings
    {text = "hello hi hey greetings good morning good afternoon good evening", intent = "greeting"},
    {text = "hi there hello friend greetings welcome", intent = "greeting"},
    {text = "hey sup yo what's up howdy", intent = "greeting"},
    {text = "hello everyone hi all greetings friends", intent = "greeting"},
    
    -- Farewells
    {text = "bye goodbye see you later farewell take care cya", intent = "farewell"},
    {text = "goodbye bye see ya later until next time", intent = "farewell"},
    {text = "take care bye goodbye have a good one", intent = "farewell"},
    {text = "catch you later bye farewell see you soon", intent = "farewell"},
    
    -- Gratitude
    {text = "thank thanks thank you appreciate grateful thx", intent = "gratitude"},
    {text = "thanks a lot thank you very much appreciate it", intent = "gratitude"},
    {text = "much appreciated thanks grateful thank you", intent = "gratitude"},
    {text = "thank you so many thanks really appreciate", intent = "gratitude"},
    
    -- Affirmations
    {text = "yes yeah yup sure okay alright certainly definitely", intent = "affirmation"},
    {text = "yeah yes absolutely indeed of course", intent = "affirmation"},
    {text = "okay sure yup sounds good alright", intent = "affirmation"},
    {text = "definitely yes absolutely certainly sure", intent = "affirmation"},
    
    -- Negations
    {text = "no nope nah not really no way", intent = "negation"},
    {text = "nope no nah not at all", intent = "negation"},
    {text = "no way nope not happening", intent = "negation"},
    {text = "not really no nope nah", intent = "negation"},
    
    -- Questions
    {text = "what is how does why when where who which", intent = "question"},
    {text = "can you tell me what do you think how about", intent = "question"},
    {text = "do you know could you explain i wonder", intent = "question"},
    {text = "what do you mean how come why not", intent = "question"},
    
    -- Help requests
    {text = "help assist support guide explain teach show me", intent = "help_request"},
    {text = "i need help can you help me assist me please", intent = "help_request"},
    {text = "how do i what should i can you show me", intent = "help_request"},
    {text = "please help me i need assistance support", intent = "help_request"},
    
    -- Apologies
    {text = "sorry apologize apology regret oops my bad", intent = "apology"},
    {text = "i'm sorry my apologies pardon me excuse me", intent = "apology"},
    {text = "sorry about that my bad oops", intent = "apology"},
    {text = "apologize sorry i regret that", intent = "apology"},
    
    -- Humor
    {text = "joke funny laugh humor comedy hilarious lol lmao", intent = "humor"},
    {text = "tell me a joke make me laugh something funny", intent = "humor"},
    {text = "that's funny lol haha lmao", intent = "humor"},
    {text = "humor comedy funny joke hilarious", intent = "humor"},
    
    -- General conversation
    {text = "how are you how's it going what's up how do you do", intent = "general"},
    {text = "nice good great awesome amazing excellent", intent = "general"},
    {text = "interesting cool neat wonderful fantastic", intent = "general"},
    {text = "i think i feel i believe in my opinion", intent = "general"},
    {text = "really oh wow really that's cool", intent = "general"},
    {text = "tell me more go on continue i'm listening", intent = "general"},
    {text = "that's nice interesting cool awesome", intent = "general"},
    {text = "wow amazing incredible fantastic wonderful", intent = "general"},
    
    -- Roblox specific
    {text = "roblox game play gaming player noob pro", intent = "general"},
    {text = "bloxburg adopt me brookhaven tower of hell", intent = "general"},
    {text = "robux avatar clothes items shop", intent = "general"},
    {text = "friends party group chat join", intent = "general"},
    {text = "roblox studio script build create", intent = "general"},
    {text = "game pass developer products robux", intent = "general"},
    
    -- Emotions - Positive
    {text = "happy glad joyful excited pleased delighted", intent = "general"},
    {text = "love like enjoy adore appreciate", intent = "general"},
    {text = "wonderful amazing fantastic great excellent", intent = "general"},
    {text = "cheerful content satisfied thrilled", intent = "general"},
    
    -- Emotions - Negative
    {text = "sad upset disappointed unhappy frustrated", intent = "general"},
    {text = "angry mad furious annoyed irritated", intent = "general"},
    {text = "worried anxious nervous scared afraid", intent = "general"},
    {text = "tired exhausted weary drained", intent = "general"},
    
    -- Common phrases
    {text = "you're welcome no problem don't mention it anytime", intent = "gratitude"},
    {text = "i don't know not sure maybe possibly", intent = "general"},
    {text = "let me think hmm interesting good point", intent = "general"},
    {text = "agree disagree same different similar", intent = "general"},
    {text = "of course certainly definitely absolutely", intent = "affirmation"},
    {text = "never mind it's okay don't worry", intent = "general"},
    
    -- Conversation starters
    {text = "what are you doing how's your day going", intent = "general"},
    {text = "did you hear about have you seen", intent = "general"},
    {text = "guess what i wanted to tell you", intent = "general"},
    {text = "by the way speaking of incidentally", intent = "general"},
    
    -- Reactions
    {text = "oh really wow seriously no way", intent = "general"},
    {text = "that's awesome cool nice great", intent = "general"},
    {text = "i see uh huh right okay", intent = "general"},
    {text = "makes sense i understand got it", intent = "general"},
}
