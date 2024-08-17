# 停止服务
systemctl stop sockd.service

# 禁用服务
systemctl disable sockd.service

# 删除systemd服务文件
rm /etc/systemd/system/sockd.service

# 删除Socks5二进制文件
rm /usr/local/bin/socks

# 删除配置文件和目录
rm -rf /etc/socks

# 重新加载systemd守护进程
systemctl daemon-reload

# 关闭防火墙端口（适用于CentOS/RedHat使用firewalld的情况）
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --remove-port=9999/tcp --permanent
    firewall-cmd --reload
fi

# 关闭防火墙端口（适用于Ubuntu/Debian使用ufw的情况）
if command -v ufw &> /dev/null; then
    ufw delete allow 9999
fi

echo "Socks5代理服务已停止并卸载"
