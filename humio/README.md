# Cloud Foundry and Observability through Humio demo

## Deploy the apps

You can deploy the apps from the `01-before` and `03-after` directories using `cf push`. `cf push` relies on you already having logged into Cloud Foundry.

## Execute the experiment

You can execute the experiment using:

```
$ chaos run experiment.json
```

***NOTE:*** Please be aware that until rollback are implemented, the experiment will leave the system in a potentially broken state.
