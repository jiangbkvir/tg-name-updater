#!/bin/bash
# 智能启动脚本 - 自动检测 session 文件并处理登录

SESSION_FILE="/app/session/tg_name_updater.session"

echo "=========================================="
echo "  Telegram 名字自动更新"
echo "=========================================="

# 检查 session 文件是否存在
if [ ! -f "$SESSION_FILE" ]; then
    echo ""
    echo "⚠️  未检测到登录凭证 (session 文件)"
    echo ""
    echo "📝 请先登录:"
    echo "   docker compose --profile login run --rm login"
    echo ""
    echo "=========================================="
    exit 1
fi

echo "✅ 检测到登录凭证，正在启动..."
echo ""

# 启动主程序
exec python3 /app/tg_name_update.py
