# Switching Google Cloud Engine Nodepool should not break system availability

## Learnings

Let's say your GCE nodes are corrupted or need patching, you know how to
create a new nodepool but you wonder if switching from one to the other might
impact your system availability. It should not but let's try, shall we?

## Requirements

### Environment

Make sure you have deployed a Kubernetes cluster and OpenFaaS as per the
main README of this repository.

Make sure you have the right Kubernetes credentials so that you can connect
to your cluster. Basically, if `kubectl` works, you should be fine as the Chaos
Toolkit uses the same credentials.

In addition, you will aso need credentials to connect to your GCE project via 
a service account file. Make sure to first [create one][createsa] and edit the
experiment `secrets` and `configuration` sections accordingly.

[createsa]: https://developers.google.com/api-client-library/python/auth/service-accounts#creatinganaccount

**WARNING:** This experiment is fairly powerful as it creates a new nodepool
on your cluster. As this is a demo, make sure you have the right environment
to toy with it first. The existing nodepool will not be deleted while the new
one will be deleted at the end of the experiment automatically. If not, you can
delete it as follows:

```
$ gcloud container node-pools list --cluster CLUSTER_ID yet-other-pool
```

### Vegeta

We are relying on [Vegeta][vegeta] to inject load into the system. Please
download the command line and make it available into your PATH.

[vegeta]: https://github.com/tsenart/vegeta

### Chaos Toolkit

You need to have the [Chaos Toolkit][chaostoolkit] installed on your local
machine as well as the [Kubernetes][chaostoolkitk8s] and [GCE][chaostoolkitgce]
dependencies:

```
(chaostk) $ pip install -U chaostoolkit chaostoolkit-kubernetes chaostoolkit-google-cloud
```

[chaostoolkit]: http://chaostoolkit.org/reference/usage/install/
[chaostoolkitk8s]: https://github.com/chaostoolkit/chaostoolkit-kubernetes
[chaostoolkitgce]: https://github.com/chaostoolkit-incubator/chaostoolkit-google-cloud

Also, to generate reports, you will need to install the
[chaostoolkit-reporting][chaostoolkitreporting] plugin.

## Usage

Run the experiment as follows:

```
(chaostk) $ cd repo/toplevel/directory
(chaostk) $ chaos run experiments/switching-gce-nodepool/experiment.json
```

Here is a sample of this experiment being [executed][asciinema]:

![Chaos Toolkit Experiment Run][run]

[asciinema]: https://asciinema.org/a/178130
[run]: https://raw.githubusercontent.com/chaosiq/demos/master/openfaas/experiments/switching-gce-nodepool/chaostoolkit-run.gif

At the same time, let's have a view of our system via [Weave Cloud][weave].

[weave]: https://cloud.weave.works/

![System View via Weave Scope][weavescope]

[weavescope]: https://raw.githubusercontent.com/chaosiq/demos/master/openfaas/experiments/switching-gce-nodepool/system-view.gif

Notice how the new node joins the cluster and how OpenFaaS reacts by distributing
the load accordingly once the nodes on the existing nodepool have been cordon.

Note also how we uncordon those nodes and delete the new nodepool in the rollbacks.

## Reporting

You can create a [report][chaostoolkitreporting] of the results as follows:

```
(chaostk) $ chaos report --export-format=pdf journal.json report.pdf
```

[chaostoolkitreporting]: https://github.com/chaostoolkit/chaostoolkit-reporting

You can find an example of such a report [here][report].

[report]: https://raw.githubusercontent.com/chaosiq/demos/master/openfaas/experiments/switching-gce-nodepool/report.pdf

We notice a few 503 indicating that some users could be impacted in the operation.
However this could also be an experiment artifact.