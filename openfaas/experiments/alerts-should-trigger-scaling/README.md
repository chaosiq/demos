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

Here is a sample of this experiment being [executed][asciinema]:

![Chaos Toolkit Experiment Run][run]

[asciinema]: https://asciinema.org/a/178120
[run]: https://raw.githubusercontent.com/chaosiq/demos/master/openfaas/experiments/alerts-should-trigger-scaling/chaostoolkit-run.gif

At the same time, let's have a view of our system via [Weave Cloud][weave] and
of the triggered alert via Prometheus.

[weave]: https://cloud.weave.works/

![System View via Weave Scope and Prometheus][weavescope]

[weavescope]: https://raw.githubusercontent.com/chaosiq/demos/master/openfaas/experiments/alerts-should-trigger-scaling/system-view.gif

## Reporting

You can create a [report][chaostoolkitreporting] of the results as follows:

```
(chaostk) $ chaos report --export-format=pdf journal.json report.pdf
```

[chaostoolkitreporting]: https://github.com/chaostoolkit/chaostoolkit-reporting


You can find an example of such a report [here][report].

[report]: https://raw.githubusercontent.com/chaosiq/demos/master/openfaas/experiments/alerts-should-trigger-scaling/report.pdf

Most interestingly, we can see our probes captured the followings.

The alert is received by OpenFaaS gateway which triggers a scale up op:

```
2018-04-24T15:44:43.333350326Z 2018/04/24 15:44:43 Alert received.
2018-04-24T15:44:43.333504616Z 2018/04/24 15:44:43 {"receiver":"scale-up","status":"firing","alerts":[{"status":"firing","labels":{"alertname":"APIHighInvocationRate","function_name":"astre","monitor":"faas-monitor","service":"gateway","severity":"major","value":"64.5870825834833"},"annotations":{"description":"High invocation total on ","summary":"High invocation total on "},"startsAt":"2018-04-24T15:44:38.325165052Z","endsAt":"0001-01-01T00:00:00Z","generatorURL":"..."}],"groupLabels":{"alertname":"APIHighInvocationRate","service":"gateway"},"commonLabels":{"alertname":"APIHighInvocationRate","function_name":"astre","monitor":"faas-monitor","service":"gateway","severity":"major","value":"64.5870825834833"},"commonAnnotations":{"description":"High invocation total on ","summary":"High invocation total on "},"externalURL":"...","version":"4","groupKey":"{}:{alertname=\"APIHighInvocationRate\", service=\"gateway\"}"}
2018-04-24T15:44:43.341766483Z 2018/04/24 15:44:43 [Scale] function=astre 1 => 5.
```

Then, later on, scaling down as follows:
```
2018-04-24T15:45:13.334234404Z 2018/04/24 15:45:13 Alert received.
2018-04-24T15:45:13.334414464Z 2018/04/24 15:45:13 {"receiver":"scale-up","status":"resolved","alerts":[{"status":"resolved","labels":{"alertname":"APIHighInvocationRate","function_name":"astre","monitor":"faas-monitor","service":"gateway","severity":"major","value":"64.5870825834833"},"annotations":{"description":"High invocation total on ","summary":"High invocation total on "},"startsAt":"2018-04-24T15:44:38.325165052Z","endsAt":"2018-04-24T15:45:08.325158179Z","generatorURL":"..."}],"groupLabels":{"alertname":"APIHighInvocationRate","service":"gateway"},"commonLabels":{"alertname":"APIHighInvocationRate","function_name":"astre","monitor":"faas-monitor","service":"gateway","severity":"major","value":"64.5870825834833"},"commonAnnotations":{"description":"High invocation total on ","summary":"High invocation total on "},"externalURL":"...","version":"4","groupKey":"{}:{alertname=\"APIHighInvocationRate\", service=\"gateway\"}"}
2018-04-24T15:45:13.340249202Z 2018/04/24 15:45:13 [Scale] function=astre 5 => 1.
```

Surely, when we query Prometheus for which alerts were active during the run:

```json
{
    "metric": {
    "__name__": "ALERTS",
    "alertname": "APIHighInvocationRate",
    "alertstate": "pending",
    "function_name": "astre",
    "service": "gateway",
    "severity": "major",
    "value": "64.5870825834833"
    },
    "value": [
    1524584674.374,
    "1"
    ]
}
```

The state is `"pending"` which is before `"firing"`. Indeed that alert is based
on a trend during a given period and we queried before that trend was confirmed.
The log of the gateway does tell us the alert did move to the `"firing"` state.