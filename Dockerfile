FROM --platform=$TARGETPLATFORM golang:1.25-bookworm AS build

WORKDIR /src

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY src/ ./

RUN CGO_ENABLED=1 go build -trimpath -buildvcs=false -ldflags="-s -w" -o /dashboard/app ./cmd/dashboard

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
