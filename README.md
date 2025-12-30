# Telegram 名字自动更新

自动将 Telegram 名字更新为：`原名 | 时间`

## 快速开始

### 1. 获取 API 凭证

访问 https://my.telegram.org/auth
- 登录后点击 "API development tools"
- 创建应用获取 `api_id` 和 `api_hash`

### 2. 配置环境变量

```bash
cp .env.example .env
```

编辑 `.env` 填入 API 凭证：
```
API_ID=你的api_id
API_HASH=你的api_hash
```

### 3. 登录（首次使用）

```bash
chmod +x login.sh
./login.sh
```

按提示输入：
- 手机号（如：+8613800138000）
- 验证码
- 两步验证密码（如果设置了）

### 4. 启动容器

```bash
docker compose up -d
```

## 用户操作流程

```
1. 配置 .env 文件
2. 运行 ./login.sh 登录一次
3. docker compose up -d 启动
4. 完成！名字每分钟自动更新
```

## 常用命令

```bash
# 查看日志
docker logs -f tg-name-updater

# 停止容器
docker compose down

# 重新登录
rm -rf session/*
./login.sh

# 修改原始名字
echo "你的名字" > session/original_name.txt
docker restart tg-name-updater
```

## 文件结构

```
.
├── Dockerfile
├── docker-compose.yml
├── tg_name_update.py
├── login.sh              # 登录脚本
├── .env                  # 配置文件（需创建）
├── .env.example          # 配置模板
├── session/              # 会话目录（自动生成）
│   ├── tg_name_updater.session  # 登录后生成
│   └── original_name.txt        # 原始名字
└── README.md
```

## 发布镜像

### 构建多平台镜像

```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t 你的用户名/tg-name-updater:latest --push .
```

### 用户使用

```bash
git clone https://github.com/你的用户名/tg-name-updater.git
cd tg-name-updater
cp .env.example .env
# 编辑 .env
./login.sh
docker compose up -d
```
