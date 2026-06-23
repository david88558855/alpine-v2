# Docker 会自动注入 TARGETARCH 变量
ARG TARGETARCH

# 根据架构选择不同的基础镜像
FROM alpine:latest AS base-amd64
FROM arm64v8/alpine:latest AS base-arm64

# 选择对应的基础镜像
FROM base-${TARGETARCH}

# Docker 会自动注入 TARGETARCH 变量
ARG TARGETARCH

# 安装 openrc、bash、tzdata
RUN apk add --no-cache \
    openrc \
    bash \
    tzdata \
    && \
    # 设置时区
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata && \
    \
    # OpenRC 容器初始化
    mkdir -p /run/openrc && \
    touch /run/openrc/softlevel && \
    \
    rm -rf /var/cache/apk/*

# TZ 让容器内程序（如 date、cron 等）直接读取时区
ENV container=docker \
    TZ=Asia/Shanghai

# 设置工作目录 /root
WORKDIR /root

# 安装 sing-box
RUN bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh) && ls

# 容器启动时运行的命令
ENTRYPOINT ["/sbin/init"]
