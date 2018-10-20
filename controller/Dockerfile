## compile controller services
ARG GODEPS_IMAGE
FROM ${GODEPS_IMAGE} as golang
WORKDIR /go/src/github.com/linkerd/linkerd2
COPY controller/gen controller/gen
COPY pkg pkg
COPY controller controller

# use `install` so that we produce multiple binaries
ARG GOOS
ARG GOARCH
ARG GOARM
RUN CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} GOARM=${GOARM} go install ./pkg/...
RUN CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} GOARM=${GOARM} go install ./controller/cmd/...

## package runtime
FROM scratch
ENV PATH=$PATH:/go/bin
COPY --from=golang /go/bin /go/bin

ARG LINKERD_VERSION
ENV LINKERD_CONTAINER_VERSION_OVERRIDE=${LINKERD_VERSION}
