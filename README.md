# 神仙监控 Docker 镜像

这是神仙监控 Dashboard 的公开 Docker 镜像发布仓库。主项目源码仍保存在私有仓库；本仓库只保存 Docker 发布文件，GitHub Actions 通过仓库密钥读取私有源码并在构建容器内编译 CGO 可用的 Dashboard 二进制。

## 镜像

```text
ghcr.io/abxian/shenxian:latest
```

当前公开 `latest` 镜像先发布 `linux/amd64`，用于常见 x86_64 服务器。`linux/arm64` 会在单独构建验证后再补。

## 安装

```sh
curl -L http://114.80.36.225:15667/sxjc/dashboard-docker.sh -o dashboard-docker.sh && chmod +x dashboard-docker.sh && sudo env SX_SITE_NAME="神仙监控" SX_INSTALL_HOST=data.example.com:8008 SX_LISTEN_PORT=8008 ./dashboard-docker.sh install
```

## 更新

```sh
sudo ./dashboard-docker.sh update
```

## 手动运行

```sh
mkdir -p ./data
cat > ./data/config.yaml <<EOF
language: zh_CN
site_name: "神仙监控"
install_host: "data.example.com:8008"
listen_port: 8008
location: Asia/Shanghai
EOF

docker run -d \
  --name shenxian-dashboard \
  --restart unless-stopped \
  -p 8008:8008 \
  -v "$PWD/data:/dashboard/data" \
  ghcr.io/abxian/shenxian:latest
```

访问：

```text
http://服务器IP:8008/dashboard
```

默认账号密码：

```text
admin / admin
```

首次登录后请立即修改默认密码。
