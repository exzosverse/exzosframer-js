#!/bin/bash

# ========================================
# ExzosFramer.js Self-Hosted Runner Setup
# For macOS M4 (ARM64) Architecture
# ========================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RUNNER_VERSION="2.328.0"
RUNNER_HASH="30e8c9e34ae3f1f5004d0fd6eb4e42714d1b489ca9c91f5eed3bcbd29c6f446d"
REPO_URL="https://github.com/exzosverse/exzosframer-js"
RUNNER_NAME="${RUNNER_NAME:-exzos-m4-runner-$(hostname -s)}"
RUNNER_WORK_DIR="${RUNNER_WORK_DIR:-_work}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,macOS,ARM64,M4}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}ExzosFramer.js Self-Hosted Runner Setup${NC}"
echo -e "${BLUE}macOS M4 (ARM64) Configuration${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: This script is for macOS only${NC}"
    exit 1
fi

# Check for ARM64 architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" ]]; then
    echo -e "${YELLOW}Warning: Not running on ARM64 architecture (detected: $ARCH)${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Function to setup runner
setup_runner() {
    local TOKEN=$1

    # Create runner directory
    echo -e "${GREEN}Creating runner directory...${NC}"
    mkdir -p ~/actions-runner-exzos && cd ~/actions-runner-exzos

    # Download runner
    echo -e "${GREEN}Downloading GitHub Actions Runner v${RUNNER_VERSION}...${NC}"
    curl -o actions-runner-osx-arm64-${RUNNER_VERSION}.tar.gz -L \
        https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-osx-arm64-${RUNNER_VERSION}.tar.gz

    # Validate hash
    echo -e "${GREEN}Validating download hash...${NC}"
    echo "${RUNNER_HASH}  actions-runner-osx-arm64-${RUNNER_VERSION}.tar.gz" | shasum -a 256 -c

    # Extract runner
    echo -e "${GREEN}Extracting runner...${NC}"
    tar xzf ./actions-runner-osx-arm64-${RUNNER_VERSION}.tar.gz

    # Configure runner
    echo -e "${GREEN}Configuring runner...${NC}"
    ./config.sh \
        --url "$REPO_URL" \
        --token "$TOKEN" \
        --name "$RUNNER_NAME" \
        --labels "$RUNNER_LABELS" \
        --work "$RUNNER_WORK_DIR" \
        --unattended \
        --replace

    echo -e "${GREEN}Runner configured successfully!${NC}"
}

# Function to create launch agent for auto-start
create_launch_agent() {
    echo -e "${GREEN}Creating launch agent for auto-start...${NC}"

    PLIST_FILE=~/Library/LaunchAgents/com.exzosframer.runner.plist

    cat > "$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.exzosframer.runner</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/actions-runner-exzos/run.sh</string>
    </array>
    <key>WorkingDirectory</key>
    <string>$HOME/actions-runner-exzos</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
        <key>Crashed</key>
        <true/>
    </dict>
    <key>StandardOutPath</key>
    <string>$HOME/actions-runner-exzos/runner.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/actions-runner-exzos/runner.error.log</string>
</dict>
</plist>
EOF

    # Load the launch agent
    launchctl load "$PLIST_FILE" 2>/dev/null || true

    echo -e "${GREEN}Launch agent created and loaded!${NC}"
}

# Function to install dependencies
install_dependencies() {
    echo -e "${GREEN}Checking and installing dependencies...${NC}"

    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Install required tools
    echo -e "${GREEN}Installing required tools...${NC}"
    brew install git node@20 npm gh docker || true

    # Install pnpm
    if ! command -v pnpm &> /dev/null; then
        echo -e "${GREEN}Installing pnpm...${NC}"
        npm install -g pnpm
    fi

    echo -e "${GREEN}Dependencies installed!${NC}"
}

# Function to optimize for M4
optimize_for_m4() {
    echo -e "${GREEN}Optimizing for Apple M4 chip...${NC}"

    # Set environment variables for optimal performance
    cat >> ~/.zshrc <<'EOF'

# GitHub Actions Runner Optimizations for M4
export RUNNER_ALLOW_RUNASROOT="0"
export ACTIONS_RUNNER_HOOK_JOB_STARTED="$HOME/actions-runner-exzos/hooks/job-started.sh"
export ACTIONS_RUNNER_HOOK_JOB_COMPLETED="$HOME/actions-runner-exzos/hooks/job-completed.sh"

# Node.js optimizations for M4
export NODE_OPTIONS="--max-old-space-size=8192"
export UV_THREADPOOL_SIZE=16

# Docker optimizations for M4
export DOCKER_DEFAULT_PLATFORM=linux/arm64
EOF

    # Create hooks directory
    mkdir -p ~/actions-runner-exzos/hooks

    # Create job-started hook
    cat > ~/actions-runner-exzos/hooks/job-started.sh <<'EOF'
#!/bin/bash
echo "🚀 Job started on ExzosFramer M4 Runner"
echo "📊 System Info:"
system_profiler SPHardwareDataType | grep -E "Chip|Memory|Cores" || true
EOF

    # Create job-completed hook
    cat > ~/actions-runner-exzos/hooks/job-completed.sh <<'EOF'
#!/bin/bash
echo "✅ Job completed on ExzosFramer M4 Runner"
EOF

    chmod +x ~/actions-runner-exzos/hooks/*.sh

    echo -e "${GREEN}M4 optimizations applied!${NC}"
}

# Main execution
main() {
    echo -e "${YELLOW}Prerequisites:${NC}"
    echo "1. You need a runner registration token from GitHub"
    echo "2. Go to: Settings → Actions → Runners → New self-hosted runner"
    echo "3. Copy the token (it starts with 'BTYZR')"
    echo ""

    read -p "Enter your runner registration token: " TOKEN

    if [[ -z "$TOKEN" ]]; then
        echo -e "${RED}Error: Token is required${NC}"
        exit 1
    fi

    # Install dependencies
    install_dependencies

    # Setup runner
    setup_runner "$TOKEN"

    # Optimize for M4
    optimize_for_m4

    # Create launch agent
    read -p "Do you want to setup auto-start on login? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_launch_agent
    fi

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ Runner Setup Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "To start the runner manually:"
    echo "  cd ~/actions-runner-exzos && ./run.sh"
    echo ""
    echo "To use in workflows, add to your YAML:"
    echo "  runs-on: self-hosted"
    echo "  # or with labels:"
    echo "  runs-on: [self-hosted, macOS, ARM64, M4]"
    echo ""
    echo "To stop the runner:"
    echo "  Press Ctrl+C in the runner terminal"
    echo ""
    echo "To remove the runner:"
    echo "  cd ~/actions-runner-exzos && ./config.sh remove"
    echo ""
}

# Run main function
main