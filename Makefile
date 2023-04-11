# Multi architecture builds
TARGETS = amd64 arm64
PLATFORM = linux
BUILD_EXE ?= podman
BUILD_TARGETS = $(TARGETS:=.build)
BUILD_CI_TARGETS = $(TARGETS:=.container)
IMAGE_PUSH_TARGETS = $(TARGETS:=.push-image)
MANIFEST_CREATE_TARGETS = $(PLATFORM:=.create-manifest)
MANIFEST_PUSH_TARGETS = $(PLATFORM:=.push-manifest)
BUILD_OPT=""
IMAGE_TAG=v1.1
IMAGE_PREFIX=fuse-device-plugin
IMAGE_REGISTRY=quay.io/cgruver0/che
BINARY=fuse-device-plugin


.DEFAULT_GOAL := build

# Build binary, container and then push to image registry
.PHONY: all
all: build container push-image create-manifest push-manifest

# Build go binaries
PHONY: build $(BUILD_TARGETS)
build: $(BUILD_TARGETS)
%.build:
	TARGET=$(*) GOOS=linux GOARCH=$(*) CGO_ENABLED=0 GO111MODULE=on go build -o ./bin/$(BINARY)-${PLATFORM}-$(*)

# Build container image
PHONY: container $(BUILD_CI_TARGETS)
container: $(BUILD_CI_TARGETS)
%.container:
	TARGET=$(*) ${BUILD_EXE} build . --platform ${PLATFORM}/$(*) -t $(IMAGE_REGISTRY)/$(IMAGE_PREFIX):build-$(*)-${IMAGE_TAG} --build-arg build_arch=${PLATFORM}-${*} -f Containerfile

#Container image push
PHONY: push-image $(IMAGE_PUSH_TARGETS)
push-image: $(IMAGE_PUSH_TARGETS)
%.push-image:
	TARGET=$(*) ${BUILD_EXE} push $(IMAGE_REGISTRY)/$(IMAGE_PREFIX):build-$(*)-${IMAGE_TAG}

# Create container manifest for amd64 and arm64
PHONY: create-manifest $(MANIFEST_CREATE_TARGETS)
create-manifest: $(MANIFEST_CREATE_TARGETS)
%.create-manifest:
	${BUILD_EXE} manifest create $(IMAGE_REGISTRY)/$(IMAGE_PREFIX):${IMAGE_TAG} -a $(IMAGE_REGISTRY)/$(IMAGE_PREFIX):build-amd64-${IMAGE_TAG} -a $(IMAGE_REGISTRY)/$(IMAGE_PREFIX):build-arm64-${IMAGE_TAG}

# container push manifest and inspect
PHONY: push-manifest $(MANIFEST_PUSH_TARGETS)
push-manifest: $(MANIFEST_PUSH_TARGETS)
%.push-manifest:
	${BUILD_EXE} manifest push --all $(IMAGE_REGISTRY)/$(IMAGE_PREFIX):${IMAGE_TAG} $(IMAGE_REGISTRY)/$(IMAGE_PREFIX):${IMAGE_TAG}
	${BUILD_EXE} manifest inspect $(IMAGE_REGISTRY)/$(IMAGE_PREFIX):${IMAGE_TAG}
