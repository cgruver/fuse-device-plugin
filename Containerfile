FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# fuse-device-plugin binary based on architecture
ARG build_arch
COPY fuse-device-plugin-${build_arch} /usr/bin/fuse-device-plugin

# replace with your desire device count
CMD ["fuse-device-plugin", "--mounts_allowed", "5000"]
