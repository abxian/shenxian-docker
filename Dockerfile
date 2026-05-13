FROM --platform=$TARGETPLATFORM golang:1.25-alpine AS build

WORKDIR /src

RUN apk add --no-cache gcc musl-dev ca-certificates tzdata

COPY src/ ./

RUN CGO_ENABLED=1 go build -trimpath -buildvcs=false -ldflags="-s -w" -o /dashboard/app ./cmd/dashboard

FROM alpine:3.22

RUN apk add --no-cache ca-certificates tzdata

COPY --from=build /dashboard/app /dashboard/app
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh /dashboard/app

WORKDIR /dashboard
VOLUME ["/dashboard/data"]
EXPOSE 8008

ENV TZ=Asia/Shanghai

ENTRYPOINT ["/entrypoint.sh"]
