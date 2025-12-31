#!/usr/bin/env python3
from telethon import TelegramClient
from telethon.errors import SessionPasswordNeededError
import os
import asyncio
import sys

async def login():
    client = TelegramClient("/app/session/tg_name_updater", int(os.getenv("API_ID")), os.getenv("API_HASH"))
    await client.connect()

    try:
        if not await client.is_user_authorized():
            # 输入手机号
            while True:
                try:
                    print("📱 请输入手机号（格式：+8613800138000）")
                    phone = input("手机号: ").strip()

                    if not phone:
                        print("❌ 手机号不能为空")
                        continue

                    print("🔐 正在发送验证码...")
                    await client.send_code_request(phone)
                    break
                except Exception as e:
                    print(f"❌ 发送验证码失败: {e}")
                    print("请重新输入...\n")

            # 输入验证码
            while True:
                print("📨 请输入 Telegram 发送的验证码：")
                code = input("验证码: ").strip()

                if not code:
                    print("❌ 验证码不能为空")
                    continue

                try:
                    await client.sign_in(phone, code)
                    break
                except SessionPasswordNeededError:
                    print("🔒 账号开启了两步验证")
                    # 输入两步验证密码
                    while True:
                        try:
                            print("🔑 请输入两步验证密码：")
                            password = input("密码: ").strip()

                            if not password:
                                print("❌ 密码不能为空")
                                continue

                            await client.sign_in(password=password)
                            break
                        except Exception as e:
                            print(f"❌ 密码错误: {e}")
                            print("请重新输入...\n")
                    break
                except Exception as e:
                    print(f"❌ 验证码错误: {e}")
                    print("请重新输入...\n")

        me = await client.get_me()
        print(f"✅ 登录成功! 用户: {me.first_name}")
        print("💾 Session 文件已保存")
        await client.disconnect()

        print()
        print("==========================================")
        print("🚀 请运行以下命令启动主服务:")
        print("   docker compose up -d")
        print("==========================================")

    except KeyboardInterrupt:
        print("\n\n❌ 登录已取消")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ 登录失败: {e}")
        sys.exit(1)

asyncio.run(login())
# CI/CD Test 2025年12月31日 星期三 08时34分05秒 CST
