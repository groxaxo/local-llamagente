// Voice AI Assistant - Frontend Application
// Powered by LiveKit and OpenAI-compatible API Providers

class VoiceAssistant {
    constructor() {
        this.room = null;
        this.isConnected = false;
        this.isMicActive = false;
        this.audioContext = null;
        this.analyser = null;
        this.animationFrame = null;
        
        this.initializeElements();
        this.attachEventListeners();
        this.startAudioVisualization();
        this.loadSettings();
    }

    initializeElements() {
        // Buttons
        this.btnConnect = document.getElementById('btn-connect');
        this.btnDisconnect = document.getElementById('btn-disconnect');
        this.btnMic = document.getElementById('btn-mic');
        this.btnClear = document.getElementById('clear-conversation');

        // Inputs
        this.inputLivekitUrl = document.getElementById('livekit-url');
        this.inputRoomName = document.getElementById('room-name');
        this.inputParticipantName = document.getElementById('participant-name');
        this.checkboxAutoConnect = document.getElementById('auto-connect-audio');
        this.checkboxNoiseCancellation = document.getElementById('noise-cancellation');

        // Status elements
        this.connectionStatus = document.getElementById('connection-status');
        this.llmStatus = document.getElementById('llm-status');
        this.sttStatus = document.getElementById('stt-status');
        this.ttsStatus = document.getElementById('tts-status');

        // Containers
        this.messagesContainer = document.getElementById('messages-container');
        this.audioCanvas = document.getElementById('audio-canvas');
    }

    attachEventListeners() {
        this.btnConnect.addEventListener('click', () => this.connect());
        this.btnDisconnect.addEventListener('click', () => this.disconnect());
        this.btnMic.addEventListener('mousedown', () => this.activateMic());
        this.btnMic.addEventListener('mouseup', () => this.deactivateMic());
        this.btnMic.addEventListener('touchstart', (e) => {
            e.preventDefault();
            this.activateMic();
        });
        this.btnMic.addEventListener('touchend', (e) => {
            e.preventDefault();
            this.deactivateMic();
        });
        this.btnClear.addEventListener('click', () => this.clearConversation());

        // Save settings on change
        [this.inputLivekitUrl, this.inputRoomName, this.inputParticipantName].forEach(input => {
            input.addEventListener('change', () => this.saveSettings());
        });
    }

    loadSettings() {
        const savedUrl = localStorage.getItem('livekitUrl');
        const savedRoom = localStorage.getItem('roomName');
        const savedName = localStorage.getItem('participantName');

        if (savedUrl) this.inputLivekitUrl.value = savedUrl;
        if (savedRoom) this.inputRoomName.value = savedRoom;
        if (savedName) this.inputParticipantName.value = savedName;
    }

    saveSettings() {
        localStorage.setItem('livekitUrl', this.inputLivekitUrl.value);
        localStorage.setItem('roomName', this.inputRoomName.value);
        localStorage.setItem('participantName', this.inputParticipantName.value);
    }

    async connect() {
        try {
            const livekitUrl = this.inputLivekitUrl.value.trim();
            const roomName = this.inputRoomName.value.trim();
            const participantName = this.inputParticipantName.value.trim();

            if (!livekitUrl || !roomName || !participantName) {
                this.showError('Please fill in all connection fields');
                return;
            }

            this.btnConnect.disabled = true;
            this.updateConnectionStatus('Connecting...', 'Establishing connection');

            // For this demo, we need a token from the server
            // In production, you'd get this from your backend
            this.showError('To connect, you need to implement token generation on your backend. See LiveKit documentation for details.');
            
            // Example connection code (requires token from backend):
            /*
            const token = await this.getToken(roomName, participantName);
            this.room = new LivekitClient.Room({
                adaptiveStream: true,
                dynacast: true,
            });

            await this.room.connect(livekitUrl, token);
            
            this.isConnected = true;
            this.setupRoomEventHandlers();
            this.updateConnectionStatus('Connected', `Room: ${roomName}`);
            this.btnConnect.disabled = true;
            this.btnDisconnect.disabled = false;
            this.btnMic.disabled = false;
            this.setStatusActive('llm-status', true);
            this.setStatusActive('stt-status', true);
            this.setStatusActive('tts-status', true);
            
            this.addSystemMessage('Connected to voice assistant');
            */

        } catch (error) {
            console.error('Connection error:', error);
            this.showError('Failed to connect: ' + error.message);
            this.btnConnect.disabled = false;
        }
    }

    async getToken(roomName, participantName) {
        // This should call your backend to generate a LiveKit token
        // Example implementation:
        const response = await fetch('/api/token', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ roomName, participantName })
        });
        
        if (!response.ok) {
            throw new Error('Failed to get token');
        }
        
        const data = await response.json();
        return data.token;
    }

    setupRoomEventHandlers() {
        if (!this.room) return;

        this.room.on('trackSubscribed', (track, publication, participant) => {
            if (track.kind === 'audio') {
                const audioElement = track.attach();
                document.body.appendChild(audioElement);
                this.setupAudioAnalyzer(audioElement);
            }
        });

        this.room.on('trackUnsubscribed', (track) => {
            track.detach().forEach(element => element.remove());
        });

        this.room.on('participantConnected', (participant) => {
            console.log('Participant connected:', participant.identity);
            this.addSystemMessage(`${participant.identity} joined`);
        });

        this.room.on('participantDisconnected', (participant) => {
            console.log('Participant disconnected:', participant.identity);
            this.addSystemMessage(`${participant.identity} left`);
        });

        this.room.on('dataReceived', (payload, participant) => {
            const data = JSON.parse(new TextDecoder().decode(payload));
            this.handleDataMessage(data, participant);
        });

        this.room.on('disconnected', () => {
            this.handleDisconnection();
        });
    }

    handleDataMessage(data, participant) {
        if (data.type === 'transcription') {
            this.addMessage(data.text, 'user', data.timestamp);
        } else if (data.type === 'response') {
            this.addMessage(data.text, 'assistant', data.timestamp);
        }
    }

    async disconnect() {
        if (this.room) {
            await this.room.disconnect();
        }
        this.handleDisconnection();
    }

    handleDisconnection() {
        this.isConnected = false;
        this.isMicActive = false;
        this.room = null;
        
        this.updateConnectionStatus('Disconnected', 'Ready to connect');
        this.btnConnect.disabled = false;
        this.btnDisconnect.disabled = true;
        this.btnMic.disabled = true;
        this.btnMic.classList.remove('active');
        
        this.setStatusActive('llm-status', false);
        this.setStatusActive('stt-status', false);
        this.setStatusActive('tts-status', false);
        
        this.addSystemMessage('Disconnected from voice assistant');
    }

    async activateMic() {
        if (!this.isConnected || this.isMicActive) return;
        
        this.isMicActive = true;
        this.btnMic.classList.add('active');
        
        if (this.room) {
            await this.room.localParticipant.setMicrophoneEnabled(true);
        }
    }

    async deactivateMic() {
        if (!this.isMicActive) return;
        
        this.isMicActive = false;
        this.btnMic.classList.remove('active');
        
        if (this.room) {
            await this.room.localParticipant.setMicrophoneEnabled(false);
        }
    }

    updateConnectionStatus(title, subtitle) {
        const statusTitle = this.connectionStatus.querySelector('.status-title');
        const statusSubtitle = this.connectionStatus.querySelector('.status-subtitle');
        
        statusTitle.textContent = title;
        statusSubtitle.textContent = subtitle;
        
        if (title === 'Connected') {
            this.connectionStatus.classList.add('connected');
        } else {
            this.connectionStatus.classList.remove('connected');
        }
    }

    setStatusActive(elementId, active) {
        const element = document.getElementById(elementId);
        if (active) {
            element.classList.add('active');
        } else {
            element.classList.remove('active');
        }
    }

    addMessage(text, sender = 'assistant', timestamp = null) {
        const message = document.createElement('div');
        message.className = `message ${sender}`;
        
        const time = timestamp ? new Date(timestamp) : new Date();
        const timeStr = time.toLocaleTimeString('en-US', { 
            hour: '2-digit', 
            minute: '2-digit' 
        });
        
        const avatar = sender === 'user' ? '👤' : '🤖';
        const senderName = sender === 'user' ? 'You' : 'Assistant';
        
        message.innerHTML = `
            <div class="message-avatar">${avatar}</div>
            <div class="message-content">
                <div class="message-header">
                    <span class="message-sender">${senderName}</span>
                    <span class="message-time">${timeStr}</span>
                </div>
                <div class="message-text">${this.escapeHtml(text)}</div>
            </div>
        `;
        
        // Remove welcome message if it exists
        const welcomeMessage = this.messagesContainer.querySelector('.welcome-message');
        if (welcomeMessage) {
            welcomeMessage.remove();
        }
        
        this.messagesContainer.appendChild(message);
        this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight;
    }

    addSystemMessage(text) {
        const message = document.createElement('div');
        message.className = 'message system';
        message.style.textAlign = 'center';
        message.style.color = 'var(--text-secondary)';
        message.style.fontSize = '13px';
        message.style.margin = '20px 0';
        message.textContent = text;
        
        this.messagesContainer.appendChild(message);
        this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight;
    }

    clearConversation() {
        this.messagesContainer.innerHTML = `
            <div class="welcome-message">
                <div class="welcome-icon">👋</div>
                <h3>Welcome to Voice AI Assistant</h3>
                <p>Configure your settings and click "Connect" to start a conversation with the AI assistant.</p>
            </div>
        `;
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    showError(message) {
        // Create a temporary error message
        const errorDiv = document.createElement('div');
        errorDiv.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: var(--danger-color);
            color: white;
            padding: 16px 24px;
            border-radius: 12px;
            box-shadow: var(--shadow-lg);
            z-index: 1000;
            animation: slideIn 0.3s ease-out;
        `;
        errorDiv.textContent = message;
        
        document.body.appendChild(errorDiv);
        
        setTimeout(() => {
            errorDiv.style.animation = 'slideOut 0.3s ease-out';
            setTimeout(() => errorDiv.remove(), 300);
        }, 5000);
    }

    setupAudioAnalyzer(audioElement) {
        if (!this.audioContext) {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
        }
        
        const source = this.audioContext.createMediaElementSource(audioElement);
        this.analyser = this.audioContext.createAnalyser();
        this.analyser.fftSize = 256;
        
        source.connect(this.analyser);
        this.analyser.connect(this.audioContext.destination);
    }

    startAudioVisualization() {
        const canvas = this.audioCanvas;
        const ctx = canvas.getContext('2d');
        const width = canvas.width;
        const height = canvas.height;
        
        const draw = () => {
            this.animationFrame = requestAnimationFrame(draw);
            
            // Clear canvas
            ctx.fillStyle = 'rgba(26, 26, 46, 0.3)';
            ctx.fillRect(0, 0, width, height);
            
            if (this.analyser) {
                const bufferLength = this.analyser.frequencyBinCount;
                const dataArray = new Uint8Array(bufferLength);
                this.analyser.getByteFrequencyData(dataArray);
                
                const barWidth = (width / bufferLength) * 2.5;
                let x = 0;
                
                for (let i = 0; i < bufferLength; i++) {
                    const barHeight = (dataArray[i] / 255) * height * 0.8;
                    
                    const gradient = ctx.createLinearGradient(0, height - barHeight, 0, height);
                    gradient.addColorStop(0, '#667eea');
                    gradient.addColorStop(1, '#764ba2');
                    
                    ctx.fillStyle = gradient;
                    ctx.fillRect(x, height - barHeight, barWidth, barHeight);
                    
                    x += barWidth + 1;
                }
            } else {
                // Draw idle animation
                const bars = 32;
                const barWidth = width / bars;
                const time = Date.now() / 1000;
                
                for (let i = 0; i < bars; i++) {
                    const barHeight = Math.sin(time * 2 + i * 0.5) * 20 + 30;
                    
                    const gradient = ctx.createLinearGradient(0, height - barHeight, 0, height);
                    gradient.addColorStop(0, 'rgba(102, 126, 234, 0.3)');
                    gradient.addColorStop(1, 'rgba(118, 75, 162, 0.3)');
                    
                    ctx.fillStyle = gradient;
                    ctx.fillRect(i * barWidth, height - barHeight, barWidth - 2, barHeight);
                }
            }
        };
        
        draw();
    }

    // Demo mode - simulate conversation
    startDemo() {
        if (this.isConnected) return;
        
        this.addMessage('Hello! How can I help you today?', 'assistant');
        
        setTimeout(() => {
            this.addMessage('Can you tell me about this voice assistant?', 'user');
        }, 2000);
        
        setTimeout(() => {
            this.addMessage('This is a voice AI assistant powered by LiveKit Agents framework. It supports any OpenAI-compatible API provider for speech-to-text, language models, and text-to-speech. You can use providers like OpenAI, DeepSeek, local models with Ollama, or any other compatible service.', 'assistant');
        }, 4000);
    }
}

// Initialize the application
document.addEventListener('DOMContentLoaded', () => {
    const app = new VoiceAssistant();
    
    // Make it globally accessible for debugging
    window.voiceAssistant = app;
    
    console.log('Voice AI Assistant initialized');
    console.log('To test the UI, call: window.voiceAssistant.startDemo()');
});
