FROM ghcr.io/max-lt/nginx-jwt-module:latest

# Remove default configurations
RUN rm -rf /etc/nginx/conf.d/* /etc/nginx/sites-enabled/* /etc/nginx/sites-available/*

# Copy custom configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY public.pem /etc/nginx/public.pem

# Create necessary directories
RUN mkdir -p /var/log/nginx /var/www/html

# Set build arguments and environment variables
ARG VERSION=0.1.0-dev
ARG BUILD_DATETIME
ENV VERSION=$VERSION
ENV BUILD_DATETIME=$BUILD_DATETIME

# Create build-info.json
RUN echo '{"version":"'$VERSION'","buildDateTime":"'$BUILD_DATETIME'","service":"brick-gateway","description":"API Gateway Service"}' > /var/www/html/build-info.json

# Expose port
EXPOSE 17000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl http://localhost:17000/health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]