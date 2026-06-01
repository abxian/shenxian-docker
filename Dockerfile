FROM --platform=$TARGETPLATFORM golang:1.26-bookworm AS build

WORKDIR /src

# DASHBOARD_VERSION 注入 singleton.Version（MCP serverInfo / 启动日志显示）。
# 与 abxian/nz 同步到的上游版本保持一致；每次 upstream sync 后在这里 bump。
ARG DASHBOARD_VERSION=v2.1.4

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY src/ ./

RUN CGO_ENABLED=1 go build -trimpath -buildvcs=false \
    -ldflags="-s -w -X github.com/shenxianhq/shenxian/service/singleton.Version=${DASHBOARD_VERSION}" \
    -o /dashboard/app ./cmd/dashboard

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /dashboard/app /dashboard/app
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh /dashboard/app

WORKDIR /dashboard
VOLUME ["/dashboard/data"]
EXPOSE 8008

ENV TZ=Asia/Shanghai

ENTRYPOINT ["/entrypoint.sh"]
