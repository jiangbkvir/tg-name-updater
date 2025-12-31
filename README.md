# Telegram 名字自动更新

自动将 Telegram 名字更新为：`原名 | 时间`

## 功能特点

- 每分钟自动更新 Telegram 名字
- 显示当前时间（中国时区）
- 多平台支持（amd64/arm64）

---

## 快速开始

### 1. 获取配置文件

```bash
# 创建目录
mkdir tg-name-updater && cd tg-name-updater

# 下载必要文件
curl -O https://raw.githubusercontent.com/jiangbkvir/tg-name-updater/master/docker-compose.yml
curl -O https://raw.githubusercontent.com/jiangbkvir/tg-name-updater/master/login.py
curl -O https://raw.githubusercontent.com/jiangbkvir/tg-name-updater/master/.env.example

# 复制配置文件
cp .env.example .env
```

### 2. 获取 API 凭证

访问 https://my.telegram.org/auth
- 登录后点击 "API development tools"
- 创建应用获取 `api_id` 和 `api_hash`

### 3. 配置环境变量

编辑 `.env` 文件填入 API 凭证：

```bash
API_ID=你的api_id
API_HASH=你的api_hash
```

### 4. 登录

```bash
docker compose --profile login run --rm -it login
```

按提示输入：
- 手机号（如：+8613800138000）
- 验证码
- 两步验证密码（如果设置了）

### 5. 启动服务

```bash
docker compose up -d
```

---

## 常用命令

```bash
# 登录
docker compose --profile login run --rm -it login

# 启动服务
docker compose up -d

# 查看日志
docker compose logs -f

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 重新登录
rm -rf session/*
docker compose --profile login run --rm -it login

```

---

## 重要说明

### 关于 Session 文件

- **Session 文件** 是 Telegram 登录后的凭证，保存在 `session/tg_name_updater.session`
- **首次使用必须先登录** 才能生成 session 文件
- **Session 文件丢失** 需要重新登录

### 镜像信息

- **镜像地址**: `jiangbkvir/tg-name-updater:latest`
- **支持平台**: linux/amd64, linux/arm64
- **基础镜像**: python:3.11-slim
- **镜像大小**: ~150MB

---

## 许可证

MIT License

<!-- Test CI/CD README -->
