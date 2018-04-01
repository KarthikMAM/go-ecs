FROM golang:1.9.2-alpine3.7

WORKDIR /go/src

ADD . /go/src/github.com/karthikmam/go-ecs

RUN go install github.com/karthikmam/go-ecs

ENTRYPOINT /go/bin/go-ecs

EXPOSE 8080