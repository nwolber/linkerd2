set -eu

bindir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $bindir/_tag.sh
. $bindir/_docker.sh

prepare_env() {
    GOOS=${GOOS:-linux}
    GOARCH=${GOARCH:-amd64}
    GOARM=${GOARM:-}
    DOCKER_PLATFORM=${DOCKER_PLATFORM:-"linux/amd64"}
    BASE_IMAGE="$(docker_repo base):2017-10-30.01$(platform_extension)"
    GODEPS_IMAGE="$(docker_repo go-deps):$(go_deps_sha)"
    
    case ${LINKERD_ARCH:-} in
    "arm")
        GOARCH=arm
        GOARM=7
        DOCKER_PLATFORM="linux/arm/7"
        ;;
    "arm64")
        GOARCH=arm64
        GOARM=
        DOCKER_PLATFORM="linux/arm64"
        ;;
    esac
}