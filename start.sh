#!/bin/bash
# Telegram 名字自动更新 - 一键启动脚本

set -e

echo "=========================================="
echo "  TG Name Updater - 一键启动"
echo "=========================================="
echo ""

# 检查 .env 文件
if [ ! -f .env ]; then
    echo "❌ 未找到 .env 文件"
    echo ""
    echo "请先配置环境变量："
    echo "  1. cp .env.example .env"
    echo "  2. 编辑 .env 填入 API_ID 和 API_HASH"
    echo ""
    exit 1
fi

# 加载环境变量
export $(grep -v '^#' .env | xargs)

# 检查 API_ID
if [ "$API_ID" = "your_api_id_here" ] || [ -z "$API_ID" ]; then
    echo "❌ 请在 .env 文件中配置 API_ID"
    exit 1
fi

# 检查是否已登录
if [ ! -f session/tg_name_updater.session ]; then
    echo "📱 首次使用，需要登录 Telegram..."
    echo ""
    chmod +x login.sh
    ./login.sh
    echo ""
fi

# 启动容器
echo "🚀 启动服务..."
docker compose up -d

echo ""
echo "✅ 启动成功！"
echo ""
echo "查看日志："
echo "  docker logs -f tg-name-updater"
echo ""
echo "停止服务："
echo "  docker compose down"
echo ""
