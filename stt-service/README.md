# Parakeet TDT STT Service

High-performance, multilingual speech-to-text service with OpenAI-compatible API.

## Features

- ⚡ Ultra-fast (~30x real-time on modern CPUs)
- 🌍 25+ languages with automatic detection
- 🔌 OpenAI-compatible API (drop-in Whisper replacement)
- 🐳 Docker ready
- 🔒 Fully local, no external API calls

## Quick Start

### Using Docker Compose (Recommended)

From project root:

```bash
docker compose up -d
curl http://localhost:5092/health  # Verify
```

### Manual Docker Build

```bash
cd stt-service
docker build -t parakeet-stt .
docker run -d -p 5092:5092 parakeet-stt
```

### Local Development

```bash
cd stt-service
pip install -r requirements.txt
python app.py
```

## API Usage

### Transcribe Audio

```bash
curl -X POST http://localhost:5092/v1/audio/transcriptions \
  -F "file=@audio.mp3" \
  -F "model=parakeet-tdt-0.6b-v3" \
  -F "response_format=json"
```

### Python Client

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:5092/v1",
    api_key="not-required"
)

with open("audio.mp3", "rb") as f:
    transcript = client.audio.transcriptions.create(
        model="parakeet-tdt-0.6b-v3",
        file=f
    )
print(transcript.text)
```

## Web Interface

Access at `http://localhost:5092` for drag-and-drop transcription.

## Configuration

- **Port**: 5092
- **Max file size**: 2000 MB
- **Supported formats**: mp3, wav, m4a, flac, ogg, and more

## Performance

| Hardware | Real-Time Factor | Speedup |
|----------|------------------|---------|
| i7-12700KF | 0.033 | ~30x |
| i7-4790 | 0.058 | ~17x |

## Supported Languages

English, Spanish, French, Russian, German, Italian, Polish, Ukrainian, Romanian, Dutch, Hungarian, Greek, Swedish, Czech, Bulgarian, Portuguese, Slovak, Croatian, Danish, Finnish, Lithuanian, Slovenian, Latvian, Estonian, Maltese

## Troubleshooting

**Service won't start:**
```bash
docker compose logs parakeet-stt  # Check logs
lsof -i :5092  # Check port usage
```

**Model download issues:**
- First run downloads ~500MB of models
- Requires internet connection
- Models cached in `models/` directory

For more details, see the [main README](../README.md).

## Credits

- **NVIDIA**: Parakeet TDT model
- **groxaxo**: ONNX optimization and OpenAI API compatibility
- **Shadowfita**: Original FastAPI implementation

## License

MIT License - See main repository LICENSE
