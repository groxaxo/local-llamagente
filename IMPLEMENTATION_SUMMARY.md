# Parakeet TDT STT Integration - Implementation Summary

## Overview

Successfully replaced the Deepgram STT implementation with **Parakeet TDT 0.6B v3**, a local, ultra-fast speech-to-text service. This implementation provides:

- ⚡ **30x real-time transcription** on modern CPUs
- 🌍 **25 languages** with automatic detection
- 🔒 **Complete privacy** - all transcription happens locally
- 💰 **No API fees** - fully self-hosted
- 🐳 **Docker-ready** - one-command deployment

## What Was Implemented

### 1. Parakeet STT Service (`stt-service/`)

A complete, production-ready STT service with:

- **FastAPI application** (`app.py`)
  - OpenAI-compatible API endpoints
  - Intelligent audio chunking with silence detection
  - Support for multiple output formats (JSON, text, SRT, VTT)
  - Real-time progress tracking
  - Built-in web interface for testing

- **Docker configuration**
  - Optimized Dockerfile for CPU deployment
  - Health checks and automatic restarts
  - Volume persistence for model caching

- **Templates**
  - Modern web interface (`templates/index.html`)
  - Interactive API documentation (`templates/swagger.html`)

### 2. LiveKit Integration (`parakeet_stt.py`)

Custom STT plugin for LiveKit Agents:

- Implements LiveKit STT interface
- Uses aiohttp for async communication
- Proper error handling with context
- Audio buffer conversion to WAV format

### 3. Updated Agent (`agent.py`)

- Removed Deepgram dependency
- Integrated Parakeet STT plugin
- Configurable via environment variables

### 4. Automated Setup Scripts

**Linux/macOS** (`setup-stt.sh`):
- Builds Docker image
- Starts service
- Verifies health
- Provides clear next steps

**Windows** (`setup-stt.bat`):
- Same functionality for Windows users
- Handles Windows-specific commands

### 5. Docker Compose Configuration

Simple orchestration with:
- Single-command deployment
- Automatic health checks
- Volume management
- Port mapping

### 6. Comprehensive Documentation

- **README.md**: Updated with Parakeet setup instructions
- **DEPLOYMENT.md**: Comprehensive deployment guide
- **stt-service/README.md**: Service-specific documentation
- **.env-example**: Updated environment configuration

## Architecture

```
┌─────────────────────────────────────────┐
│         LiveKit Agent (agent.py)        │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Parakeet STT Plugin            │  │
│  │   (parakeet_stt.py)             │  │
│  └──────────┬───────────────────────┘  │
│             │ HTTP API calls            │
└─────────────┼───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│     Parakeet STT Service (Docker)       │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   FastAPI Server (app.py)        │  │
│  │   - OpenAI-compatible API        │  │
│  │   - Audio processing             │  │
│  │   - Model inference              │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Parakeet TDT 0.6B v3 Model    │  │
│  │   - ONNX Runtime                 │  │
│  │   - INT8 Quantization            │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Quick Start

### 1. Start STT Service

```bash
# Using automated script (Linux/macOS)
./setup-stt.sh

# Or using Docker Compose directly
docker compose up -d

# Windows
setup-stt.bat
```

### 2. Configure Agent

Update `.env.local`:

```env
# Parakeet STT Configuration
PARAKEET_BASE_URL=http://localhost:5092/v1
STT_MODEL=parakeet-tdt-0.6b-v3

# LiveKit Configuration
LIVEKIT_API_KEY=your_key
LIVEKIT_API_SECRET=your_secret
LIVEKIT_URL=wss://your-project.livekit.cloud

# LLM Configuration (choose one)
LLM_PROVIDER=deepseek
LLM_BASE_URL=https://api.deepseek.com
LLM_MODEL=deepseek-chat
OPENAI_API_KEY=your_deepseek_api_key

# TTS Configuration
KANI_BASE_URL=http://localhost:8000/v1
TTS_MODEL=nineninesix/kani-tts-400m-es
TTS_VOICE=andrew
```

### 3. Run Agent

```bash
uv run agent.py dev
```

## Key Features

### Parakeet STT Service Features

1. **Ultra-Fast Performance**
   - ~30x real-time on Intel i7-12700K
   - ~17x real-time on Intel i7-4790
   - Optimized for CPU with ONNX Runtime

2. **Multilingual Support**
   - 25 European languages
   - Automatic language detection
   - No manual language selection needed

3. **Intelligent Audio Processing**
   - Silence-based chunking for long files
   - Automatic format conversion
   - Support for 2GB+ audio files

4. **OpenAI-Compatible API**
   - Drop-in replacement for Whisper API
   - Multiple output formats
   - Compatible with existing tools

5. **Built-in Web Interface**
   - Drag-and-drop transcription
   - Real-time progress tracking
   - Export in multiple formats

### Integration Features

1. **Seamless LiveKit Integration**
   - Custom STT plugin
   - Async audio processing
   - Proper error handling

2. **Easy Configuration**
   - Environment-based setup
   - No code changes needed
   - Clear documentation

3. **Docker Deployment**
   - Single-command setup
   - Automatic health checks
   - Volume persistence

## Performance Benchmarks

| Hardware | Real-Time Factor | Speedup |
|----------|------------------|---------|
| i7-12700KF (P-cores) | 0.033 | ~30x |
| i7-4790 | 0.058 | ~17x |

## Supported Languages

English, Spanish, French, Russian, German, Italian, Polish, Ukrainian, Romanian, Dutch, Hungarian, Greek, Swedish, Czech, Bulgarian, Portuguese, Slovak, Croatian, Danish, Finnish, Lithuanian, Slovenian, Latvian, Estonian, Maltese

## File Structure

```
local-llamagente/
├── agent.py                    # Updated to use Parakeet STT
├── parakeet_stt.py            # Custom STT plugin for LiveKit
├── docker-compose.yml          # Docker orchestration
├── setup-stt.sh               # Setup script (Linux/macOS)
├── setup-stt.bat              # Setup script (Windows)
├── .env-example               # Updated with STT config
├── README.md                  # Updated documentation
├── DEPLOYMENT.md              # Updated deployment guide
├── pyproject.toml             # Updated dependencies
└── stt-service/               # Parakeet STT service
    ├── app.py                 # FastAPI application
    ├── requirements.txt       # Python dependencies
    ├── Dockerfile             # Container image
    ├── .dockerignore          # Docker ignore rules
    ├── README.md              # Service documentation
    ├── parakeet.png           # Logo
    └── templates/
        ├── index.html         # Web interface
        └── swagger.html       # API documentation
```

## Testing

### Verify STT Service

```bash
# Check health
curl http://localhost:5092/health

# Test transcription
curl -X POST http://localhost:5092/v1/audio/transcriptions \
  -H "Authorization: Bearer sk-no-key-required" \
  -F "file=@test.mp3" \
  -F "model=parakeet-tdt-0.6b-v3" \
  -F "response_format=text"
```

### Test with Agent

1. Start the STT service
2. Configure `.env.local`
3. Run `uv run agent.py dev`
4. Connect via LiveKit Playground or web frontend

## Troubleshooting

### STT Service Issues

```bash
# Check if service is running
docker compose ps

# View logs
docker compose logs -f parakeet-stt

# Restart service
docker compose restart parakeet-stt
```

### Common Issues

1. **Port already in use**: Change port in docker-compose.yml
2. **Model download slow**: First startup downloads models (~500MB)
3. **Out of memory**: Service requires ~2GB RAM

## Security Considerations

- ✅ Non-root user in Docker container
- ✅ Health checks for availability
- ✅ No external API calls
- ✅ All data processed locally
- ✅ Volume permissions properly set

## Future Enhancements

Potential improvements:
- GPU support via CUDA provider
- Additional language models
- Real-time streaming transcription
- Speaker diarization
- Custom model fine-tuning

## Credits

- **NVIDIA**: Parakeet TDT model
- **groxaxo**: ONNX optimization and OpenAI API compatibility
- **Shadowfita**: Original FastAPI implementation

## License

This implementation follows the MIT License of the main repository.
