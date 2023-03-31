# fuse device plugin

> Inspired by @JasonChenY's [fuse-device-plugin](https://github.com/JasonChenY/fuse-device-plugin)

## Environment requirements

[Kubernetes](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/resource-management/device-plugin.md) version >= 1.8.

## background

When using sshfs or s3fs, etc., if you need to use /dev/fuse in the container, you need to use the privileged mode, which will bring many problems, such as the number of GPUs cannot be shielded, and all the number of GPU cards on the host can be seen in the container. Based on this, we can implement fuse-device-plugin in the same way as nvidia-device-plugin, and use /dev/fuse by injection

## Requirements

Please make sure before using `--feature-gates=DevicePlugins=true` Turned on.

```bash
kubelet -h | grep "DevicePlugins"
```

## deploy:

* kubernete version < 1.16

```bash
kubectl create -f fuse-device-plugin.yml
```

* kubernete version > 1.16

```
kubectl create -f fuse-device-plugin-k8s-1.16.yml
```

## use

reference [fuse-test.yml](fuse-test.yml)

```yaml
spec: 
  containers:
  - ...
    resources:
      limits:
        github.com/fuse: 1
```

# Special thanks to

![Goland](https://blog.jetbrains.com/wp-content/uploads/2019/01/goland_icon.svg)
