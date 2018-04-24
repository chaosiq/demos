# Terminating an OpenFaaS function should not impact users with system availability

## Learnings

We hope that terminating one OpenFaaS pod function should not impact our users
since Kubernetes looks to keep our system aligned with our expectations. But,
are we not impacting our users at all? Is one pod enough overall?

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
(chaostk) $ chaos run experiments/terminate-function/experiment.json
```

Here is a sample of this experiment being executed:

[![asciicast](https://asciinema.org/a/178112.png)](https://asciinema.org/a/178112)

At the same time, let's have a view of our system via [Weave Cloud][weave].

[weave]: https://cloud.weave.works/

![System View via Weave Scope][weavescope]

[weavescope]: https://raw.githubusercontent.com/chaosiq/demos/master/openfaas/experiments/terminate-function/terminate-function-weave.gif

## Reporting

You can create a [report][chaostoolkitreporting] of the results as follows:

```
(chaostk) $ chaos report --export-format=pdf journal.json report.pdf
```

[chaostoolkitreporting]: https://github.com/chaostoolkit/chaostoolkit-reporting

You can find an example of such a report [here].

[report]: https://raw.githubusercontent.com/chaosiq/demos/master/openfaas/experiments/terminate-function/report.pdf