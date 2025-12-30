# Telegram 名字自动更新

自动将 Telegram 名字更新为：`原名 | 时间`

## 功能特点

- 每分钟自动更新 Telegram 名字
- 显示当前时间（中国时区）
- 多平台支持（amd64/arm64）
- 登录后自动启动服务

---

## 快速开始

### 1. 下载配置文件

```bash
mkdir tg-name-updater && cd tg-name-updater

# 下载 docker-compose.yml
curl -O https://raw.githubusercontent.com/jiangbkvir/tg-name-updater/master/docker-compose.yml

# 下载 docker-compose.login.yml（首次登录需要）
curl -O https://raw.githubusercontent.com/jiangbkvir/tg-name-updater/master/docker-compose.login.yml

# 下载 .env.example
curl -O https://raw.githubusercontent.com/jiangbkvir/tg-name-updater/master/.env.example

# 复制为 .env
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

### 4. 启动服务

```bash
docker compose up -d
```

**首次使用时**，如果没有登录凭证，会提示你先登录：

```bash
docker compose -f docker-compose.login.yml run --rm -it login
```

按提示输入：
- 手机号（如：+8613800138000）
- 验证码
- 两步验证密码（如果设置了）

登录成功后会**自动启动主服务**！

---

## 常用命令

```bash
# 查看日志
docker logs -f tg-name-updater

# 查看实时更新的名字
docker logs tg-name-updater | grep "名字已更新"

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 重新登录
rm -rf session/*
docker compose -f docker-compose.login.yml run --rm -it login

# 修改原始名字
echo "你的新名字" > session/original_name.txt
docker compose restart
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

### 相关链接

- **Docker Hub**: https://hub.docker.com/r/jiangbkvir/tg-name-updater
- **GitHub**: https://github.com/jiangbkvir/tg-name-updater

---

## 许可证

MIT License
