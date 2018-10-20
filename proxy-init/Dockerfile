## compile proxy-init utility
ARG GODEPS_IMAGE
ARG BASE_IMAGE
FROM ${GODEPS_IMAGE} as golang
WORKDIR /go/src/github.com/linkerd/linkerd2
COPY ./proxy-init ./proxy-init
ARG GOOS
ARG GOARCH
ARG GOARM
RUN CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} GOARM=${GOARM} go install -v ./proxy-init/

## package runtime
FROM ${BASE_IMAGE}
COPY --from=golang /go/bin/proxy-init /usr/local/bin/proxy-init
ENTRYPOINT ["/usr/local/bin/proxy-init"]
