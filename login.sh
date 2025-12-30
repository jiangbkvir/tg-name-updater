#!/bin/bash
# Telegram 登录脚本 - 用于生成 session 文件

echo "=========================================="
echo "  Telegram 名字自动更新 - 登录工具"
echo "=========================================="
echo ""
echo "请按提示输入登录信息..."
echo ""

# 运行登录脚本
docker run --rm -it \
  -v $(pwd)/session:/app/session \
  -e API_ID=$API_ID \
  -e API_HASH=$API_HASH \
  tg-name-updater-tg-name-updater \
  python3 -c "
from telethon import TelegramClient
from telethon.errors import SessionPasswordNeededError
import os
import asyncio

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

asyncio.run(login())
"

echo ""
echo "=========================================="
echo "  登录完成！现在可以启动主容器了"
echo "=========================================="
echo ""
echo "启动命令："
echo "  docker compose up -d"
echo ""
