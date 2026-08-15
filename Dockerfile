# Go 1.26.6 caused high-frequency gRPC RequestTask/ReportSystemState stream
# cancellations under the production Agent load. Keep the verified toolchain
# pinned so rebuilding the same source cannot silently change runtime behavior.
FROM --platform=$TARGETPLATFORM golang:1.26.5-bookworm AS build

WORKDIR /src

# DASHBOARD_VERSION 注入 singleton.Version（页脚 / MCP serverInfo / 启动日志显示）。
# 神仙监控自有版本号，与官方 nezha 版本完全无关——upstream sync 只合代码，不动这里。
# 想发新版时手动 bump 这个号即可。
ARG DASHBOARD_VERSION=v1.0.1

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
