# GPT新改一键全自动Socks5脚本
适用于 Debian 9+、Ubuntu 20.04+ 和 CentOS 7+ 

默认端口，用户名和密码
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ruheo/240818GPTchanges5/main/socks5.sh)"
```

默认端口，无认证无用户名和密码
```bash
curl -fsSL https://raw.githubusercontent.com/ruheo/240818GPTchanges5/main/socks5.sh | sudo bash -s -- noauth
```

自定义端口，无需用户名和密码
```bash
curl -fsSL https://raw.githubusercontent.com/ruheo/240818GPTchanges5/main/socks5.sh | sudo bash -s -- noauth 端口号
```

自定义端口用户名和密码
```bash
curl -fsSL https://raw.githubusercontent.com/ruheo/240818GPTchanges5/main/socks5.sh | sudo bash -s -- password 端口 用户名 密码
```
