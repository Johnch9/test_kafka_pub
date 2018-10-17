# ---
# Go Builder Image
FROM golang:1.11.1-alpine AS builder

#RUN apk update && apk add curl git && apk add pkgconfig && apk add --no-cache librdkafka

RUN apk add --update --no-cache alpine-sdk bash ca-certificates \
      libressl \
      tar \
      git openssh openssl yajl-dev zlib-dev cyrus-sasl-dev openssl-dev build-base coreutils
WORKDIR /root
RUN git clone https://github.com/edenhill/librdkafka.git
WORKDIR /root/librdkafka
RUN /root/librdkafka/configure
RUN make
RUN make install
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

RUN go get github.com/labstack/echo
RUN go get github.com/labstack/echo/middleware
RUN go get github.com/sirupsen/logrus
RUN go get github.com/confluentinc/confluent-kafka-go/kafka

# set build arguments: GitHub user and repository
ARG GH_USER
ARG GH_REPO

# Create and set working directory
RUN mkdir -p /go/src/github.com/$GH_USER/$GH_REPO
WORKDIR /go/src/github.com//$GH_USER/$GH_REPO

# copy sources
COPY . .

# Run tests, skip 'vendor'
# RUN go test -v $(go list ./... | grep -v /vendor/)

# Build application
RUN go build -v -o "dist/myapp"

# ---
# Application Runtime Image
#FROM alpine:latest

# set build arguments: GitHub user and repository
#ARG GH_USER
#ARG GH_REPO

# copy file from builder image
#COPY --from=builder /go/src/github.com/$GH_USER/$GH_REPO/dist/myapp /usr/bin/myapp

EXPOSE 8080

CMD ["dist/myapp", "--help"]