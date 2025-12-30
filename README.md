# Telegram 名字自动更新

自动将 Telegram 名字更新为：`原名 | 时间`

## 功能特点

- 每分钟自动更新 Telegram 名字
- 显示当前时间（中国时区）
- 支持 Docker Compose 和直接运行两种方式
- 多平台支持（amd64/arm64）

---

## 快速开始（推荐使用 Docker Compose）

### 1. 获取 API 凭证

访问 https://my.telegram.org/auth
- 登录后点击 "API development tools"
- 创建应用获取 `api_id` 和 `api_hash`

### 2. 克隆项目

```bash
git clone https://github.com/jiangbkvir/tg-name-updater.git
cd tg-name-updater
```

### 3. 配置环境变量

```bash
cp .env.example .env
```

编辑 `.env` 填入 API 凭证：
```bash
API_ID=你的api_id
API_HASH=你的api_hash
```

### 4. 首次登录

```bash
chmod +x login.sh
./login.sh
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

## 使用方式

### 方式一：Docker Compose（推荐）

**优点**：配置管理方便，支持环境变量文件，易于维护

```bash
# 启动
docker compose up -d

# 查看日志
docker compose logs -f

# 停止
docker compose down

# 重启
docker compose restart
```

### 方式二：Docker 直接运行

**适合**：快速测试或不想克隆整个项目

```bash
# 创建会话目录
mkdir -p session

# 运行容器（需要先登录获取 session 文件）
docker run -d \
  --name tg-name-updater \
  --restart unless-stopped \
  -e API_ID=你的api_id \
  -e API_HASH=你的api_hash \
  -e TZ=Asia/Shanghai \
  -v $(pwd)/session:/app/session \
  jiangbkvir/tg-name-updater:latest
```

**注意**：直接运行方式需要先通过交互式容器获取 session 文件：

```bash
# 交互式登录
docker run -it --rm \
  -e API_ID=你的api_id \
  -e API_HASH=你的api_hash \
  -v $(pwd)/session:/app/session \
  jiangbkvir/tg-name-updater:latest \
  python3 -c "from telethon import TelegramClient; import os; client = TelegramClient('session/tg_name_updater', os.getenv('API_ID'), os.getenv('API_HASH')); client.start()"
```

---

## 常用命令

```bash
# 查看日志
docker logs -f tg-name-updater

# 查看实时更新的名字
docker logs tg-name-updater | grep "名字已更新"

# 停止容器
docker compose down
# 或
docker stop tg-name-updater && docker rm tg-name-updater

# 重新登录
rm -rf session/*
./login.sh

# 修改原始名字
echo "你的新名字" > session/original_name.txt
docker restart tg-name-updater
```

---

## 项目结构

```
.
├── Dockerfile
├── docker-compose.yml
├── tg_name_update.py      # 核心程序
├── login.sh               # 登录脚本
├── start.sh               # 一键启动脚本
├── .env.example           # 配置模板
├── .env                   # 配置文件（需创建）
├── session/               # 会话目录（自动生成）
│   ├── tg_name_updater.session  # 登录后生成
│   └── original_name.txt        # 原始名字
└── README.md
```

---

## 镜像信息

- **镜像地址**: `jiangbkvir/tg-name-updater:latest`
- **支持平台**: linux/amd64, linux/arm64
- **基础镜像**: python:3.11-slim
- **镜像大小**: ~150MB

---

## 开发相关

### 构建本地镜像

```bash
docker build -t tg-name-updater:local .
```

### 构建多平台镜像并推送

```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 \
  -t jiangbkvir/tg-name-updater:latest --push .
```

---

## 许可证

MIT License
