# Chaos Experiments with Chaos Toolkit and Weave Cloud

## Overview

This demo will walk you through experimenting chaos engineering against a
Kubernetes cluster, with [Weave Cloud][weavecloud] deployed, using the
[Chaos Toolkit][chaostoolkit].

[chaostoolkit]: http://chaostoolkit.org/
[weavecloud]: https://cloud.weave.works/
[rook]: https://rook.io/
[stolon]: http://stolon.io/
[nginx]: https://github.com/kubernetes/ingress-nginx
[etcd]: https://github.com/coreos/etcd
[rbac]: https://kubernetes.io/docs/admin/authorization/rbac/
[minikube]: https://github.com/kubernetes/minikube

## Architecture

This demo tries to showcase a fairly rich stack:

* storage: a distributed block storage provided by [rook][rook]
* k/v store: a distributed K/V store via [etcd][etcd]
* database: a replicated PostgreSQL through [stolon][stolon]
* ingress: a L7 ingress controller via [nginx][nginx]
* a basic web application

In additon, the Kubernetes cluster is in version 1.8 and has [RBAC][rbac]
enabled.

### Functional Dependencies

Both the K/V store and the database are configured to use the distributed
storage and therefore rely on its availability.

The database controller relies on the K/V store to be available.

The frontend application relies on the database to be available.

## Getting Started

**NOTE:** This is not a production ready setup. It provides a fairly common
stack but do not run it for production please.

### Requirements

This demo was tried with [minikube][minikube] 0.24.1 and Kubernetes 1.8. It
only relies on Kubernetes and nothing specific on the host. It should therefore
run on any Kubernetes environment.

However, expect to have at least 4Gb of RAM you can dedicated to the demo
to run and 2 VCPU. More would be better.

### Weave Cloud Account

This demo expects you own a [Weave Cloud][weavecloud] account. Please make sure
you create one before going further.

### Starting the Environment

Create the environment as follows:

```console
$ ./bootstrap.sh
```

This will take a few minutes to complete, depending on your machine.

You may look at the options of that script (to suit your needs) as follows:

```console
$ ./bootstrap.sh -h
```

For instance, to use the `kvm2` VM driver for minikube, run:

```console
$ ./bootstrap.sh --vm-driver kvm2
```

Once completed, you should have the entire stack ready and your application
available.

### Deploy weave cloud components

To let weave monitor your cluster, you must deploy its components. Please
follow their [procedures][weavecloud].

### Resolve the application

Your application is designed to resolve at `https://app.cosmos.foo/`, and since
that domain does not exist (well it wouldn't resolve to your local machine
anyway), you must tell your host where to find it. The easiest is to update
the `/etc/hosts` file of your machine as follows:

```console
$ echo "$(minikube ip) app.cosmos.foo" | sudo tee -a /etc/hosts
```

If you have added that line before, you must edit the file instead.

Once this is done, you can point your browser at https://app.cosmos.foo

Note that the certificate is self-signed so your browser will (rightly)
complained. Go ahead and accept whatever it asks you to access the application.

The application is a dummy web application that displays content that you add
via its [admin page][admin]. Simply add some entries and come back to the home
page.

[admin]: https://app.cosmos.foo/admin/star/

## Cleanup

This part is much simpler. First remove the line from `/etc/hosts` pointing
at the `app.cosmos.foo` domain. Next, delete the cluster as follows:

```console
$ minikube delete
```

Obviously, if you did not use minikube, you will have to clean up manually.

Notice that weave cloud should then not be able to see your cluster.