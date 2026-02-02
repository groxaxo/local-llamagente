# Voice AI Agent

A real-time voice AI assistant built with the LiveKit Agents framework. This project features **local speech-to-text** (Parakeet TDT), flexible language model support, and text-to-speech capabilities—all using **OpenAI-compatible API endpoints**.

## ✨ Key Features

- 🎤 **Flexible STT**: Local Parakeet TDT (~30x real-time) or any OpenAI-compatible STT service
- 🤖 **Universal LLM Support**: Works with OpenAI, DeepSeek, Anthropic, or any OpenAI-compatible provider
- 🔊 **Configurable TTS**: OpenAI TTS, local KaniTTS, or any compatible service
- 🌍 **Multilingual**: 25+ languages supported with automatic detection
- 🎨 **Modern Web UI**: Beautiful, responsive interface with real-time features
- 🐳 **Docker Ready**: One-command deployment with Docker Compose
- 🔒 **Privacy First**: Run everything locally or mix local/cloud services

## Quick Start

### Prerequisites

- Python ≥ 3.10
- Docker and Docker Compose (for local STT)
- LiveKit Cloud account ([sign up for free](https://cloud.livekit.io/))
- API keys for your chosen providers (OpenAI, DeepSeek, etc.)

### Installation

**Linux / macOS:**
```bash
git clone https://github.com/groxaxo/local-llamagente.git
cd local-llamagente

# Setup local STT service (optional)
./setup-stt.sh

# Install agent dependencies
./install.sh

# Configure your .env.local file (see below)
uv run agent.py dev
```

**Windows:**
```bash
git clone https://github.com/groxaxo/local-llamagente.git
cd local-llamagente

# Setup local STT service (optional)
setup-stt.bat

# Install agent dependencies
install.bat

# Configure your .env.local file (see below)
uv run agent.py dev
```

### Configuration

Create a `.env.local` file with your settings. All three components (STT, LLM, TTS) support **OpenAI-compatible API endpoints**.

#### Example 1: OpenAI (Cloud)

```env
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_api_secret
LIVEKIT_URL=wss://your-project.livekit.cloud

# OpenAI STT (Cloud)
PARAKEET_BASE_URL=https://api.openai.com/v1
STT_MODEL=whisper-1
OPENAI_API_KEY=your_openai_api_key

# OpenAI LLM (Cloud)
LLM_PROVIDER=openai
LLM_BASE_URL=https://api.openai.com/v1
LLM_MODEL=gpt-4o-mini

# OpenAI TTS (Cloud)
KANI_BASE_URL=https://api.openai.com/v1
TTS_MODEL=tts-1
TTS_VOICE=alloy
```

#### Example 2: DeepSeek + Local STT (Hybrid - Recommended)

```env
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_api_secret
LIVEKIT_URL=wss://your-project.livekit.cloud

# Local Parakeet STT (ultra-fast, local)
PARAKEET_BASE_URL=http://localhost:5092/v1
STT_MODEL=parakeet-tdt-0.6b-v3

# DeepSeek LLM (cloud, cost-effective)
LLM_PROVIDER=deepseek
LLM_BASE_URL=https://api.deepseek.com
LLM_MODEL=deepseek-chat
OPENAI_API_KEY=your_deepseek_api_key

# OpenAI TTS (cloud)
KANI_BASE_URL=https://api.openai.com/v1
TTS_MODEL=tts-1
TTS_VOICE=alloy
```

#### Example 3: Fully Local

```env
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_api_secret
LIVEKIT_URL=wss://your-project.livekit.cloud

# Local Parakeet STT
PARAKEET_BASE_URL=http://localhost:5092/v1
STT_MODEL=parakeet-tdt-0.6b-v3

# Local LLM (Ollama)
LLM_PROVIDER=ollama
LLM_BASE_URL=http://localhost:11434/v1
LLM_MODEL=qwen2.5:7b-instruct
OPENAI_API_KEY=not-needed

# Local TTS (KaniTTS)
KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

## Using the Web Frontend

1. **Start the agent**:
   ```bash
   uv run agent.py dev
   ```

2. **Open the frontend**:
   ```bash
   # Quick method
   open frontend/index.html
   
   # Or with a local server (recommended)
   cd frontend && python3 -m http.server 8080
   # Then open http://localhost:8080
   ```

3. **Configure and connect**:
   - Enter your LiveKit URL
   - Set room name and participant name
   - Click "Connect"
   - Use push-to-talk to speak

## Component Setup

### STT (Speech-to-Text)

#### Option 1: Local Parakeet TDT (Recommended)

Ultra-fast local STT with 25+ language support:

```bash
docker compose up -d
curl http://localhost:5092/health  # Verify
```

Configuration:
```env
PARAKEET_BASE_URL=http://localhost:5092/v1
STT_MODEL=parakeet-tdt-0.6b-v3
```

#### Option 2: OpenAI Whisper

```env
PARAKEET_BASE_URL=https://api.openai.com/v1
STT_MODEL=whisper-1
OPENAI_API_KEY=your_openai_api_key
```

#### Option 3: Any OpenAI-compatible STT Provider

```env
PARAKEET_BASE_URL=https://your-stt-provider.com/v1
STT_MODEL=your-model-name
```

### LLM (Language Model)

Any OpenAI-compatible provider works. Examples:

**OpenAI:**
```env
LLM_PROVIDER=openai
LLM_BASE_URL=https://api.openai.com/v1
LLM_MODEL=gpt-4o-mini
OPENAI_API_KEY=your_openai_api_key
```

**DeepSeek:**
```env
LLM_PROVIDER=deepseek
LLM_BASE_URL=https://api.deepseek.com
LLM_MODEL=deepseek-chat
OPENAI_API_KEY=your_deepseek_api_key
```

**Ollama (Local):**
```bash
ollama pull qwen2.5:7b-instruct
ollama serve
```
```env
LLM_PROVIDER=ollama
LLM_BASE_URL=http://localhost:11434/v1
LLM_MODEL=qwen2.5:7b-instruct
OPENAI_API_KEY=not-needed
```

**vLLM (Local):**
```bash
pip install vllm
python -m vllm.entrypoints.openai.api_server \
    --model Qwen/Qwen2.5-7B-Instruct --port 8001
```
```env
LLM_PROVIDER=vllm
LLM_BASE_URL=http://localhost:8001/v1
LLM_MODEL=Qwen/Qwen2.5-7B-Instruct
OPENAI_API_KEY=not-needed
```

### TTS (Text-to-Speech)

#### Option 1: OpenAI TTS

```env
KANI_BASE_URL=https://api.openai.com/v1
TTS_MODEL=tts-1
TTS_VOICE=alloy
OPENAI_API_KEY=your_openai_api_key
```

#### Option 2: Local KaniTTS (Spanish)

```bash
git clone https://github.com/nineninesix-ai/kanitts-vllm.git
cd kanitts-vllm
pip install -r requirements.txt
python server.py --model nineninesix/kani-tts-400m-es --port 8000
```
```env
KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

#### Option 3: Any OpenAI-compatible TTS Provider

```env
KANI_BASE_URL=https://your-tts-provider.com/v1
TTS_MODEL=your-model-name
TTS_VOICE=your-voice-name
```

## Usage

### Development Mode
```bash
uv run agent.py dev
```

### Console Mode (Local Testing)
```bash
uv run agent.py console
```

### Production Mode
```bash
uv run agent.py start
```

## Deployment

Deploy to LiveKit Cloud:

```bash
lk agent create
```

This automatically:
- Generates Dockerfile and configuration files
- Registers your agent with LiveKit Cloud
- Deploys the containerized agent

For self-hosted deployments, see [LiveKit documentation](https://docs.livekit.io/agents/).

## Troubleshooting

**Agent won't start:**
- Verify all environment variables in `.env.local`
- Check API keys are valid
- Ensure required services are running (Docker for local STT, etc.)

**STT not working:**
- For local: `curl http://localhost:5092/health`
- Check Docker logs: `docker compose logs parakeet-stt`
- Verify `PARAKEET_BASE_URL` is correct

**LLM not responding:**
- Test endpoint: `curl http://your-llm-url/v1/models`
- Check API key and credits (for cloud providers)
- For local: ensure server is running

**TTS not working:**
- Test endpoint: `curl http://your-tts-url/v1/audio/speech`
- Check server logs for errors
- Verify OpenAI-compatible API implementation

## Advanced Configuration

### Using Different Providers per Component

You can mix and match providers:

```env
# Local STT for privacy
PARAKEET_BASE_URL=http://localhost:5092/v1
STT_MODEL=parakeet-tdt-0.6b-v3

# Cloud LLM for quality
LLM_BASE_URL=https://api.openai.com/v1
LLM_MODEL=gpt-4o-mini
OPENAI_API_KEY=your_openai_key

# Local TTS for cost savings
KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

### Anthropic Claude Support

```env
# Use an OpenAI-to-Anthropic adapter or compatible proxy
LLM_BASE_URL=https://api.anthropic.com/v1
LLM_MODEL=claude-3-5-sonnet-20241022
OPENAI_API_KEY=your_anthropic_api_key
```

### Custom API Endpoints

Any service implementing the OpenAI API specification will work:

```env
# Your custom STT endpoint
PARAKEET_BASE_URL=https://my-custom-stt.example.com/v1
STT_MODEL=my-model

# Your custom LLM endpoint  
LLM_BASE_URL=https://my-custom-llm.example.com/v1
LLM_MODEL=my-model

# Your custom TTS endpoint
KANI_BASE_URL=https://my-custom-tts.example.com/v1
TTS_MODEL=my-model
TTS_VOICE=my-voice
```

## Resources

- [LiveKit Agents Documentation](https://docs.livekit.io/agents/)
- [LiveKit Cloud Console](https://cloud.livekit.io/)
- [Parakeet TDT Model](https://huggingface.co/nvidia/parakeet-tdt-0.6b-v3)
- [OpenAI API Documentation](https://platform.openai.com/docs/)

## License

Apache 2.0. See [LICENSE](LICENSE) file for details.
