# OpenFaaS alert should trigger scaling up of function

## Learnings

This experiments aims at validating the promise, from OpenFaaS, that it will
autoscale a function based on traffic.

If it does, we should see a burst of new pods while the load remains high
enough. Those pods should automatically go away when the load goes down.

## Requirements

### Environment

Make sure you have deployed a Kubernetes cluster and OpenFaaS as per the
main README of this repository.

Make sure you have the right Kubernetes credentials so that you can connect
to your cluster. Basically, if `kubectl` works, you should be fine as the Chaos
Toolkit uses the same credentials.

### Vegeta

We are relying on [Vegeta][vegeta] to inject load into the system. Please
download the command line and make it available into your PATH.

[vegeta]: https://github.com/tsenart/vegeta

### Chaos Toolkit

You need to have the [Chaos Toolkit][chaostoolkit] installed on your local
machine as well as the [Kubernetes][chaostoolkitk8s] dependency:

```
(chaostk) $ pip install -U chaostoolkit chaostoolkit-kubernetes
```

[chaostoolkit]: http://chaostoolkit.org/reference/usage/install/
[chaostoolkitk8s]: https://github.com/chaostoolkit/chaostoolkit-kubernetes

Also, to generate reports, you will need to install the
[chaostoolkit-reporting][chaostoolkitreporting] plugin.

## Usage

Run the experiment as follows:

```
(chaostk) $ cd repo/toplevel/directory
(chaostk) $ chaos run experiments/alerts-should-trigger-scalling/experiment.json
```

## Reporting

You can create a [report][chaostoolkitreporting] of the results as follows:

```
(chaostk) $ chaos report --export-format=pdf journal.json report.pdf
```

[chaostoolkitreporting]: https://github.com/chaostoolkit/chaostoolkit-reporting