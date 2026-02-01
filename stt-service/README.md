# Parakeet TDT STT Service

This directory contains the Parakeet TDT 0.6B v3 speech-to-text service that provides high-performance, multilingual transcription for the voice AI agent.

## Features

- **Ultra-fast transcription**: ~30x real-time speedup on modern CPUs
- **Multilingual support**: Automatic language detection across 25 languages
- **OpenAI-compatible API**: Drop-in replacement for OpenAI Whisper API
- **CPU optimized**: Runs efficiently on consumer hardware without GPU
- **Docker ready**: Easy deployment with pre-configured Docker container

## Supported Languages

English, Spanish, French, Russian, German, Italian, Polish, Ukrainian, Romanian, Dutch, Hungarian, Greek, Swedish, Czech, Bulgarian, Portuguese, Slovak, Croatian, Danish, Finnish, Lithuanian, Slovenian, Latvian, Estonian, Maltese

## Quick Start with Docker

### Using Docker Compose (Recommended)

From the project root directory:

```bash
# Start the STT service
docker compose up -d

# Check logs
docker compose logs -f parakeet-stt

# Stop the service
docker compose down
```

The service will be available at `http://localhost:5092`

### Building the Docker Image Manually

```bash
cd stt-service
docker build -t parakeet-stt .
docker run -d -p 5092:5092 --name parakeet-stt parakeet-stt
```

## Local Development (without Docker)

### Prerequisites

- Python 3.10+
- FFmpeg

### Installation

```bash
cd stt-service
pip install -r requirements.txt
```

### Running the Service

```bash
python app.py
```

The service will start on `http://localhost:5092`

## API Usage

### Transcribe Audio

```bash
curl -X POST http://localhost:5092/v1/audio/transcriptions \
  -H "Authorization: Bearer sk-no-key-required" \
  -F "file=@audio.mp3" \
  -F "model=parakeet-tdt-0.6b-v3" \
  -F "response_format=json"
```

### Response Formats

- `json` (default): `{"text": "transcription..."}`
- `text`: Plain text transcription
- `srt`: SubRip subtitle format
- `vtt`: WebVTT subtitle format
- `verbose_json`: Detailed response with segments and metadata

### Python Client Example

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:5092/v1",
    api_key="sk-no-key-required"
)

with open("audio.mp3", "rb") as audio_file:
    transcript = client.audio.transcriptions.create(
        model="parakeet-tdt-0.6b-v3",
        file=audio_file,
        response_format="text"
    )
    
print(transcript)
```

## Web Interface

Access the built-in web interface at `http://localhost:5092` for easy drag-and-drop transcription.

## Health Check

```bash
curl http://localhost:5092/health
```

## Configuration

The service uses these default configurations:

- **Port**: 5092
- **Threads**: 8 (optimized for modern CPUs)
- **Max file size**: 2000 MB
- **Chunk duration**: 90 seconds (for long audio files)

## Performance

On Intel Core i7-12700K:
- **Average speedup**: ~30x real-time
- **Real-Time Factor (RTF)**: 0.033
- **Supports**: Multi-hour audio files with intelligent chunking

## Troubleshooting

### Service won't start

1. Check if port 5092 is available:
   ```bash
   lsof -i :5092
   ```

2. Check Docker logs:
   ```bash
   docker compose logs parakeet-stt
   ```

### Model download issues

The ONNX models are automatically downloaded on first run. If download fails:

1. Ensure you have internet connection
2. Check available disk space (~500MB required)
3. Models are cached in the `models/` directory

### Transcription errors

1. Verify FFmpeg is installed:
   ```bash
   ffmpeg -version
   ```

2. Check audio file format is supported (mp3, wav, m4a, etc.)

3. For large files, ensure enough disk space for temporary files

## Credits

- **NVIDIA**: Original Parakeet TDT model
- **groxaxo**: ONNX optimization and OpenAI API compatibility
- **Shadowfita**: Original FastAPI implementation

## License

MIT License - See main repository LICENSE file
