FROM alpine AS download

ARG TARGETOS
ARG TARGETARCH
ARG DUFS_BASE=http://114.80.36.225:15667/sxjc

RUN apk add --no-cache ca-certificates curl
RUN test "$TARGETOS" = "linux"
RUN curl -fsSL "$DUFS_BASE/releases/dashboard/dashboard-${TARGETOS}-${TARGETARCH}" -o /dashboard
RUN chmod +x /dashboard

FROM busybox:stable-musl

COPY --from=download /etc/ssl/certs /etc/ssl/certs
COPY --from=download /dashboard /dashboard/app
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /dashboard
VOLUME ["/dashboard/data"]
EXPOSE 8008

ENV TZ=Asia/Shanghai

ENTRYPOINT ["/entrypoint.sh"]
