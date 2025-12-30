#!/bin/bash
# 智能启动脚本 - 支持 MODE 环境变量控制行为

SESSION_FILE="/app/session/tg_name_updater.session"

# 登录模式
if [ "$MODE" = "login" ]; then
    exec python3 /app/project/login.py
fi

# 正常模式
echo "=========================================="
echo "  Telegram 名字自动更新"
echo "=========================================="

# 检查 session 文件是否存在
if [ ! -f "$SESSION_FILE" ]; then
    echo ""
    echo "⚠️  未检测到登录凭证 (session 文件)"
    echo ""
    echo "📝 请先登录:"
    echo "   docker compose --profile login run --rm -it login"
    echo ""
    echo "=========================================="
    exit 1
fi

echo "✅ 检测到登录凭证，正在启动..."
echo ""

# 启动主程序
exec python3 /app/tg_name_update.py
