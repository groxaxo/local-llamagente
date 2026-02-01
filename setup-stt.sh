#!/bin/bash

# Parakeet STT Service Setup and Test Script
# This script sets up and tests the Parakeet TDT STT service

set -e

echo "🎤 Parakeet TDT STT Service Setup"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker and Docker Compose are installed${NC}"
echo ""

# Build and start the service
echo "🔨 Building Parakeet STT Docker image..."
docker compose build parakeet-stt

echo ""
echo "🚀 Starting Parakeet STT service..."
docker compose up -d parakeet-stt

echo ""
echo "⏳ Waiting for service to be ready (this may take a minute)..."
sleep 10

# Check if service is running
if ! docker compose ps | grep -q "parakeet-stt.*running"; then
    echo -e "${RED}❌ Service failed to start${NC}"
    echo "Checking logs:"
    docker compose logs parakeet-stt
    exit 1
fi

echo -e "${GREEN}✓ Service is running${NC}"
echo ""

# Test the health endpoint
echo "🔍 Testing health endpoint..."
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:5092/health > /dev/null 2>&1; then
        HEALTH_RESPONSE=$(curl -s http://localhost:5092/health)
        echo -e "${GREEN}✓ Health check passed${NC}"
        echo "Response: $HEALTH_RESPONSE"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo -e "${YELLOW}Waiting for service... (attempt $RETRY_COUNT/$MAX_RETRIES)${NC}"
        sleep 2
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo -e "${RED}❌ Service health check failed after $MAX_RETRIES attempts${NC}"
    echo "Checking logs:"
    docker compose logs parakeet-stt
    exit 1
fi

echo ""
echo "✅ Parakeet STT Service Setup Complete!"
echo ""
echo "Service Information:"
echo "  - URL: http://localhost:5092"
echo "  - API Endpoint: http://localhost:5092/v1/audio/transcriptions"
echo "  - Web Interface: http://localhost:5092"
echo "  - Health Check: http://localhost:5092/health"
echo ""
echo "To view logs:"
echo "  docker compose logs -f parakeet-stt"
echo ""
echo "To stop the service:"
echo "  docker compose down"
echo ""
echo "Next steps:"
echo "  1. Configure your .env.local file with:"
echo "     PARAKEET_BASE_URL=http://localhost:5092/v1"
echo "     STT_MODEL=parakeet-tdt-0.6b-v3"
echo "  2. Start the agent: uv run agent.py dev"
echo ""
