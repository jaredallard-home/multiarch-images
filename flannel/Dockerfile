FROM golang:1.14-alpine as build
WORKDIR /go/src/github.com/coreos/flannel
ARG VERSION

RUN apk add --no-cache make gcc git linux-headers musl-dev

# Copy everything in.
COPY . ./

RUN make -e dist/flanneld

FROM alpine:3.11
ENTRYPOINT ["/opt/bin/flanneld"]

LABEL maintainer="Jared Allard <jaredallard@outlook.com>"

RUN apk add --no-cache iproute2 net-tools ca-certificates iptables strongswan && update-ca-certificates
RUN apk add wireguard-tools --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community

COPY --from=build /go/src/github.com/coreos/flannel/dist/flanneld /opt/bin/flanneld
COPY dist/mk-docker-opts.sh /opt/bin/