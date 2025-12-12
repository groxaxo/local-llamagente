# Local Model Deployment Guide

This guide provides step-by-step instructions for deploying all models locally for a completely self-hosted voice AI agent.

## Overview

This setup runs everything locally:
- **LLM**: Qwen 2.5 Instruct (via vLLM, Ollama, or LM Studio)
- **TTS**: KaniTTS Spanish model (nineninesix/kani-tts-400m-es)
- **STT**: Deepgram (cloud-based, but can be replaced with local alternatives)

## Quick Start: Fully Local Setup

### Prerequisites

- Python 3.10+
- 16GB+ RAM (for 7B models)
- 8GB+ VRAM (GPU recommended but not required)
- LiveKit account (or self-hosted LiveKit server)

### Step 1: Install and Setup LLM (Choose One)

#### Option A: Ollama (Recommended for Beginners)

1. **Install Ollama:**
   - Visit https://ollama.ai/
   - Download and install for your OS
   - Ollama runs automatically after installation

2. **Pull Qwen 2.5 Model:**
   ```bash
   ollama pull qwen2.5:7b-instruct
   ```

3. **Verify it's running:**
   ```bash
   curl http://localhost:11434/v1/models
   ```

4. **Configure in `.env.local`:**
   ```env
   LLM_PROVIDER=ollama
   LLM_BASE_URL=http://localhost:11434/v1
   LLM_MODEL=qwen2.5:7b-instruct
   OPENAI_API_KEY=not-needed
   ```

#### Option B: vLLM (Recommended for Performance)

1. **Install vLLM:**
   ```bash
   pip install vllm
   ```

2. **Start vLLM Server:**
   ```bash
   # For GPU:
   python -m vllm.entrypoints.openai.api_server \
       --model Qwen/Qwen2.5-7B-Instruct \
       --port 8001
   
   # For CPU only (slower):
   python -m vllm.entrypoints.openai.api_server \
       --model Qwen/Qwen2.5-7B-Instruct \
       --port 8001 \
       --device cpu
   ```

3. **Verify it's running:**
   ```bash
   curl http://localhost:8001/v1/models
   ```

4. **Configure in `.env.local`:**
   ```env
   LLM_PROVIDER=vllm
   LLM_BASE_URL=http://localhost:8001/v1
   LLM_MODEL=Qwen/Qwen2.5-7B-Instruct
   OPENAI_API_KEY=not-needed
   ```

#### Option C: LM Studio (Best for Desktop Users)

1. **Install LM Studio:**
   - Download from https://lmstudio.ai/
   - Install and launch the application

2. **Download Model:**
   - Open LM Studio
   - Search for "Qwen 2.5 Instruct"
   - Download a GGUF version (Q4 or Q5 for better performance)

3. **Start Server:**
   - Go to "Local Server" tab
   - Load your downloaded model
   - Click "Start Server"
   - Default port is 1234

4. **Configure in `.env.local`:**
   ```env
   LLM_PROVIDER=lmstudio
   LLM_BASE_URL=http://localhost:1234/v1
   LLM_MODEL=qwen2.5-7b-instruct
   OPENAI_API_KEY=not-needed
   ```

### Step 2: Setup KaniTTS (Spanish TTS)

1. **Clone KaniTTS vLLM Repository:**
   ```bash
   git clone https://github.com/nineninesix-ai/kanitts-vllm.git
   cd kanitts-vllm
   ```

2. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Start TTS Server:**
   ```bash
   python server.py --model nineninesix/kani-tts-400m-es --port 8000
   ```

   The server will download the model on first run (~400MB).

4. **Verify TTS Server:**
   ```bash
   curl http://localhost:8000/v1/audio/speech \
     -H "Content-Type: application/json" \
     -d '{
       "model": "nineninesix/kani-tts-400m-es",
       "input": "Hola, soy tu asistente de voz.",
       "voice": "andrew"
     }' \
     --output test.wav
   
   # Play the audio file to verify
   # On macOS: afplay test.wav
   # On Linux: aplay test.wav
   # On Windows: start test.wav
   ```

5. **Configure in `.env.local`:**
   ```env
   KANI_BASE_URL=http://localhost:8000/v1
   TTS_MODEL=nineninesix/kani-tts-400m-es
   TTS_VOICE=andrew
   ```

### Step 3: Setup Agent

1. **Install Dependencies:**
   ```bash
   cd /path/to/local-llamagente
   uv sync
   ```

2. **Download Model Files:**
   ```bash
   uv run agent.py download-files
   ```

3. **Create `.env.local` with Full Configuration:**
   ```env
   # LiveKit
   LIVEKIT_API_KEY=your_livekit_api_key
   LIVEKIT_API_SECRET=your_livekit_api_secret
   LIVEKIT_URL=wss://your-project.livekit.cloud
   
   # Deepgram STT
   DEEPGRAM_API_KEY=your_deepgram_api_key
   
   # LLM (Example: Ollama)
   LLM_PROVIDER=ollama
   LLM_BASE_URL=http://localhost:11434/v1
   LLM_MODEL=qwen2.5:7b-instruct
   OPENAI_API_KEY=not-needed
   
   # TTS (KaniTTS Spanish)
   KANI_BASE_URL=http://localhost:8000/v1
   TTS_MODEL=nineninesix/kani-tts-400m-es
   TTS_VOICE=andrew
   ```

4. **Run the Agent:**
   ```bash
   uv run agent.py dev
   ```

## Testing Your Setup

### Test LLM

```bash
# For Ollama
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5:7b-instruct",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'

# For vLLM
curl http://localhost:8001/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen/Qwen2.5-7B-Instruct",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Test TTS

```bash
curl http://localhost:8000/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nineninesix/kani-tts-400m-es",
    "input": "Hola, ¿cómo estás?",
    "voice": "andrew"
  }' \
  --output test.wav
```

## Performance Optimization

### GPU Acceleration

For better performance, ensure you have CUDA installed:

```bash
# Check if CUDA is available
python -c "import torch; print(torch.cuda.is_available())"
```

### Memory Requirements

| Model | RAM | VRAM | Performance |
|-------|-----|------|-------------|
| Qwen 2.5 3B | 8GB | 4GB | Good |
| Qwen 2.5 7B | 16GB | 8GB | Better |
| Qwen 2.5 7B (Q4) | 8GB | 4GB | Good (quantized) |

### Using Smaller Models

If you have limited resources, use smaller models:

**For vLLM:**
```bash
python -m vllm.entrypoints.openai.api_server \
    --model Qwen/Qwen2.5-3B-Instruct \
    --port 8001
```

**For Ollama:**
```bash
ollama pull qwen2.5:3b-instruct
```

## Troubleshooting

### LLM Server Won't Start

**Out of memory:**
- Try a smaller model (3B instead of 7B)
- Use quantized versions (Q4, Q5)
- Close other applications

**CUDA errors:**
- Verify CUDA installation: `nvidia-smi`
- Update GPU drivers
- Use CPU mode: `--device cpu` for vLLM

### TTS Server Issues

**Model download fails:**
- Check internet connection
- Ensure you have enough disk space (~1GB)
- Try downloading manually from HuggingFace

**Audio quality issues:**
- Verify sample rate settings
- Check the response_format parameter

### Agent Connection Issues

**Cannot connect to LLM:**
- Verify server is running: `curl http://localhost:PORT/v1/models`
- Check LLM_BASE_URL in `.env.local`
- Ensure no firewall blocking localhost

**TTS not working:**
- Verify TTS server is running
- Test with curl command
- Check server logs for errors

## Production Deployment

For production deployment:

1. Use a process manager (systemd, supervisor) to keep services running
2. Configure proper logging
3. Set up monitoring for all services
4. Use reverse proxy (nginx) for external access
5. Implement proper security (authentication, rate limiting)

### Example systemd Service for vLLM

```ini
[Unit]
Description=vLLM OpenAI API Server
After=network.target

[Service]
Type=simple
User=your-user
WorkingDirectory=/home/your-user
ExecStart=/usr/bin/python3 -m vllm.entrypoints.openai.api_server --model Qwen/Qwen2.5-7B-Instruct --port 8001
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Example systemd Service for KaniTTS

```ini
[Unit]
Description=KaniTTS Server
After=network.target

[Service]
Type=simple
User=your-user
WorkingDirectory=/home/your-user/kanitts-vllm
ExecStart=/usr/bin/python3 server.py --model nineninesix/kani-tts-400m-es --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

## Alternative STT Options

While this guide uses Deepgram (cloud), you can also use local STT:

### Whisper (Local STT)

```bash
pip install openai-whisper
```

Modify the agent to use Whisper instead of Deepgram for fully local operation.

## Resources

- [Qwen Models](https://huggingface.co/Qwen)
- [KaniTTS Model](https://huggingface.co/nineninesix/kani-tts-400m-es)
- [vLLM Documentation](https://docs.vllm.ai/)
- [Ollama Documentation](https://github.com/ollama/ollama)
- [LM Studio](https://lmstudio.ai/)
- [LiveKit Documentation](https://docs.livekit.io/)
