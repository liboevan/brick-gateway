#!/bin/bash

# Quick Start Script for Brick Gateway Service
# Build, run, and launch the gateway service by default
# Usage: ./quick_start.sh [action] [version] or ./quick_start.sh [version]
# Actions: build, run, test, clean, all (default)

set -e

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# If the first argument looks like a version, treat it as version and use default action 'all'
if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
    ACTION=all
    VERSION_ARG=$1
else
    ACTION=${1:-all}
    VERSION_ARG=$2
fi

echo "🚀 Brick Gateway Quick Start Script"
echo "==================================="

case $ACTION in
    "build")
        print_header "Build"
        "$SCRIPT_DIR/build.sh" $VERSION_ARG
        ;;
    
    "run")
        print_header "Run"
        "$SCRIPT_DIR/run.sh" $VERSION_ARG
        ;;
    
    "test")
        print_header "Test"
        print_info "Testing gateway routes..."
        echo "Testing clock API..."
        curl -s http://localhost:$API_PORT/api/clock/ntp/current-time || echo "❌ Clock API failed"
        echo "Testing sentinel API..."
        curl -s http://localhost:$API_PORT/api/sentinel/health || echo "❌ Sentinel API failed"
        echo "Testing login API..."
        curl -s http://localhost:$API_PORT/api/login || echo "❌ Login API failed"
        echo "Testing frontend..."
        curl -s http://localhost:$API_PORT/ | head -1 || echo "❌ Frontend failed"
        ;;
    
    "clean")
        print_header "Clean"
        "$SCRIPT_DIR/clean.sh" $2
        ;;
    
    "logs")
        print_info "Showing container logs..."
        docker logs -f $CONTAINER_NAME
        ;;
    
    "status")
        print_info "Container Status:"
        docker ps -a --filter name=$CONTAINER_NAME
        echo ""
        print_info "Gateway URL:"
        echo "   http://localhost:$API_PORT"
        ;;
    
    "all"|*)
        print_header "Full Cycle: Build → Run → Launch"
        
        # Build
        "$SCRIPT_DIR/build.sh" $VERSION_ARG
        echo ""
        
        # Run
        "$SCRIPT_DIR/run.sh" $VERSION_ARG
        echo ""
        
        # Wait for gateway to be ready
        wait_for_api
        echo ""
        
        print_info "Gateway is ready!"
        print_info "Gateway Routes:"
        echo "   http://localhost:$API_PORT/api/clock/* -> brick-clock:17003"
        echo "   http://localhost:$API_PORT/api/sentinel/* -> brick-sentinel:17001"
        echo "   http://localhost:$API_PORT/api/login -> brick-sentinel:17001/api/sentinel/login"
        echo "   http://localhost:$API_PORT/* -> brick-hub:17002"
        
        echo ""
        print_info "Quick start completed!"
        echo "   Gateway: http://localhost:$API_PORT"
        echo "   Logs: ./scripts/quick_start.sh logs"
        echo "   Status: ./scripts/quick_start.sh status"
        ;;
esac 