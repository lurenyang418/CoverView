FROM node:alpine3.12 as front-builder

RUN set -eux \
    && sed -i s#dl-cdn.alpinelinux.org#mirror.tuna.tsinghua.edu.cn#g /etc/apk/repositories \
    && apk --no-cache --no-progress update \
    && apk --no-cache --no-progress upgrade \
    && apk add --no-cache --no-progress git \
    && git clone --depth=1 https://ghproxy.com/https://github.com/rutikwankhade/CoverView.git app \
    && cd app \
    && npm i \
    && npm run build

FROM golang:alpine as bin-builder

WORKDIR /app

COPY . /app

COPY --from=front-builder /app/build /app/assets

RUN CGO_ENABLED=0 go build -a --trimpath --ldflags="-s -w" -o app .

FROM alpine

COPY --from=bin-builder /app/app /usr/local/bin/app

EXPOSE 80

CMD ["app"]