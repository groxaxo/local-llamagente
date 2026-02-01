# Voice AI Agent with Local STT

A real-time voice AI assistant built with LiveKit Agents framework, featuring **local speech-to-text** (Parakeet TDT), language processing, and text-to-speech capabilities. Now with **Parakeet TDT** for ultra-fast, multilingual STT, **DeepSeek Chat** as the default LLM, and an **exquisite web frontend**!

## ✨ New Features

- 🎤 **Parakeet TDT STT** - Ultra-fast local speech-to-text (~30x real-time) with 25-language support
- 🐳 **Docker Support** - One-command deployment with Docker Compose
- 🎨 **Beautiful Web Frontend** - Modern, responsive UI with real-time conversation display
- 🤖 **DeepSeek Chat** - Powerful language model as default (faster and more cost-effective)
- 🚀 **Auto Installer** - One-command installation for Linux, macOS, and Windows
- 📊 **Audio Visualization** - Live audio level visualization in the frontend
- ⚙️ **Easy Configuration** - Simple web-based setup for all settings

## Features

- **Speech-to-Text**: **Parakeet TDT 0.6B v3** - Local, ultra-fast STT with automatic language detection
  - ~30x real-time speedup on modern CPUs
  - 25 supported languages (English, Spanish, French, German, and more)
  - No API keys required - fully local
  - OpenAI-compatible API
- **Language Model**: Supports multiple local and cloud LLM providers:
  - **DeepSeek Chat (default)** - Fast, intelligent, cost-effective
  - OpenAI GPT-4o-mini (cloud)
  - vLLM with Qwen 2.5 Instruct (local)
  - Ollama (local)
  - LM Studio (local)
- **Text-to-Speech**: KaniTTS Spanish model (nineninesix/kani-tts-400m-es) via OpenAI-compatible server
- **Voice Activity Detection**: Silero VAD for accurate speech detection
- **Turn Detection**: Multilingual turn detection for natural conversations
- **Noise Cancellation**: Background voice cancellation (BVC) for clear audio
- **Web Frontend**: Beautiful, responsive UI with real-time features

## Prerequisites

- Python ≥ 3.10
- [uv](https://docs.astral.sh/uv/) package manager (auto-installed by installer)
- Docker and Docker Compose (for STT service)
- LiveKit Cloud account ([sign up for free](https://cloud.livekit.io/))
- API keys for:
  - LiveKit (API key, secret, and URL)
  - DeepSeek (for default LLM) OR OpenAI OR a local LLM server (vLLM, Ollama, or LM Studio)

## Quick Start with Docker (Recommended)

### Complete Setup (STT + Agent)

```bash
git clone https://github.com/groxaxo/local-llamagente.git
cd local-llamagente

# Start the Parakeet STT service
docker compose up -d

# Install agent dependencies
./install.sh  # or install.bat on Windows

# Configure your .env.local file (see configuration below)

# Start the agent
uv run agent.py dev
```

The Parakeet STT service will be available at `http://localhost:5092`

### Linux / macOS

```bash
git clone https://github.com/groxaxo/local-llamagente.git
cd local-llamagente
chmod +x install.sh
./install.sh
```

### Windows

```bash
git clone https://github.com/groxaxo/local-llamagente.git
cd local-llamagente
install.bat
```

The auto installer will:
- ✅ Check Python version
- ✅ Install uv package manager
- ✅ Install LiveKit CLI
- ✅ Install all dependencies
- ✅ Download required model files
- ✅ Set up environment variables
- ✅ Guide you through API key configuration

After installation:
1. Configure your API keys in `.env.local`
2. Start the agent: `uv run agent.py dev`
3. Open the frontend: `open frontend/index.html`

## Manual Installation

### 1. Install LiveKit CLI (if not using auto installer)

**macOS:**
```bash
brew install livekit-cli
```

**Linux:**
```bash
curl -sSL https://get.livekit.io/cli | bash
```

**Windows:**
```bash
winget install LiveKit.LiveKitCLI
```

Then authenticate with LiveKit Cloud:
```bash
lk cloud auth
```

### 2. Clone and Setup

```bash
git clone git@github.com:nineninesix-ai/livekit-agent.git
cd livekit-agent
```

### 3. Install Dependencies

```bash
uv sync
```

This will install all required dependencies from [pyproject.toml](pyproject.toml):
- `livekit-agents` with OpenAI, Silero, and turn-detector plugins
- `livekit-plugins-noise-cancellation` for audio processing
- `python-dotenv` for environment variable management
- `aiohttp` for Parakeet STT client

### 4. Start Parakeet STT Service

Start the local STT service using Docker:

```bash
docker compose up -d
```

Verify it's running:
```bash
curl http://localhost:5092/health
```

### 5. Configure Environment Variables

Create a `.env.local` file in the project root with the following variables:

```env
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_api_secret
LIVEKIT_URL=wss://your-project.livekit.cloud

# STT Configuration (Parakeet TDT - Local)
PARAKEET_BASE_URL=http://localhost:5092/v1
STT_MODEL=parakeet-tdt-0.6b-v3

# LLM Configuration - Choose one option:
# Option 1: DeepSeek Chat (Default - Recommended)
OPENAI_API_KEY=your_deepseek_api_key
LLM_PROVIDER=deepseek
LLM_BASE_URL=https://api.deepseek.com
LLM_MODEL=deepseek-chat

# Option 2: OpenAI (Cloud)
# OPENAI_API_KEY=your_openai_api_key
# LLM_PROVIDER=openai
# LLM_BASE_URL=https://api.openai.com/v1
# LLM_MODEL=gpt-4o-mini

# Option 3: vLLM (Local)
# LLM_PROVIDER=vllm
# LLM_BASE_URL=http://localhost:8001/v1
# LLM_MODEL=Qwen/Qwen2.5-7B-Instruct
# OPENAI_API_KEY=not-needed

# Option 4: Ollama (Local)
# LLM_PROVIDER=ollama
# LLM_BASE_URL=http://localhost:11434/v1
# LLM_MODEL=qwen2.5:7b-instruct
# OPENAI_API_KEY=not-needed

# Option 5: LM Studio (Local)
# LLM_PROVIDER=lmstudio
# LLM_BASE_URL=http://localhost:1234/v1
# LLM_MODEL=qwen2.5-7b-instruct
# OPENAI_API_KEY=not-needed

# TTS Configuration (KaniTTS)
KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

**Get your DeepSeek API key:**
1. Visit [DeepSeek Platform](https://platform.deepseek.com/)
2. Sign up for an account
3. Generate an API key from the dashboard

**Quick setup with LiveKit CLI:**
```bash
lk app env -w
```

This automatically generates LiveKit credentials in `.env.local`.

### 5. Download Model Files

Download required model files (VAD, turn detection, etc.):

```bash
uv run agent.py download-files
```

## Web Frontend

This project includes a beautiful, modern web interface for interacting with the voice assistant.

### Features

- 🎨 Modern, responsive design with smooth animations
- 🎙️ Push-to-talk microphone control
- 📊 Real-time audio visualization
- 💬 Live conversation display
- ⚙️ Easy configuration panel
- 📱 Works on desktop, tablet, and mobile

### Using the Frontend

1. **Start the backend agent**:
   ```bash
   uv run agent.py dev
   ```

2. **Open the frontend**:
   
   **Quick method (for testing):**
   ```bash
   # macOS
   open frontend/index.html
   
   # Linux
   xdg-open frontend/index.html
   
   # Windows
   start frontend/index.html
   ```
   
   **Recommended method (with local server):**
   ```bash
   cd frontend
   python3 -m http.server 8080
   # Then open http://localhost:8080 in your browser
   ```

3. **Configure and connect**:
   - Enter your LiveKit URL
   - Set room name and participant name
   - Click "Connect"
   - Use push-to-talk to speak with the assistant

For detailed frontend documentation, see [frontend/README.md](frontend/README.md).

## Usage

### Quick Start Examples

Here are some common configurations to get you started quickly:

**Example 1: DeepSeek Chat with Local STT (Default - Recommended)**
```env
# .env.local
LIVEKIT_API_KEY=your_key
LIVEKIT_API_SECRET=your_secret
LIVEKIT_URL=wss://your-project.livekit.cloud

# Local Parakeet STT
PARAKEET_BASE_URL=http://localhost:5092/v1
STT_MODEL=parakeet-tdt-0.6b-v3

# DeepSeek LLM
LLM_PROVIDER=deepseek
LLM_BASE_URL=https://api.deepseek.com
LLM_MODEL=deepseek-chat
OPENAI_API_KEY=your_deepseek_api_key

# KaniTTS
KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

**Example 2: Fully Local Setup (Parakeet STT + Ollama + KaniTTS)**
```env
# .env.local
LIVEKIT_API_KEY=your_key
LIVEKIT_API_SECRET=your_secret
LIVEKIT_URL=wss://your-project.livekit.cloud

# Local Parakeet STT
PARAKEET_BASE_URL=http://localhost:5092/v1
STT_MODEL=parakeet-tdt-0.6b-v3

# Ollama LLM
LLM_PROVIDER=ollama
LLM_BASE_URL=http://localhost:11434/v1
LLM_MODEL=qwen2.5:7b-instruct
OPENAI_API_KEY=not-needed

# KaniTTS
KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

**Example 3: Local STT + vLLM for Performance + KaniTTS**
```env
# .env.local
LIVEKIT_API_KEY=your_key
LIVEKIT_API_SECRET=your_secret
LIVEKIT_URL=wss://your-project.livekit.cloud

# Local Parakeet STT
PARAKEET_BASE_URL=http://localhost:5092/v1
STT_MODEL=parakeet-tdt-0.6b-v3

LLM_PROVIDER=vllm
LLM_BASE_URL=http://localhost:8001/v1
LLM_MODEL=Qwen/Qwen2.5-7B-Instruct
OPENAI_API_KEY=not-needed

KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

**Example 4: Local STT + Cloud OpenAI + Local TTS**
```env
# .env.local
LIVEKIT_API_KEY=your_key
LIVEKIT_API_SECRET=your_secret
LIVEKIT_URL=wss://your-project.livekit.cloud

# Local Parakeet STT
PARAKEET_BASE_URL=http://localhost:5092/v1
STT_MODEL=parakeet-tdt-0.6b-v3

# OpenAI LLM
LLM_PROVIDER=openai
LLM_MODEL=gpt-4o-mini
OPENAI_API_KEY=your_openai_key

# KaniTTS
KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

### Development Mode

Run the agent in development mode (connects to LiveKit Cloud):

```bash
uv run agent.py dev
```

This starts the agent and connects it to your LiveKit server. You can interact with it via:
- [LiveKit Agents Playground](https://cloud.livekit.io/projects/p_/agents)
- Your own web/mobile frontend
- Telephony integration

### Console Mode

Test the agent locally in your terminal without LiveKit connection:

```bash
uv run agent.py console
```

### Production Mode

Run the agent in production:

```bash
uv run agent.py start
```

## Local Model Deployment Guide

For detailed instructions on deploying all models locally (LLM + TTS), see the [DEPLOYMENT.md](DEPLOYMENT.md) guide.

Quick overview of supported providers:

### Local LLM Setup

This agent supports multiple LLM backends, all using OpenAI-compatible APIs. Choose the option that best fits your needs:

#### Option 1: vLLM (Recommended for Performance)

vLLM provides high-throughput serving for LLMs with optimized performance.

**Installation:**
```bash
pip install vllm
```

**Deploy Qwen 2.5 Instruct:**
```bash
# Start vLLM server with Qwen 2.5 7B Instruct
python -m vllm.entrypoints.openai.api_server \
    --model Qwen/Qwen2.5-7B-Instruct \
    --port 8001 \
    --served-model-name Qwen/Qwen2.5-7B-Instruct

# For smaller models (3B):
# python -m vllm.entrypoints.openai.api_server \
#     --model Qwen/Qwen2.5-3B-Instruct \
#     --port 8001
```

**Configuration in `.env.local`:**
```env
LLM_PROVIDER=vllm
LLM_BASE_URL=http://localhost:8001/v1
LLM_MODEL=Qwen/Qwen2.5-7B-Instruct
OPENAI_API_KEY=not-needed
```

#### Option 2: Ollama (Easiest Setup)

Ollama provides the simplest way to run local LLMs.

**Installation:**
Visit [ollama.ai](https://ollama.ai/) and follow the installation instructions for your OS.

**Deploy Qwen 2.5 Instruct:**
```bash
# Pull and run Qwen 2.5 7B Instruct
ollama pull qwen2.5:7b-instruct

# Start Ollama server (usually runs automatically)
ollama serve
```

**Configuration in `.env.local`:**
```env
LLM_PROVIDER=ollama
LLM_BASE_URL=http://localhost:11434/v1
LLM_MODEL=qwen2.5:7b-instruct
OPENAI_API_KEY=not-needed
```

**Note:** Ollama requires OpenAI compatibility to be enabled. Make sure you're using Ollama v0.1.0 or later which includes the `/v1` OpenAI-compatible endpoint.

#### Option 3: LM Studio (Best for Desktop)

LM Studio provides a user-friendly desktop application for running local LLMs.

**Installation:**
1. Download LM Studio from [lmstudio.ai](https://lmstudio.ai/)
2. Install and launch the application
3. Download a model (search for "Qwen 2.5 Instruct" in the app)
4. Start the local server from the "Local Server" tab (default port: 1234)

**Configuration in `.env.local`:**
```env
LLM_PROVIDER=lmstudio
LLM_BASE_URL=http://localhost:1234/v1
LLM_MODEL=qwen2.5-7b-instruct
OPENAI_API_KEY=not-needed
```

**Note:** The exact model name may vary based on what you've loaded in LM Studio. Check the "Local Server" tab for the correct model identifier.

### Custom TTS Server (KaniTTS Spanish Model)

This project uses the KaniTTS Spanish model (`nineninesix/kani-tts-400m-es`) for text-to-speech, deployed via an OpenAI-compatible server.

**Setup KaniTTS Server:**

1. Clone the KaniTTS vLLM repository:
```bash
git clone https://github.com/nineninesix-ai/kanitts-vllm.git
cd kanitts-vllm
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Start the TTS server with the Spanish model:
```bash
python server.py --model nineninesix/kani-tts-400m-es --port 8000
```

4. The server will be available at `http://localhost:8000/v1`

**Configuration in `.env.local`:**
```env
KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

**Verify TTS Server:**
```bash
curl http://localhost:8000/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nineninesix/kani-tts-400m-es",
    "input": "Hola, soy tu asistente de voz.",
    "voice": "andrew"
  }' \
  --output test.wav
```

Check our reference implementation: https://github.com/nineninesix-ai/kanitts-vllm

### Audio Models Configuration

Current configuration:
- **STT**: Parakeet TDT 0.6B v3 - Local, ultra-fast (~30x real-time), 25-language support
- **LLM**: Configurable (DeepSeek, OpenAI, vLLM, Ollama, or LM Studio)
- **TTS**: KaniTTS Spanish model (nineninesix/kani-tts-400m-es)
- **VAD**: Silero VAD
- **Turn Detection**: Multilingual model
- **Noise Cancellation**: BVC (recommended for telephony)

## Telephony Applications

For telephony use cases, the agent uses BVC (Background Voice Cancellation) noise cancellation. For even better results with telephone audio, consider using `BVCTelephony`:

```python
room_input_options=RoomInputOptions(
    noise_cancellation=noise_cancellation.BVCTelephony(),
)
```

## Deployment

### Deploy to LiveKit Cloud

To deploy your agent to LiveKit Cloud for production use:

```bash
lk agent create
```

This command will:
- Automatically generate `Dockerfile`, `.dockerignore`, and `livekit.toml` configuration files
- Register your agent with your LiveKit Cloud project
- Deploy the containerized agent to the cloud

**Prerequisites for deployment:**
- LiveKit CLI authenticated with your cloud account (`lk cloud auth`)
- All environment variables configured in your LiveKit Cloud project settings

After deployment, your agent will be available through:
- [LiveKit Agents Playground](https://cloud.livekit.io/projects/p_/agents)
- Your custom web/mobile applications. Check our web embed app example here: https://github.com/nineninesix-ai/voice-agent-web-embed
- Telephony integrations

**Note:** For self-hosted production environments, refer to the [LiveKit documentation](https://docs.livekit.io/agents/) for custom deployment configurations.

## Resources

- [LiveKit Agents Documentation](https://docs.livekit.io/agents/)
- [LiveKit Cloud Console](https://cloud.livekit.io/)
- [Parakeet TDT Model](https://huggingface.co/nvidia/parakeet-tdt-0.6b-v3)
- [OpenAI API Documentation](https://platform.openai.com/docs/)

## Troubleshooting

**Agent won't start:**
- Verify all environment variables are set correctly in `.env.local`
- Ensure model files are downloaded: `uv run agent.py download-files`
- Check that your API keys are valid (or set to "not-needed" for local LLMs)
- Ensure Parakeet STT service is running: `docker compose ps`

**STT not working:**
- Verify Parakeet STT service is running: `curl http://localhost:5092/health`
- Check Docker logs: `docker compose logs parakeet-stt`
- Ensure port 5092 is not in use by another service
- Verify `PARAKEET_BASE_URL` is correctly set in `.env.local`

**No audio in/out:**
- Verify your microphone/speaker permissions
- Check LiveKit room configuration
- Ensure noise cancellation is properly configured

**TTS not working:**
- Ensure your local KaniTTS server is running on port 8000 (or configured port)
- Check server logs for errors
- Verify the server implements OpenAI-compatible API
- Test the TTS endpoint with curl (see Configuration section)

**LLM not responding:**
- For local LLMs, ensure the server is running:
  - vLLM: Check `http://localhost:8001/v1/models`
  - Ollama: Check `http://localhost:11434/v1/models`
  - LM Studio: Verify server is started in the application
- Check `LLM_BASE_URL` is correctly set in `.env.local`
- Verify the model name matches what's deployed
- For OpenAI, check your API key is valid and has credits

**Model loading issues:**
- Ensure you have enough GPU/CPU memory for the selected model
- For Qwen 2.5 7B: Recommended 16GB+ RAM, 8GB+ VRAM
- For Qwen 2.5 3B: Recommended 8GB+ RAM, 4GB+ VRAM
- Consider using quantized models (Q4, Q5) for lower memory requirements

## License

Apache 2. See [LICENSE](LICENSE) file for details.
