FROM golang:1.12 as build
WORKDIR /src
ARG VERSION

# Run go mod stuff only when needed
COPY go.mod go.sum ./
RUN go mod download

# Now copy the rest
COPY . ./

RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags "-X main.version=$VERSION -extldflags -static" -o ./bin/csi-snapshotter ./cmd/...

FROM gcr.io/distroless/static:latest
LABEL maintainers="Kubernetes Authors"
LABEL description="CSI External Resizer"

COPY --from=build /src/bin/csi-snapshotter csi-snapshotter
ENTRYPOINT ["/csi-snapshotter"]
