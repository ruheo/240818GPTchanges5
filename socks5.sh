#!/bin/bash

# Socks5 Installation Script

# Check if the user is root
if [ "$EUID" -ne 0 ]; then
    echo "请以root用户身份运行"
    exit 1
fi

# 获取脚本参数
PORT=${1:-9999}
USER=${2:-caishen891}
PASSWD=${3:-999999}
AUTH_MODE=${4:-password} # 认证模式：noauth（无认证）或 password（需要认证）

# 设置变量
PACKAGE_MANAGER=""
FIREWALL_COMMAND=""
SOCKS_BIN="/usr/local/bin/socks"
SERVICE_FILE="/etc/systemd/system/sockd.service"
CONFIG_FILE="/etc/socks/config.yaml"

# Determine package manager and firewall
if command -v yum &> /dev/null; then
    PACKAGE_MANAGER="yum"
    FIREWALL_COMMAND="firewall-cmd --add-port=$PORT/tcp --permanent && firewall-cmd --reload"
elif command -v apt-get &> /dev/null; then
    PACKAGE_MANAGER="apt-get"
    FIREWALL_COMMAND="ufw allow $PORT"
else
    echo "不支持的系统，请手动安装所需的软件包并配置防火墙。"
    exit 1
fi

# 安装必要的软件包
for cmd in wget lsof; do
    if ! command -v $cmd &> /dev/null; then
        echo "$cmd 未安装，正在安装..."
        $PACKAGE_MANAGER install -y $cmd
    fi
done

# 下载并设置Socks5二进制文件
if [ ! -f "$SOCKS_BIN" ]; then
    echo "下载 Socks5 二进制文件..."
    wget -O "$SOCKS_BIN" --no-check-certificate https://github.com/ruheo/240818GPTchanges5/raw/main/socks || {
        echo "下载 Socks5 二进制文件失败"
        exit 1
    }
    chmod +x "$SOCKS_BIN"
else
    echo "Socks5 二进制文件已经存在，跳过下载。"
fi

# 创建Socks5 systemd服务文件
if [ ! -f "$SERVICE_FILE" ]; then
    echo "创建 Socks5 服务文件..."
    cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Socks Service
After=network.target nss-lookup.target

[Service]
User=socksuser
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=$SOCKS_BIN run -config $CONFIG_FILE
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF
else
    echo "Socks5 服务文件已经存在，跳过创建。"
fi

# 创建Socks5配置文件
echo "创建 Socks5 配置文件..."
mkdir -p /etc/socks
if [ "$AUTH_MODE" = "password" ]; then
    cat <<EOF > "$CONFIG_FILE"
{
    "log": {
        "loglevel": "warning"
    },
    "routing": {
        "domainStrategy": "AsIs"
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": "$PORT",
            "protocol": "socks",
            "settings": {
                "auth": "password",
                "accounts": [
                    {
                        "user": "$USER",
                        "pass": "$PASSWD"
                    }
                ],
                "udp": true
            },
            "streamSettings": {
                "network": "tcp"
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ]
}
EOF
else
    cat <<EOF > "$CONFIG_FILE"
{
    "log": {
        "loglevel": "warning"
    },
    "routing": {
        "domainStrategy": "AsIs"
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": "$PORT",
            "protocol": "socks",
            "settings": {
                "auth": "noauth",
                "udp": true
            },
            "streamSettings": {
                "network": "tcp"
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ]
}
EOF
fi

# 创建专用用户
if id "socksuser" &>/dev/null; then
    echo "用户 socksuser 已经存在"
else
    echo "创建用户 socksuser..."
    useradd -r -s /sbin/nologin socksuser
fi

# 启用并启动Socks5服务
echo "启用并启动 Socks5 服务..."
systemctl daemon-reload
systemctl enable sockd.service
systemctl start sockd.service

# 配置防火墙
echo "配置防火墙..."
eval "$FIREWALL_COMMAND"

# 显示连接信息
IPv4=$(curl -4 ip.sb)
IPv6=$(curl -6 ip.sb)
echo -e "IPv4: $IPv4\nIPv6: $IPv6\n端口: $PORT\n用户名: $USER\n密码: $PASSWD"

# 完成
echo "——————Socks5代理安装并配置成功——————"
echo "停止及卸载请运行以下代码"
echo "systemctl stop sockd.service
systemctl disable sockd.service
rm /etc/systemd/system/sockd.service
rm /usr/local/bin/socks
rm -rf /etc/socks
systemctl daemon-reload
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --remove-port=9999/tcp --permanent
    firewall-cmd --reload
fi
if command -v ufw &> /dev/null; then
    ufw delete allow 9999
fi
echo "Socks5代理服务已停止并卸载""
