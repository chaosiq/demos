This is our OpenFaaS function, it merely responds to calls such as:

```
GET http://demo.foo.bar/function/astre
Authorization: Basic XYZ
Content-Type: application/json

{"city": "Paris"}
```

It then returns:

```json
{
  "dawn": "2018-04-23T05:12:05+01:00",
  "sunrise": "2018-04-23T05:48:45+01:00",
  "noon": "2018-04-23T12:58:53+01:00",
  "sunset": "2018-04-23T20:09:01+01:00",
  "dusk": "2018-04-23T20:45:41+01:00"
}
```

You should not need to rebuild this image, but if you wish to do so, you will
need the [faas-cli] installed.

[faas-cli]: https://github.com/openfaas/faas-cli

Make sure to export the right address to your OpenFaaS endpoint. For instance,
with a minikube cluster:

```
$ export OPENFAAS_URL=$(minikube ip):31112
```

Then you can rebuild the image:

```
$ faas-cli template pull https://github.com/openfaas-incubator/python-flask-template
$ faas-cli build -f astre.yml
```

And deploy it:

```
$ faas-cli deploy -f astre.yml
```

Deploying will require you have access to the Docker repository where the
image will be pushed to.