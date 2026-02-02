# Voice AI Assistant Frontend

A modern, responsive web interface for the Voice AI Assistant.

## Features

- 🎨 Modern UI with smooth animations
- 🎙️ Push-to-talk microphone control
- 📊 Real-time audio visualization
- 💬 Live conversation display
- ⚙️ Easy configuration panel
- 📱 Responsive design (desktop, tablet, mobile)

## Quick Start

### Option 1: Simple File Opening

```bash
# macOS
open frontend/index.html

# Linux
xdg-open frontend/index.html

# Windows
start frontend/index.html
```

### Option 2: Local Server (Recommended)

```bash
cd frontend
python3 -m http.server 8080
# Then open http://localhost:8080
```

## Configuration

Before connecting, configure:

1. **LiveKit URL** - Your LiveKit server URL (e.g., `wss://your-project.livekit.cloud`)
2. **Room Name** - The room to join (default: `voice-ai-room`)
3. **Your Name** - Your participant name (default: `User`)

Settings are saved in browser local storage.

## Token Generation

To connect, implement a backend endpoint that generates LiveKit access tokens. See the [main README](../README.md) for full setup instructions.

## Demo Mode

Test the UI without connecting:

```javascript
// In browser console (F12)
window.voiceAssistant.startDemo()
```

## Customization

### Colors

Edit `styles.css` CSS variables:

```css
:root {
    --primary-color: #667eea;
    --secondary-color: #764ba2;
    /* ... */
}
```

### Layout

Modify sections in `index.html`:
- `.header` - Top navigation
- `.conversation-panel` - Message display
- `.control-panel` - Controls
- `.footer` - Bottom info

## Files

```
frontend/
├── index.html      # Main HTML
├── styles.css      # Styling
├── app.js          # Application logic
└── README.md       # This file
```

## License

Apache 2.0 - Same as main project
