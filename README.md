# Brick Gateway

> English version: [README.en.md](README.en.md)

Brick Gateway 是一个基于 Nginx 的 API 网关服务，提供 JWT 认证、反向代理和路由管理功能。

## 项目简介

Brick Gateway 作为整个 Brick 系统的统一入口，负责处理所有外部请求的路由、认证和转发。它集成了 JWT 认证模块，提供安全的 API 访问控制。

- **JWT 认证网关**：基于 RSA 密钥对的 JWT 令牌验证
- **智能路由**：根据路径自动转发到相应的后端服务
- **安全防护**：内置安全头部和 CORS 配置
- **性能优化**：静态资源缓存和 Gzip 压缩

## 系统架构

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

## 核心功能

### 🔐 JWT 认证
- **RSA 密钥验证**：使用 RSA 公钥验证 JWT 令牌
- **权限控制**：基于令牌中的权限信息进行访问控制
- **自动验证**：对受保护的 API 端点自动进行令牌验证

### 🌐 智能路由
- **认证 API**：`/api/auth/*` → brick-auth 服务
- **时钟 API**：`/api/clock/*` → brick-clock 服务（需要认证）
- **NTP API**：`/api/ntp/*` → brick-clock 服务（需要认证）
- **前端应用**：`/*` → brick-hub 服务

### 🛡️ 安全特性
- **安全头部**：X-Frame-Options、X-XSS-Protection 等
- **CORS 支持**：完整的跨域资源共享配置
- **请求过滤**：自动过滤恶意请求

### ⚡ 性能优化
- **静态缓存**：JavaScript、CSS、图片等静态资源缓存
- **Gzip 压缩**：自动压缩文本类型响应
- **连接池**：优化的上游连接管理

## 目录结构

```
brick-gateway/
├── nginx.conf              # 主配置文件
├── nginx-auth_request.conf # 认证请求配置
├── Dockerfile              # 容器构建文件
├── public.pem              # RSA 公钥文件
├── scripts/                # 管理脚本
│   ├── build.sh           # 构建脚本
│   ├── run.sh             # 运行脚本
│   ├── clean.sh           # 清理脚本
│   ├── config.sh          # 配置脚本
│   └── quick_start.sh     # 快速启动脚本
└── README.md              # 本文档
```

## 快速开始

### 构建镜像
```bash
./scripts/build.sh [version]
```

### 运行服务
```bash
./scripts/run.sh [version]
```

### 快速启动（构建+运行）
```bash
./scripts/quick_start.sh [action] [version]
```

### 清理资源
```bash
./scripts/clean.sh [--image]
```

### 查看状态
```bash
./scripts/quick_start.sh status
```

### 查看日志
```bash
./scripts/quick_start.sh logs
```

### 健康检查
```bash
curl http://localhost:17000/health
```

## API 路由

### 公开端点
- `GET /` - 前端应用（brick-hub）
- `GET /health` - 健康检查
- `GET /build-info.json` - 构建信息

### 认证端点（无需 JWT）
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/validate` - 验证令牌
- `GET /api/auth/me` - 获取用户信息
- `POST /api/auth/refresh` - 刷新令牌

### 受保护端点（需要 JWT）
- `GET /api/clock/*` - 时钟服务 API
- `POST /api/clock/*` - 时钟服务 API
- `GET /api/ntp/*` - NTP 服务 API
- `POST /api/ntp/*` - NTP 服务 API

### 兼容性端点
- `POST /login` - 兼容性登录端点
- `POST /validate` - 兼容性验证端点
- `POST /refresh` - 兼容性刷新端点
- `GET /me` - 兼容性用户信息端点

## 配置说明

### 环境变量
- `VERSION` - 服务版本（默认：0.1.0-dev）
- `BUILD_DATETIME` - 构建时间戳
- `API_PORT` - 服务端口（默认：17000）

### 上游服务配置
```nginx
upstream brick_clock {
    server brick-clock:17003;
}

upstream brick_hub {
    server brick-hub:17002;
}

upstream brick_auth {
    server brick-auth:17001;
}
```

### JWT 配置
- **算法**：RS256
- **密钥文件**：/etc/nginx/public.pem
- **令牌提取**：从 Authorization 头部提取 Bearer 令牌

## 安全配置

### 安全头部
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
```

### CORS 配置
```nginx
add_header Access-Control-Allow-Origin * always;
add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization" always;
```

## 性能优化

### 静态资源缓存
```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    add_header Vary Accept-Encoding;
}
```

### Gzip 压缩
```nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript;
```

## 监控和日志

### 日志配置
- **访问日志**：/var/log/nginx/access.log
- **错误日志**：/var/log/nginx/error.log
- **日志格式**：包含 IP、时间、请求、状态码等信息

### 健康检查
- **端点**：http://localhost:17000/health
- **检查间隔**：30秒
- **超时时间**：3秒
- **重试次数**：3次

## 故障排除

### 常见问题

1. **JWT 验证失败**
   - 检查 public.pem 文件是否存在
   - 验证 RSA 公钥格式是否正确
   - 确认令牌格式和算法

2. **上游服务连接失败**
   - 检查 Docker 网络配置
   - 验证上游服务是否正常运行
   - 确认服务端口是否正确

3. **CORS 错误**
   - 检查 CORS 头部配置
   - 验证预检请求处理
   - 确认允许的域名和方法

### 调试命令

```bash
# 检查容器状态
docker ps | grep brick-gateway

# 查看网关日志
docker logs brick-gateway

# 测试健康检查
curl http://localhost:17000/health

# 测试认证端点
curl -X POST http://localhost:17000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"brick-admin","password":"brickpass"}'

# 测试受保护端点
curl -H "Authorization: Bearer <token>" \
  http://localhost:17000/api/clock/status
```

## 脚本使用

### build.sh
构建 Docker 镜像
```bash
./scripts/build.sh [version]
```

### run.sh
运行容器
```bash
./scripts/run.sh [version]
```

### clean.sh
清理容器和镜像
```bash
./scripts/clean.sh [--image]
```

### quick_start.sh
快速启动和测试
```bash
./scripts/quick_start.sh [action] [version]
# action: build, run, test, clean, logs, status, all
```

## 技术栈

- **Nginx**：高性能 Web 服务器和反向代理
- **JWT Module**：JWT 认证模块
- **Docker**：容器化部署
- **RSA 加密**：JWT 令牌签名验证
- **Gzip 压缩**：响应压缩优化
- **静态缓存**：资源缓存策略

## 版本信息

- **当前版本**：0.1.0-dev
- **构建时间**：2025-07-10T13:00:00Z
- **服务名称**：brick-gateway
- **描述**：API Gateway Service