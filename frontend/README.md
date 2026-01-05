# Voice AI Assistant Frontend

A beautiful, modern web interface for the Voice AI Assistant powered by DeepSeek Chat and LiveKit.

## Features

- 🎨 **Exquisite UI Design** - Modern, responsive interface with smooth animations
- 🎙️ **Real-time Voice Interaction** - Push-to-talk microphone control
- 📊 **Audio Visualization** - Live audio level visualization
- 💬 **Conversation Display** - Clean, chat-style message interface
- ⚙️ **Configuration Panel** - Easy setup for LiveKit connection
- 📱 **Responsive Design** - Works on desktop, tablet, and mobile
- 🔄 **Live Status Indicators** - Real-time backend service status
- 🌙 **Dark Theme** - Eye-friendly dark mode design

## Quick Start

### Option 1: Local File (Development)

Simply open the `index.html` file in your browser:

```bash
# On macOS
open frontend/index.html

# On Linux
xdg-open frontend/index.html

# On Windows
start frontend/index.html
```

**Note**: Some features may be limited when opening as a local file due to browser security restrictions.

### Option 2: Local Server (Recommended)

Use a simple HTTP server to serve the frontend:

**Using Python:**
```bash
cd frontend
python3 -m http.server 8080
```

Then open http://localhost:8080 in your browser.

**Using Node.js (npx):**
```bash
cd frontend
npx http-server -p 8080
```

**Using PHP:**
```bash
cd frontend
php -S localhost:8080
```

## Configuration

Before connecting, you need to configure:

1. **LiveKit URL** - Your LiveKit server URL (e.g., `wss://your-project.livekit.cloud`)
2. **Room Name** - The room to join (default: `voice-ai-room`)
3. **Your Name** - Your participant name (default: `User`)

These settings are saved in your browser's local storage.

## Token Generation

To connect to LiveKit, you need to implement a backend endpoint that generates access tokens. 

### Example Backend (Node.js/Express)

```javascript
const express = require('express');
const { AccessToken } = require('livekit-server-sdk');

const app = express();
app.use(express.json());

app.post('/api/token', (req, res) => {
    const { roomName, participantName } = req.body;
    
    const token = new AccessToken(
        process.env.LIVEKIT_API_KEY,
        process.env.LIVEKIT_API_SECRET,
        {
            identity: participantName,
        }
    );
    
    token.addGrant({
        roomJoin: true,
        room: roomName,
        canPublish: true,
        canSubscribe: true,
    });
    
    res.json({ token: token.toJwt() });
});

app.listen(3000);
```

### Example Backend (Python/Flask)

```python
from flask import Flask, request, jsonify
from livekit import api
import os

app = Flask(__name__)

@app.route('/api/token', methods=['POST'])
def generate_token():
    data = request.json
    room_name = data['roomName']
    participant_name = data['participantName']
    
    token = api.AccessToken(
        os.getenv('LIVEKIT_API_KEY'),
        os.getenv('LIVEKIT_API_SECRET')
    )
    token.with_identity(participant_name)
    token.with_grants(api.VideoGrants(
        room_join=True,
        room=room_name,
        can_publish=True,
        can_subscribe=True
    ))
    
    return jsonify({'token': token.to_jwt()})

if __name__ == '__main__':
    app.run(port=3000)
```

## Usage

1. **Start the backend agent**:
   ```bash
   uv run agent.py dev
   ```

2. **Open the frontend** in your browser

3. **Configure connection settings** in the Configuration panel

4. **Click "Connect"** to join the voice room

5. **Press and hold the microphone button** to speak

6. The assistant will respond with voice and text

## Demo Mode

For testing the UI without connecting to LiveKit, you can run the demo mode:

1. Open the browser console (F12)
2. Run: `window.voiceAssistant.startDemo()`

This will simulate a conversation to showcase the UI.

## Customization

### Changing Colors

Edit `styles.css` and modify the CSS variables at the top:

```css
:root {
    --primary-color: #667eea;
    --secondary-color: #764ba2;
    --accent-color: #f093fb;
    /* ... more colors ... */
}
```

### Modifying the Layout

The main layout is defined in `index.html`. Key sections:
- `.header` - Top navigation bar
- `.conversation-panel` - Message display area
- `.control-panel` - Controls and configuration
- `.footer` - Bottom credits

### Adding Features

Extend the `VoiceAssistant` class in `app.js`:

```javascript
class VoiceAssistant {
    // Add your custom methods here
    customFeature() {
        // Your code
    }
}
```

## Browser Compatibility

- ✅ Chrome/Edge 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Opera 76+

## Troubleshooting

### Cannot connect to LiveKit

- Ensure your LiveKit URL is correct and starts with `wss://`
- Verify your backend token generation endpoint is running
- Check browser console for specific error messages

### No audio visualization

- Grant microphone permissions when prompted
- Check that audio tracks are being received
- Verify Web Audio API is supported in your browser

### Microphone not working

- Ensure you've granted microphone permissions
- Check that no other application is using the microphone
- Try refreshing the page

## Files Structure

```
frontend/
├── index.html      # Main HTML file
├── styles.css      # All styling
├── app.js          # Application logic
└── README.md       # This file
```

## License

Apache 2.0 - Same as the main project
