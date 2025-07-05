# Nginx Reverse Proxy

This directory contains the Nginx reverse proxy configuration for the Vue Gate application with API backend support.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx Proxy   │    │   Vue Frontend  │    │   API Backend   │
│   (Port 80/443) │◄──►│   (Port 80)     │    │   (Port 8000)   │
│   Container     │    │   Container     │    │   Container     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Features

- **Reverse Proxy**: Routes requests to appropriate services
- **API Routing**: `/api/*` requests go to backend
- **Frontend Routing**: All other requests serve Vue app
- **CORS Support**: Handles cross-origin requests
- **Static Asset Caching**: Optimized for performance
- **Health Checks**: Built-in monitoring
- **SSL Ready**: HTTPS configuration included

## Usage

### Start All Services

```bash
# From the nginx-proxy directory
docker-compose up --build
```

### Access Points

- **Frontend**: http://localhost (Vue application)
- **API**: http://localhost/api (Backend API)
- **Health Check**: http://localhost/health

## Configuration

### Nginx Configuration (`nginx.conf`)

The main configuration handles:

1. **API Proxy**: Routes `/api/*` to backend service
2. **Frontend Proxy**: Routes all other requests to Vue app
3. **CORS Headers**: Enables cross-origin requests
4. **Static Caching**: Optimizes asset delivery
5. **Security Headers**: Protects against common attacks

### Docker Compose (`docker-compose.yml`)

Defines three services:

1. **nginx-proxy**: The reverse proxy
2. **vue-gate**: Vue frontend application
3. **api-backend**: Backend API (placeholder)

## Customization

### Adding Your API Backend

Replace the placeholder API service in `docker-compose.yml`:

```yaml
api-backend:
  build: ../brick-your-api-directory
  container_name: your-api
  restart: unless-stopped
  networks:
    - app-network
```

### SSL/HTTPS Setup

1. Add SSL certificates to the container
2. Uncomment HTTPS server block in `nginx.conf`
3. Update certificate paths

### Environment Variables

Create a `.env` file for configuration:

```env
API_URL=http://api-backend:8000
VUE_URL=http://vue-gate:80
DOMAIN=yourdomain.com
```

## Development

### Local Development

For development, you can run services individually:

```bash
# Run Vue app in development mode
cd ../brick-gate-ui
npm run dev

# Run API backend
cd ../your-api
npm run dev

# Run only nginx proxy
docker-compose up nginx-proxy
```

### Production Deployment

```bash
# Build and start all services
docker-compose -f docker-compose.yml up --build -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Troubleshooting

### Check Service Status

```bash
# Check all containers
docker-compose ps

# Check nginx logs
docker-compose logs nginx-proxy

# Check specific service
docker-compose logs vue-gate
```

### Common Issues

1. **Port Conflicts**: Ensure ports 80/443 are available
2. **Network Issues**: Check Docker network connectivity
3. **CORS Errors**: Verify API proxy configuration
4. **Vue Router Issues**: Ensure proper proxy configuration

## Security Considerations

- The configuration includes security headers
- CORS is properly configured for API access
- Consider adding rate limiting for production
- Implement proper authentication for API endpoints 