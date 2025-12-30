#!/usr/bin/env python3
"""
Telegram 名字自动更新脚本
在原名后面添加时间：原名 | 小时:分钟 | 星期几
"""

from telethon import TelegramClient, events
from telethon.errors import SessionPasswordNeededError
import os
from datetime import datetime
import pytz
import asyncio

# 从环境变量读取配置
API_ID = int(os.getenv('API_ID', '0'))
API_HASH = os.getenv('API_HASH', '')
SESSION_NAME = '/app/session/tg_name_updater'
ORIGINAL_NAME_FILE = '/app/session/original_name.txt'

# 时区
TZ = pytz.timezone('Asia/Shanghai')

# 星期映射
WEEKDAYS = ['一', '二', '三', '四', '五', '六', '日']

async def get_original_name(client):
    """获取并保存原始名字"""
    # 尝试从文件读取
    if os.path.exists(ORIGINAL_NAME_FILE):
        with open(ORIGINAL_NAME_FILE, 'r', encoding='utf-8') as f:
            saved_name = f.read().strip()
        # 检查是否已包含时间后缀（防止重复保存）
        if ' | ' in saved_name and any(c.isdigit() for c in saved_name):
            # 已保存的名字包含时间，说明出错了，需要重新获取原始名字
            print(f'⚠️  检测到已保存的名字包含时间后缀，正在重新获取原始名字...')
        else:
            return saved_name

    # 获取当前名字并清理可能的时间后缀
    me = await client.get_me()
    current_name = me.first_name or ''

    # 如果当前名字包含时间后缀，尝试清理
    if ' | ' in current_name:
        # 移除 " | HH:MM" 格式的后缀
        original_name = current_name.split(' | ')[0]
        print(f'🧹 已清理时间后缀，原始名字: {original_name}')
    else:
        original_name = current_name

    # 保存到文件
    os.makedirs(os.path.dirname(ORIGINAL_NAME_FILE), exist_ok=True)
    with open(ORIGINAL_NAME_FILE, 'w', encoding='utf-8') as f:
        f.write(original_name)

    print(f'💾 已保存原始名字: {original_name}')
    return original_name

async def update_name(client, original_name):
    """在原名后面添加时间"""
    now = datetime.now(TZ)
    hour_min = now.strftime('%H:%M')
    new_name = f'{original_name} | {hour_min}'

    try:
        await client(functions.account.UpdateProfileRequest(
            first_name=new_name
        ))
        print(f'✅ 名字已更新: {new_name}')
    except Exception as e:
        print(f'❌ 更新失败: {e}')

async def main():
    if API_ID == 0 or not API_HASH:
        print('❌ 错误: 请在 .env 文件中设置 API_ID 和 API_HASH')
        print('📖 获取方式: 访问 https://my.telegram.org')
        return

    # 检查 session 文件是否存在
    if not os.path.exists(SESSION_NAME + '.session'):
        print('❌ 未检测到登录凭证 (session 文件)')
        print('📝 请先登录:')
        print('   docker compose -f docker-compose.login.yml run --rm login')
        return

    # 创建客户端
    client = TelegramClient(SESSION_NAME, API_ID, API_HASH)

    try:
        # 连接（不自动登录，使用已有 session）
        await client.connect()

        # 检查是否已授权
        if not await client.is_user_authorized():
            print('❌ Session 文件无效或已过期')
            print('📝 请重新登录:')
            print('   docker compose -f docker-compose.login.yml run --rm login')
            await client.disconnect()
            return

        print('✅ 登录成功!\n')

        # 获取原始名字
        original_name = await get_original_name(client)

        # 立即更新一次
        await update_name(client, original_name)

        # 每分钟更新一次
        print('⏰ 开始定时更新...')
        while True:
            await update_name(client, original_name)
            # 等待到下一分钟
            await asyncio.sleep(60 - datetime.now(TZ).second)

    except Exception as e:
        print(f'❌ 错误: {e}')
    finally:
        await client.disconnect()

# 导入 UpdateProfileRequest
from telethon.tl import functions

if __name__ == '__main__':
    asyncio.run(main())
