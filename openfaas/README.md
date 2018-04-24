# Chaos Engineering OpenFaaS on Kubernetes with the Chaos Toolkit

This guide contains a set of [Chaos Toolkit][chaostoolkit] Chaos Engineering
experiments targetting [OpenFaaS][openfaas] and [Kubernetes][k8s].

[chaostoolkit]: http://chaostoolkit.org/
[openfaas]: https://github.com/openfaas/faas
[k8s]: https://kubernetes.io/
[gce]: https://cloud.google.com/compute/
[gke]: https://cloud.google.com/kubernetes-engine/
[mk]: https://kubernetes.io/docs/getting-started-guides/minikube/

## Available Experiments

The following experiments are provided:

* [Terminating an OpenFaaS function pod][term] should not impact users querying it
* Does [OpenFaaS scale up and down automatically][scale] when load gets high/down?
* [[GCE only][gce]] [Switching to a new nodepool][nnp] should have a minimum impact on
  users

New experiments will be added in the future.

[term]: https://github.com/chaosiq/demos/tree/master/openfaas/experiments/terminate-function
[scale]: https://github.com/chaosiq/demos/tree/master/openfaas/experiments/alerts-should-trigger-scaling
[nnp]: https://github.com/chaosiq/demos/tree/master/openfaas/experiments/switching-gce-nodepool

## Requirements

Those experiments can be reproduced on your environment. Please read the
following guides to set it up:

* [minikube-setup][mks]: if you wish to run on a local [Minikube][mk]
* [gce-setup][gces]: if you wish to run against [Google Kubernetes Engine][gke]
* [openfaas-setup][ofaass]: once you have you created your Kubernetes cluster, how to
  deploy OpenFaaS

[mks]: https://github.com/chaosiq/demos/blob/master/openfaas/minikube-setup.md
[gces]: https://github.com/chaosiq/demos/blob/master/openfaas/gce-setup.md
[ofaass]: https://github.com/chaosiq/demos/blob/master/openfaas/openfaas-setup.md

## Usage

Please navigate each experiment for further instructions.

## Want to discuss these experiments?

Please join us on the Chaos Toolkit [slack](https://join.chaostoolkit.org/) :)