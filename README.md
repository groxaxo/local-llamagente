# Voice AI Agent with KaniTTS

A real-time voice AI assistant built with LiveKit Agents framework, featuring speech-to-text, language processing, and text-to-speech capabilities.

## Features

- **Speech-to-Text**: Deepgram STT with Flux General EN model
- **Language Model**: Supports multiple local and cloud LLM providers:
  - OpenAI GPT-4o-mini (cloud)
  - vLLM with Qwen 2.5 Instruct (local)
  - Ollama (local)
  - LM Studio (local)
- **Text-to-Speech**: KaniTTS Spanish model (nineninesix/kani-tts-400m-es) via OpenAI-compatible server
- **Voice Activity Detection**: Silero VAD for accurate speech detection
- **Turn Detection**: Multilingual turn detection for natural conversations
- **Noise Cancellation**: Background voice cancellation (BVC) for clear audio

## Prerequisites

- Python ≥ 3.10
- [uv](https://docs.astral.sh/uv/) package manager
- LiveKit Cloud account ([sign up for free](https://cloud.livekit.io/))
- API keys for:
  - LiveKit (API key, secret, and URL)
  - Deepgram (for STT)
  - OpenAI (for cloud LLM option) OR a local LLM server (vLLM, Ollama, or LM Studio)

## Installation

### 1. Install LiveKit CLI

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
- `livekit-agents` with Deepgram, OpenAI, Silero, and turn-detector plugins
- `livekit-plugins-noise-cancellation` for audio processing
- `python-dotenv` for environment variable management

### 4. Configure Environment Variables

Create a `.env.local` file in the project root with the following variables:

```env
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_api_secret
LIVEKIT_URL=wss://your-project.livekit.cloud
DEEPGRAM_API_KEY=your_deepgram_api_key

# LLM Configuration - Choose one option:
# Option 1: OpenAI (Cloud)
OPENAI_API_KEY=your_openai_api_key
LLM_PROVIDER=openai
LLM_MODEL=gpt-4o-mini

# Option 2: vLLM (Local)
# LLM_PROVIDER=vllm
# LLM_BASE_URL=http://localhost:8001/v1
# LLM_MODEL=Qwen/Qwen2.5-7B-Instruct
# OPENAI_API_KEY=not-needed

# Option 3: Ollama (Local)
# LLM_PROVIDER=ollama
# LLM_BASE_URL=http://localhost:11434/v1
# LLM_MODEL=qwen2.5:7b-instruct
# OPENAI_API_KEY=not-needed

# Option 4: LM Studio (Local)
# LLM_PROVIDER=lmstudio
# LLM_BASE_URL=http://localhost:1234/v1
# LLM_MODEL=qwen2.5-7b-instruct
# OPENAI_API_KEY=not-needed

# TTS Configuration (KaniTTS)
KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

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

## Usage

### Quick Start Examples

Here are some common configurations to get you started quickly:

**Example 1: Fully Local Setup (Ollama + KaniTTS)**
```env
# .env.local
LIVEKIT_API_KEY=your_key
LIVEKIT_API_SECRET=your_secret
LIVEKIT_URL=wss://your-project.livekit.cloud
DEEPGRAM_API_KEY=your_deepgram_key

LLM_PROVIDER=ollama
LLM_BASE_URL=http://localhost:11434/v1
LLM_MODEL=qwen2.5:7b-instruct
OPENAI_API_KEY=not-needed

KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

**Example 2: vLLM for Performance + KaniTTS**
```env
# .env.local
LIVEKIT_API_KEY=your_key
LIVEKIT_API_SECRET=your_secret
LIVEKIT_URL=wss://your-project.livekit.cloud
DEEPGRAM_API_KEY=your_deepgram_key

LLM_PROVIDER=vllm
LLM_BASE_URL=http://localhost:8001/v1
LLM_MODEL=Qwen/Qwen2.5-7B-Instruct
OPENAI_API_KEY=not-needed

KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

**Example 3: Cloud OpenAI + Local KaniTTS**
```env
# .env.local
LIVEKIT_API_KEY=your_key
LIVEKIT_API_SECRET=your_secret
LIVEKIT_URL=wss://your-project.livekit.cloud
DEEPGRAM_API_KEY=your_deepgram_key

LLM_PROVIDER=openai
LLM_MODEL=gpt-4o-mini
OPENAI_API_KEY=your_openai_key

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
- **STT**: Deepgram Flux General EN with 0.4s eager end-of-turn threshold
- **LLM**: Configurable (OpenAI, vLLM, Ollama, or LM Studio)
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
- [Deepgram Documentation](https://developers.deepgram.com/)
- [OpenAI API Documentation](https://platform.openai.com/docs/)

## Troubleshooting

**Agent won't start:**
- Verify all environment variables are set correctly in `.env.local`
- Ensure model files are downloaded: `uv run agent.py download-files`
- Check that your API keys are valid (or set to "not-needed" for local LLMs)

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
