#!/bin/bash

# Voice AI Agent Auto Installer
# Supports Linux and macOS

set -e

echo "========================================="
echo "Voice AI Agent - Auto Installer"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN"
esac

print_info "Detected OS: $MACHINE"
echo ""

# Step 1: Check Python version
print_info "Checking Python version..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
    
    if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 10 ]; then
        print_success "Python $PYTHON_VERSION found"
    else
        print_error "Python 3.10+ required. Found: $PYTHON_VERSION"
        exit 1
    fi
else
    print_error "Python 3.10+ not found. Please install Python first."
    exit 1
fi
echo ""

# Step 2: Install uv package manager
print_info "Checking for uv package manager..."
if command -v uv &> /dev/null; then
    print_success "uv already installed"
else
    print_info "Installing uv package manager..."
    if [ "$MACHINE" = "Mac" ] && command -v brew &> /dev/null; then
        brew install uv
    else
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    print_success "uv installed"
fi
echo ""

# Step 3: Install LiveKit CLI
print_info "Checking for LiveKit CLI..."
if command -v lk &> /dev/null; then
    print_success "LiveKit CLI already installed"
else
    print_info "Installing LiveKit CLI..."
    if [ "$MACHINE" = "Mac" ]; then
        if command -v brew &> /dev/null; then
            brew install livekit-cli
            print_success "LiveKit CLI installed via Homebrew"
        else
            print_error "Homebrew not found. Please install it first: https://brew.sh"
            exit 1
        fi
    elif [ "$MACHINE" = "Linux" ]; then
        curl -sSL https://get.livekit.io/cli | bash
        print_success "LiveKit CLI installed"
    else
        print_error "Unsupported OS for automatic LiveKit CLI installation"
        exit 1
    fi
fi
echo ""

# Step 4: Install project dependencies
print_info "Installing project dependencies..."
uv sync
print_success "Dependencies installed"
echo ""

# Step 5: Download model files
print_info "Downloading required model files..."
uv run agent.py download-files
print_success "Model files downloaded"
echo ""

# Step 6: Setup environment variables
print_info "Setting up environment variables..."
if [ ! -f .env.local ]; then
    cp .env-example .env.local
    print_success "Created .env.local from template"
    
    echo ""
    echo "========================================="
    echo "Environment Configuration"
    echo "========================================="
    echo ""
    
    # LiveKit Configuration
    echo "Would you like to configure LiveKit now? (y/n)"
    read -r configure_livekit
    
    if [ "$configure_livekit" = "y" ] || [ "$configure_livekit" = "Y" ]; then
        echo ""
        print_info "LiveKit Cloud authentication..."
        lk cloud auth || true
        
        echo ""
        print_info "Generating LiveKit environment variables..."
        lk app env -w || true
    fi
    
    # API Keys
    echo ""
    echo "You'll need to configure API keys in .env.local based on your chosen providers:"
    echo "  - For OpenAI: Get API key from https://platform.openai.com/"
    echo "  - For DeepSeek: Get API key from https://platform.deepseek.com/"
    echo "  - For local providers (Ollama, vLLM, etc.): Use 'not-needed'"
    echo "  - Local Parakeet STT: No API key required (runs via Docker)"
    echo ""
    echo "Would you like to enter your LLM API key now? (y/n)"
    read -r configure_keys
    
    if [ "$configure_keys" = "y" ] || [ "$configure_keys" = "Y" ]; then
        echo ""
        echo -n "Enter your LLM API key (OpenAI/DeepSeek) or 'not-needed' for local: "
        read -r openai_key
        if [ -n "$openai_key" ]; then
            if [ "$MACHINE" = "Mac" ]; then
                sed -i '' "s/OPENAI_API_KEY=\"\"/OPENAI_API_KEY=\"$openai_key\"/" .env.local
            else
                sed -i "s/OPENAI_API_KEY=\"\"/OPENAI_API_KEY=\"$openai_key\"/" .env.local
            fi
            print_success "API key saved to .env.local"
        fi
    fi
else
    print_success ".env.local already exists"
fi
echo ""

# Step 7: Installation complete
echo "========================================="
echo "Installation Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Configure API keys in .env.local for your chosen providers"
echo "  2. (Optional) Start local STT: docker compose up -d"
echo "  3. Start the agent: uv run agent.py dev"
echo "  4. Open the frontend: open frontend/index.html (or use a local server)"
echo ""
echo "For more configuration options, see README.md"
echo ""
print_success "You're all set! Happy building!"
