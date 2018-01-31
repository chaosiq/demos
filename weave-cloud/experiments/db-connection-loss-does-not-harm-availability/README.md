# Database connection loss does not impact application availability

In this [Chaos Toolkit][chaostoolkit] experiment, we are going to see how we
can respond to losing connection to the database and prevent our application
to be shortly unavailable.

[chaostoolkit]: http://chaostoolkit.org/

## Prerequisites

This experiment expects you have [deployed the demo environment][install] and
installed the [chaostoolkit][chaosinstall] package on your machine.

[install]: https://github.com/chaosiq/demos/blob/master/weave-cloud/README.md
[chaosinstall]: http://chaostoolkit.org/reference/usage/install/

Make sure you can access the application at https://app.cosmos.foo before
running the experiment.

### Weave Cloud

Please, do make sure you have created an account on [Weave Cloud][weave] to
benefit from the workflow explored in this demo.

[weave]: https://cloud.weave.works/

### Chaos Toolkit Dependencies

For this demo, you will need to install the followings:

```console
$ pip install -U chaostoolkit chaostoolkit-reporting chaosiq
```

Note that the [chaostoolkit-reporting][reporting] package, for the report
generation, requires system-wide dependencies. This is not necessary for the
run workflow.

[reporting]: http://chaostoolkit.org/reference/usage/report/

## Experimental Workflow

Onece your environment is settled and the application can be reached, you
may start the experimental workflow.

### Discovering the system capabilities

The first step is to [discover][] your environment as follows:

[discover]: http://chaostoolkit.org/reference/usage/discover/

```console
$ chaos discover chaostoolkit-kubernetes
[2018-01-31 18:35:35 INFO] Attempting to download and install package 'chaostoolkit-kubernetes'
[2018-01-31 18:35:39 INFO] Package downloaded and installed in current environment
[2018-01-31 18:35:39 INFO] Discovering capabilities from chaostoolkit-kubernetes
[2018-01-31 18:35:39 INFO] Searching for actions
[2018-01-31 18:35:39 INFO] Searching for probes
[2018-01-31 18:35:39 INFO] Searching for actions
[2018-01-31 18:35:39 INFO] Searching for probes
[2018-01-31 18:35:39 INFO] Discovering Kubernetes system
[2018-01-31 18:35:39 INFO] Discovery report saved in ./discovery.json
```

This will generate a discovery output that can contains information we can
use to init an ad-hoc experiment.

### Initialize a chaos experiment

Now that we have discovered the system, we can [initialize][init] an experiment
as follows:

[init]: http://chaostoolkit.org/reference/usage/init/

```console
$ chaos init
```

At this stage, we have an experiment that is almost ready to be executed. We
still need to fill the missing gaps.

### Run the experiment

We are now ready to [run][] this experiment as follows:

[run]: http://chaostoolkit.org/reference/usage/run/

```console
$ chaos run experiment.json
```

### Create a report

Finally, let's generate a report from the run:

```console
$ chaos report --export-format=pdf chaos-report.json report.pdf
```
