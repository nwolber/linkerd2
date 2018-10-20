set -eu

bindir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $bindir/_log.sh

# TODO this should be set to the canonical public docker regsitry; we can override this
# docker regsistry in, for instance, CI.
export DOCKER_REGISTRY="${DOCKER_REGISTRY:-gcr.io/linkerd-io}"

# When set, causes docker's build output to be emitted to stderr.
export DOCKER_TRACE="${DOCKER_TRACE:-}"

docker_repo() {
    repo="$1"

    name="$repo"
    if [ -n "${DOCKER_IMAGE_PREFIX:-}" ]; then
        name="$DOCKER_IMAGE_PREFIX$name"
    fi
    
    if [ -n "${DOCKER_REGISTRY:-}" ]; then
        name="$DOCKER_REGISTRY/$name"
    fi

    echo "$name"
}

docker_build() {
    repo=$(docker_repo "$1")
    shift

    tag="$1"
    shift

    file="$1"
    shift

    extra="$@"

    output="/dev/null"
    if [ -n "$DOCKER_TRACE" ]; then
        output="/dev/stderr"
    fi

    rootdir="$( cd $bindir/.. && pwd )"

    log_debug "  :; docker build $rootdir -t $repo:$tag -f $file --platform=${DOCKER_PLATFORM:-} --build-arg GOOS=${GOOS:-} --build-arg GOARCH=${GOARCH:-} --build-arg GOARM=${GOARM:-} --build-arg BASE_IMAGE=${BASE_IMAGE:-} --build-arg GODEPS_IMAGE=${GODEPS_IMAGE:-} \ $extra"
    docker build $rootdir \
        -t "$repo:$tag" \
        -f "$file" \
        --platform=${DOCKER_PLATFORM:-} \
        --build-arg GOOS=${GOOS:-} \
        --build-arg GOARCH=${GOARCH:-} \
        --build-arg GOARM=${GOARM:-} \
        --build-arg BASE_IMAGE=${BASE_IMAGE:-} \
        --build-arg GODEPS_IMAGE=${GODEPS_IMAGE:-} \
        $extra \
        > "$output"

    echo "$repo:$tag"
}

docker_pull() {
    repo=$(docker_repo "$1")
    tag="$2"
    log_debug "  :; docker pull $repo:$tag"
    docker pull "$repo:$tag" --platform=${DOCKER_PLATFORM:-}
}

docker_push() {
    repo=$(docker_repo "$1")
    tag="$2"
    log_debug "  :; docker push $repo:$tag"
    docker push "$repo:$tag"
}

docker_retag() {
    repo=$(docker_repo "$1")
    from="$2"
    to="$3"
    log_debug "  :; docker tag $repo:$from $repo:$to"
    docker tag "$repo:$from" "$repo:$to"
    echo "$repo:$to"
}

docker_manifest_create() {
    repo=$(docker_repo "$1")
    shift

    manifests=""
    while [ $# -gt 0 ]; do
        tag="$(LINKERD_ARCH=$1 head_root_tag)"
        manifests="$manifests $repo:$tag"
        shift
    done

    output="/dev/null"
    if [ -n "$DOCKER_TRACE" ]; then
        output="/dev/stderr"
    fi

    tag="$(NO_PLATFORM=1 head_root_tag)"

    log_debug "  :; docker manifest create $repo:$tag$manifests"
    docker manifest create "$repo:$tag" $manifests > "$output"
}

docker_manifest_annotate() {
    repo=$(docker_repo "$1")
    shift

    arch=$1
    shift

    list_tag="$(NO_PLATFORM=1 head_root_tag)"
    manifest_tag="$(LINKERD_ARCH=$arch head_root_tag)"

    if [ $arch == "arm" ]; then
        variant="v7"
    fi

    output="/dev/null"
    if [ -n "$DOCKER_TRACE" ]; then
        output="/dev/stderr"
    fi

    if [ -z ${variant:-} ]; then
        log_debug "  :; docker manifest annotate --arch $arch $repo:$list_tag $repo:$manifest_tag"
        docker manifest annotate --arch "$arch" "$repo:$list_tag" "$repo:$manifest_tag" > "$output"
    else
        log_debug "  :; docker manifest annotate --arch $arch --variant $variant $repo:$list_tag $repo:$manifest_tag"
        docker manifest annotate --arch "$arch" --variant "$variant" "$repo:$list_tag" "$repo:$manifest_tag" > "$output"
    fi
}

docker_manifest_push() {
    repo=$(docker_repo "$1")
    shift

    output="/dev/null"
    if [ -n "$DOCKER_TRACE" ]; then
        output="/dev/stderr"
    fi

    log_debug "  :; docker manifest push --purge $repo"
    docker manifest push --purge "$repo" > "$output"
}