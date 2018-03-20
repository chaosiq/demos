
# Day of Cloud Native Workshop, Oslo

This workshop was conducted at the [Day of Cloud Native](https://www.code-conf.com/2018/dcn/) in Oslo, March 2018. The goals of this workshop were to:

* Introduce [Chaos Engineering](http://principlesofchaos.org/)
* Introduce why Chaos Engineering is important to Cloud Native systems
* Introduce the free and open source [Chaos Toolkit](http://chaostoolkit.org/)
* Discuss production failure experiences and how to construct Game Days
* Show how to build automated Chaos Experiments with the Chaos Toolkit

Conversations and outcomes from this workshop are documented in the ["Geek on a Harley, Road to GOTO Chicago: Chaos Tour"](https://leanpub.com/geekonaharleychaostour) book. The book is free but if you give a donation all proceeds will go to [Girls Who Code](https://girlswhocode.com/).

## Prerequisites

To run this workshop it is assumed that you have installed the [Chaos Toolkit CLI][chaos-toolkit] and have access to a Kubernetes cluster.

[chaos-toolkit]: https://github.com/chaostoolkit/chaostoolkit

## Commands executed throughout the workshop

The following commands are provided for convenience when working through this workshop.

To apply the "before chaos learning" system:

```
$ kubectl apply -f 01-before/deployment
```

To discover what can be conducted against your kubernetes cluster:

```
$ chaos discover chaostoolkit-kubernetes
```

To initialise a new chaos experiment using what has been discovered:

```
$ chaos init
```

To run the newly created automated chaos experiment:

```
$ chaos run experiment.json
```

To apply the "after chaos learning" system:

```
$ kubectl apply -f 03-after/deployment
```

To re-run the experiment after the new, improved system has been deployed:

```
$ chaos run experiment.json
```

Optional, to create a chaos experiment report for sharing with others:

```
$ chaos report —export-format=pdf journal.json report.pdf
```
