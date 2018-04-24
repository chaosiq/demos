# Deploy Kubernetes with Google Kubernetes Engine

This guide is not a full guide about deploying a Kubernetes cluster on
Google Cloud. But it contains the main steps to help you getting there.

Using Google Cloud is not free (though on a new account, you get credits that
are more than enough to cover this demo), so please understand the potential
involved costs.

## List Your Organizations
```console
$ gcloud organizations list
```

Pick the one you target and create a variable for it:

```
$ export ORGID=1xxxxxxxxx
```

## Create A New Project

```console
$ export PROJECT_ID=chaosiqdemos
$ gcloud projects create $PROJECT_ID --organization=$ORGID
$ gcloud config set project $PROJECT_ID
```

```console
$ export ZONE=us-west1-a
$ gcloud config set project $PROJECT_ID
$ gcloud config set compute/zone $ZONE
```

Enable billing for that project from the console!

## Create Your Kubernetes Cluster

```console
$ gcloud services enable container.googleapis.com
```

```console
$ export CLUSTER_NAME=demos-cluster
$ gcloud container clusters create $CLUSTER_NAME \
    --cluster-version=1.9.6-gke.0 \
    --enable-autorepair \
    --enable-autoupgrade \
    --enable-network-policy \
    --no-enable-basic-auth \
    --no-enable-legacy-authorization \
    --num-nodes=1 \
    --image-type=COS \
    --zone=$ZONE \
    --no-enable-cloud-logging \
    --labels=environment=demos
```

### Retrieve The Cluster Credentials

```console
$ gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE \
    --project $PROJECT_ID
```

### Grant cluster-admin to your identity

see https://coreos.com/operators/prometheus/docs/latest/troubleshooting.html
and this https://medium.com/@lestrrat/configuring-rbac-for-your-kubernetes-service-accounts-c348b64eb242

```console
$ ACCOUNT=$(gcloud info --format='value(config.account)')
$ kubectl create clusterrolebinding user-admin-binding \
    --clusterrole=cluster-admin --user=$ACCOUNT
```

Your email comes from the first command's output.

## Create a regional static IP

```console
$ export REGION=us-west1
$ gcloud compute addresses create kubernetes-demos-cluster-ingress \
    --region=$REGION
$ export DEMO_CLUSTER_PUBLIC_IP_ADDR=$(gcloud compute addresses \
    describe kubernetes-demos-cluster-ingress --region $REGION \
    --format='value(address)')
```

## Create Nginx ingress controller

First edit `manifests/service/nginx-ingress-gce.yaml` and replace the
`loadBalancerIP` address with the regional static IP you created above.

```console
$ kubectl apply -f manifests/namespace/nginx-ingress.yaml \
    -f manifests/deployment/default-backend.yaml \
    -f manifests/service/default-backend.yaml \
    -f manifests/configmap/nginx-ingress.yaml \
    -f manifests/rbac/nginx-ingress.yaml \
    -f manifests/deployment/nginx-ingress.yaml \
    -f manifests/serviceaccount/nginx-ingress.yaml \
    -f manifests/service/nginx-ingress-gce.yaml
```
