# Brick Gateway

> 中文版请见: [README.md](README.md)

Brick Gateway is an Nginx-based API gateway service that provides JWT authentication, reverse proxy, and routing management functionality.

## Project Overview

Brick Gateway serves as the unified entry point for the entire Brick system, responsible for routing, authentication, and forwarding all external requests. It integrates JWT authentication modules to provide secure API access control.

- **JWT Authentication Gateway**: JWT token verification based on RSA key pairs
- **Smart Routing**: Automatically forwards requests to appropriate backend services based on paths
- **Security Protection**: Built-in security headers and CORS configuration
- **Performance Optimization**: Static resource caching and Gzip compression

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Brick Gateway │    │   Brick Hub     │    │   Brick Auth    │
│   (Port 17000)  │◄──►│   (Port 17002)  │    │   (Port 17001)  │
│   (API Gateway) │    │   (Frontend)    │    │   (Auth Service)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Brick Clock   │    │   Static Assets │    │   JWT Validation│
│   (Port 17003)  │    │   (Cached)      │    │   (RSA Keys)    │
│   (Clock API)   │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Core Features

### 🔐 JWT Authentication
- **RSA Key Verification**: Uses RSA public key to verify JWT tokens
- **Permission Control**: Access control based on permissions in tokens
- **Automatic Validation**: Automatic token validation for protected API endpoints

### 🌐 Smart Routing
- **Auth API**: `/api/auth/*` → brick-auth service
- **Clock API**: `/api/clock/*` → brick-clock service (requires authentication)
- **NTP API**: `/api/ntp/*` → brick-clock service (requires authentication)
- **Frontend App**: `/*` → brick-hub service

### 🛡️ Security Features
- **Security Headers**: X-Frame-Options, X-XSS-Protection, etc.
- **CORS Support**: Complete cross-origin resource sharing configuration
- **Request Filtering**: Automatic filtering of malicious requests

### ⚡ Performance Optimization
- **Static Caching**: JavaScript, CSS, images, and other static resource caching
- **Gzip Compression**: Automatic compression of text-type responses
- **Connection Pooling**: Optimized upstream connection management

## Directory Structure

```
brick-gateway/
├── nginx.conf              # Main configuration file
├── nginx-auth_request.conf # Authentication request configuration
├── Dockerfile              # Container build file
├── public.pem              # RSA public key file
├── scripts/                # Management scripts
│   ├── build.sh           # Build script
│   ├── run.sh             # Run script
│   ├── clean.sh           # Cleanup script
│   ├── config.sh          # Configuration script
│   └── quick_start.sh     # Quick start script
└── README.md              # This documentation
```

## Quick Start

### Build Image
```bash
./scripts/build.sh [version]
```

### Run Service
```bash
./scripts/run.sh [version]
```

### Quick Start (Build + Run)
```bash
./scripts/quick_start.sh [action] [version]
```

### Clean Resources
```bash
./scripts/clean.sh [--image]
```

### Check Status
```bash
./scripts/quick_start.sh status
```

### View Logs
```bash
./scripts/quick_start.sh logs
```

### Health Check
```bash
curl http://localhost:17000/health
```

## API Routes

### Public Endpoints
- `GET /` - Frontend application (brick-hub)
- `GET /health` - Health check
- `GET /build-info.json` - Build information

### Authentication Endpoints (No JWT Required)
- `POST /api/auth/login` - User login
- `POST /api/auth/validate` - Validate token
- `GET /api/auth/me` - Get user information
- `POST /api/auth/refresh` - Refresh token

### Protected Endpoints (JWT Required)
- `GET /api/clock/*` - Clock service API
- `POST /api/clock/*` - Clock service API
- `GET /api/ntp/*` - NTP service API
- `POST /api/ntp/*` - NTP service API

### Compatibility Endpoints
- `POST /login` - Compatibility login endpoint
- `POST /validate` - Compatibility validation endpoint
- `POST /refresh` - Compatibility refresh endpoint
- `GET /me` - Compatibility user info endpoint

## Configuration

### Environment Variables
- `VERSION` - Service version (default: 0.1.0-dev)
- `BUILD_DATETIME` - Build timestamp
- `API_PORT` - Service port (default: 17000)

### Upstream Service Configuration
```nginx
upstream brick_clock {
    server el-brick-clock:17003;
}

upstream brick_hub {
    server el-brick-hub:17002;
}

upstream brick_auth {
    server el-brick-auth:17001;
}
```

### JWT Configuration
- **Algorithm**: RS256
- **Key File**: /etc/nginx/public.pem
- **Token Extraction**: Extract Bearer token from Authorization header

## Security Configuration

### Security Headers
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
```

### CORS Configuration
```nginx
add_header Access-Control-Allow-Origin * always;
add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization" always;
```

## Performance Optimization

### Static Resource Caching
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    add_header Vary Accept-Encoding;
}
```

### Gzip Compression
```nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript;
```

## Monitoring and Logging

### Log Configuration
- **Access Log**: /var/log/nginx/access.log
- **Error Log**: /var/log/nginx/error.log
- **Log Format**: Includes IP, time, request, status code, and other information

### Health Check
- **Endpoint**: http://localhost:17000/health
- **Check Interval**: 30 seconds
- **Timeout**: 3 seconds
- **Retries**: 3 times

## Troubleshooting

### Common Issues

1. **JWT Validation Failure**
   - Check if public.pem file exists
   - Verify RSA public key format is correct
   - Confirm token format and algorithm

2. **Upstream Service Connection Failure**
   - Check Docker network configuration
   - Verify upstream services are running normally
   - Confirm service ports are correct

3. **CORS Errors**
   - Check CORS header configuration
   - Verify preflight request handling
   - Confirm allowed domains and methods

### Debug Commands

```bash
# Check container status
docker ps | grep brick-gateway

# View gateway logs
docker logs el-brick-gateway

# Test health check
curl http://localhost:17000/health

# Test authentication endpoint
curl -X POST http://localhost:17000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"brick-admin","password":"brickpass"}'

# Test protected endpoint
curl -H "Authorization: Bearer <token>" \
  http://localhost:17000/api/clock/status
```

## Script Usage

### build.sh
Build Docker image
```bash
./scripts/build.sh [version]
```

### run.sh
Run container
```bash
./scripts/run.sh [version]
```

### clean.sh
Clean containers and images
```bash
./scripts/clean.sh [--image]
```

### quick_start.sh
Quick start and test
```bash
./scripts/quick_start.sh [action] [version]
# action: build, run, test, clean, logs, status, all
```

## Technology Stack

- **Nginx**: High-performance web server and reverse proxy
- **JWT Module**: JWT authentication module
- **Docker**: Containerized deployment
- **RSA Encryption**: JWT token signature verification
- **Gzip Compression**: Response compression optimization
- **Static Caching**: Resource caching strategy

## Version Information

- **Current Version**: 0.1.0-dev
- **Build Time**: 2025-07-10T13:00:00Z
- **Service Name**: brick-gateway
- **Description**: API Gateway Service 