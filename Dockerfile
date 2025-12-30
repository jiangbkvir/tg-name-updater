FROM python:3.11-slim

# 接受代理参数
ARG https_proxy
ARG http_proxy
ARG all_proxy

# 设置代理环境变量
ENV https_proxy=${https_proxy}
ENV http_proxy=${http_proxy}
ENV all_proxy=${all_proxy}

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 依赖
RUN pip3 install --no-cache-dir \
    Telethon==1.34.0 \
    pytz==2024.1

# 复制脚本
COPY tg_name_update.py /app/

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

CMD ["python3", "tg_name_update.py"]
