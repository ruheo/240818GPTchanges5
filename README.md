# GPT新改一键全自动Socks5脚本
适用于 Debian 9+、Ubuntu 20.04+ 和 CentOS 7+ 

默认端口，用户名和密码
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ruheo/240818GPTchanges5/main/socks5.sh)"
```

指定端口9999，无需用户名和密码
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ruheo/240818GPTchanges5/main/socks5.sh) noauth"
```

自定义端口，无需用户名和密码
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ruheo/240818GPTchanges5/main/socks5.sh)  端口号 noauth"
```

自定义端口用户名和密码
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ruheo/240818GPTchanges5/main/socks5.sh) 8888 myuser mypassword"
```
