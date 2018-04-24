# Deploy Kubernetes with Minikube

This guide covers the commands to get the demo ready in a minikube instance so
you can try it locally.

## Create the cluster

Adjust the parameters to your local machine:

```
$ minikube start \
    --kubernetes-version v1.10.0 \
    --memory 4096 \
    --cpus 2 \
    --vm-driver kvm2
```

## Create Nginx ingress controller

```console
$ minikube addons enable ingress
```
