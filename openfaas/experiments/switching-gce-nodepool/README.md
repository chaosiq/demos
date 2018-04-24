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

## Reporting

You can create a [report][chaostoolkitreporting] of the results as follows:

```
(chaostk) $ chaos report --export-format=pdf journal.json report.pdf
```

[chaostoolkitreporting]: https://github.com/chaostoolkit/chaostoolkit-reporting