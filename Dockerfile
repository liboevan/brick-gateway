FROM ghcr.io/max-lt/nginx-jwt-module:latest

# Build arguments
ARG VERSION=0.1.0-dev
ARG BUILD_DATETIME

# Set environment variables
ENV VERSION=$VERSION
ENV BUILD_DATETIME=$BUILD_DATETIME

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY jwt_secret.key /etc/nginx/jwt_secret.key
COPY public.pem /etc/nginx/public.pem

# Create necessary directories
RUN mkdir -p /var/log/nginx /var/www/html

# Create build-info.json
RUN echo '{"version":"'$VERSION'","buildDateTime":"'$BUILD_DATETIME'","service":"brick-gateway","description":"API Gateway Service"}' > /var/www/html/build-info.json

# Expose port 17000 (and 443 for HTTPS)
EXPOSE 17000 443

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 