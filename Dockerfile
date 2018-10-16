# ---
# Go Builder Image
FROM golang:1.8-alpine AS builder

RUN apk update && apk add curl git

RUN go get github.com/labstack/echo
RUN go get github.com/labstack/echo/middleware
RUN go get github.com/sirupsen/logrus

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
RUN CGO_ENABLED=0 go build -v -o "dist/myapp"

# ---
# Application Runtime Image
FROM alpine:3.6

# set build arguments: GitHub user and repository
ARG GH_USER
ARG GH_REPO

# copy file from builder image
COPY --from=builder /go/src/github.com/$GH_USER/$GH_REPO/dist/myapp /usr/bin/myapp

EXPOSE 8080

CMD ["myapp", "--help"]