# Deploy OpenFaas in your Kubernetes Cluster

```console
$ kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml \
    -f https://raw.githubusercontent.com/openfaas/faas-netes/master/yaml/rbac.yml \
    -f https://raw.githubusercontent.com/openfaas/faas-netes/master/yaml/alertmanager_config.yml \
    -f https://raw.githubusercontent.com/openfaas/faas-netes/master/yaml/alertmanager.yml \
    -f https://raw.githubusercontent.com/openfaas/faas-netes/master/yaml/prometheus_config.yml \
    -f https://raw.githubusercontent.com/openfaas/faas-netes/master/yaml/prometheus.yml \
    -f https://raw.githubusercontent.com/openfaas/faas-netes/master/yaml/gateway.yml \
    -f https://raw.githubusercontent.com/openfaas/faas-netes/master/yaml/nats.yml \
    -f https://raw.githubusercontent.com/openfaas/faas-netes/master/yaml/faasnetesd.yml \
    -f https://raw.githubusercontent.com/openfaas/faas-netes/master/yaml/queueworker.yml
```

# Create Ingress to OpenFaas Gateway

## Pretend we have a Domain

```console
$ export FAKE_DEMO_DOMAIN=demo.foo.bar
$ echo "$(minikube ip) $FAKE_DEMO_DOMAIN" | sudo tee -a /etc/hosts
```

## Create a secret for basic authentication

WARNING: If you consider putting this demo out, please change the password
below and change the basic header authentication in each experiment file as well
as the json files of the data directory.

```console
$ htpasswd -b -c auth jane demo
$ kubectl -n openfaas create secret generic basic-auth --from-file=auth
```

## Deploy ingress

```console
$ kubectl apply -f manifests/ingress/openfaas-gateway.yaml
```

Once it's all up and running, you will be able to see the OpenFaaS dashboard
at http://demo.foo.bar/ui/ and log with the credentials you created before.

## Optional steps

The following steps are not mandatory so you can skip them.

### Create a self-signed certificate

Until [this feature request][faasclitls] is implemented on faas-cli, you can
skip this section as it won't allow you to deploy with a self-signed
certificate.

[faasclitls]: https://github.com/openfaas/faas-cli/issues/376

```console
$ openssl req -x509 -newkey rsa:2048 -sha256 -nodes \
    -keyout manifests/secret/key.pem -out manifests/secret/cert.pem -days 365 \
    -subj "/C=FR/ST=/L=Paris/O=Company/OU=Org/CN=demo.foo.bar"
```

Replace the subject entries with whatever suits you.

### Create a secret for your certificate

Save your certificate as a secret for the ingress to use:

```console
$ kubectl -n openfaas create secret tls demo-tls \
    --key manifests/secret/key.pem \
    --cert manifests/secret/cert.pem
```

### Enable TLS in the ingress

If you do enable a certificate, please edit the
`manifests/ingress/openfaas-gateway.yaml` and uncomment the TLS section.
