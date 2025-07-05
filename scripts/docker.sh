#!/bin/bash

# Docker Management Script for Brick Gateway
# For building and running the gateway service

set -e

ACTION=${1:-help}

case $ACTION in
    "build")
        echo "🔨 Building Brick Gateway..."
        docker build -t el/brick-gateway ..
        echo "✅ Gateway built successfully!"
        ;;
    
    "run")
        echo "🚀 Running Brick Gateway..."
        docker run -d --name el-brick-gateway -p 17000:17000 el/brick-gateway
        echo "✅ Gateway running at http://localhost:17000"
        ;;
    
    "stop")
        echo "🛑 Stopping Brick Gateway..."
        docker stop el-brick-gateway
        docker rm el-brick-gateway
        echo "✅ Gateway stopped and removed"
        ;;
    
    "restart")
        echo "🔄 Restarting Brick Gateway..."
        docker stop el-brick-gateway 2>/dev/null || true
        docker rm el-brick-gateway 2>/dev/null || true
        docker run -d --name el-brick-gateway -p 17000:17000 el/brick-gateway
        echo "✅ Gateway restarted at http://localhost:17000"
        ;;
    
    "logs")
        echo "📊 Showing gateway logs..."
        docker logs -f el-brick-gateway
        ;;
    
    "clean")
        echo "🧹 Cleaning up gateway..."
        docker stop el-brick-gateway 2>/dev/null || true
        docker rm el-brick-gateway 2>/dev/null || true
        docker rmi el/brick-gateway 2>/dev/null || true
        echo "✅ Gateway cleanup completed"
        ;;
    
    "build-and-run")
        echo "🔨 Building and running gateway..."
        docker build -t el/brick-gateway ..
        docker stop el-brick-gateway 2>/dev/null || true
        docker rm el-brick-gateway 2>/dev/null || true
        docker run -d --name el-brick-gateway -p 17000:17000 el/brick-gateway
        echo "✅ Gateway running at http://localhost:17000"
        ;;
    
    "test-routes")
        echo "🧪 Testing gateway routes..."
        echo "Testing clock API..."
        curl -s http://localhost:17000/api/clock/ntp/current-time || echo "❌ Clock API failed"
        echo "Testing sentinel API..."
        curl -s http://localhost:17000/api/sentinel/health || echo "❌ Sentinel API failed"
        echo "Testing login API..."
        curl -s http://localhost:17000/api/login || echo "❌ Login API failed"
        echo "Testing frontend..."
        curl -s http://localhost:17000/ | head -1 || echo "❌ Frontend failed"
        ;;
    
    "help"|*)
        echo "Brick Gateway Docker Management Script"
        echo ""
        echo "Usage: ./scripts/docker.sh [action]"
        echo ""
        echo "Actions:"
        echo "  build         - Build gateway Docker image"
        echo "  run           - Run gateway container"
        echo "  stop          - Stop gateway container"
        echo "  restart       - Restart gateway container"
        echo "  logs          - Show gateway logs"
        echo "  clean         - Clean up gateway"
        echo "  build-and-run - Build and run in one command"
        echo "  test-routes   - Test all gateway routes"
        echo "  help          - Show this help"
        echo ""
        echo "Examples:"
        echo "  ./scripts/docker.sh build-and-run"
        echo "  ./scripts/docker.sh test-routes"
        echo ""
        echo "Gateway Routes:"
        echo "  http://localhost:17000/api/clock/* -> brick-clock:17003"
        echo "  http://localhost:17000/api/sentinel/* -> brick-sentinel:17001"
        echo "  http://localhost:17000/api/login -> brick-sentinel:17001/api/sentinel/login"
        echo "  http://localhost:17000/* -> brick-hub:17002"
        ;;
esac 