#!/bin/bash
# Telegram 登录脚本 - 用于生成 session 文件

echo "=========================================="
echo "  Telegram 名字自动更新 - 登录工具"
echo "=========================================="
echo ""
echo "登录成功后会自动启动主服务"
echo ""

# 检测使用哪个镜像
if docker images jiangbkvir/tg-name-updater:latest --format "{{.Repository}}:{{.Tag}}" | grep -q "jiangbkvir/tg-name-updater:latest"; then
    IMAGE_NAME="jiangbkvir/tg-name-updater:latest"
    echo "📦 使用发布镜像: $IMAGE_NAME"
elif docker images tg-name-updater-tg-name-updater --format "{{.Repository}}:{{.Tag}}" | grep -q "tg-name-updater-tg-name-updater"; then
    IMAGE_NAME="tg-name-updater-tg-name-updater"
    echo "📦 使用本地镜像: $IMAGE_NAME"
else
    echo "⚠️  未找到镜像，尝试拉取发布镜像..."
    docker pull jiangbkvir/tg-name-updater:latest
    IMAGE_NAME="jiangbkvir/tg-name-updater:latest"
    echo "✅ 镜像拉取完成: $IMAGE_NAME"
fi
echo ""

# 检查 .env 文件
if [ ! -f .env ]; then
    echo "❌ 错误：.env 文件不存在"
    echo ""
    echo "请先创建 .env 文件："
    echo "  cp .env.example .env"
    echo "  然后编辑 .env 填入 API_ID 和 API_HASH"
    echo ""
    exit 1
fi

# 读取环境变量
export $(grep -v '^#' .env | xargs)

if [ -z "$API_ID" ] || [ -z "$API_HASH" ]; then
    echo "❌ 错误：.env 文件中缺少 API_ID 或 API_HASH"
    echo ""
    exit 1
fi

# 创建 session 目录
mkdir -p session

# 运行登录脚本
docker run --rm -it \
  -v $(pwd)/session:/app/session \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd):/app/project \
  -w /app/project \
  -e API_ID=$API_ID \
  -e API_HASH=$API_HASH \
  $IMAGE_NAME \
  python3 -c "
from telethon import TelegramClient
from telethon.errors import SessionPasswordNeededError
import os
import asyncio
import subprocess

async def login():
    client = TelegramClient('/app/session/tg_name_updater', int(os.getenv('API_ID')), os.getenv('API_HASH'))
    await client.connect()

    if not await client.is_user_authorized():
        print('📱 请输入手机号（格式：+8613800138000）')
        phone = input('手机号: ')

        print('🔐 正在发送验证码...')
        await client.send_code_request(phone)

        print('📨 请输入 Telegram 发送的验证码：')
        code = input('验证码: ')

        try:
            await client.sign_in(phone, code)
        except SessionPasswordNeededError:
            print('🔒 账号开启了两步验证')
            print('🔑 请输入两步验证密码：')
            password = input('密码: ')
            await client.sign_in(password=password)

    me = await client.get_me()
    print(f'✅ 登录成功! 用户: {me.first_name}')
    print('💾 Session 文件已保存到 session/ 目录')
    await client.disconnect()

    print('🚀 正在启动主服务...')
    result = subprocess.run(['docker', 'compose', 'up', '-d'], capture_output=True, text=True)
    if result.returncode == 0:
        print('✅ 主服务已启动!')
        print('📊 查看日志: docker logs -f tg-name-updater')
    else:
        print('❌ 启动失败，请手动运行: docker compose up -d')
        print(result.stderr)

asyncio.run(login())
"

echo ""
echo "=========================================="
echo "  登录并启动完成！"
echo "=========================================="
echo ""
