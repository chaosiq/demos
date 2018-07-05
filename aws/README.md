# Chaos Toolkit Experiments for Systems and Application Hosted on AWS

This is a bunch of demos of applications living in AWS, in various ways such as
EKS, ECS or EC2.

## Requirements

### AWS Account and Credentials

Before you get going, you must ensure you have your local machine setup to be
able to access your AWS services, with the appropriate permissions. This means
you need to start by creating an AWS account if you don't have one, then create
an API key from the AWS IAM dashboard.

Please, read the [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration)
to get you setup with a valid `~/.aws/credentials` file. You may also modify
the [experiments to directly inject those credentials](https://docs.chaostoolkit.org/drivers/aws/#credentials)
if you prefer.

### Install the Chaos Toolkit and its Drivers

These demos use the [Chaos Toolkit](https://chaostoolkit.org/), so please
install it as per its [documentation](https://docs.chaostoolkit.org/reference/usage/install/)
and make sure the Python virtual environment is activated in your terminal
before you attempt to run them.

TL;DR: Run

```console
$ pip install -U chaostoolkit \
    chaostoolkit-aws \
    chaostoolkit-spring \
    chaostoolkit-kubernetes
```

#### Install the Chaos Toolkit driver for AWS

Once you have your Python virtual environment ready, as per the installation
procedure above, make sure to
[install the AWS driver](https://docs.chaostoolkit.org/drivers/aws/#install).

#### Install the Chaos Toolkit driver for Spring

Once you have your Python virtual environment ready, as per the installation
procedure above, make sure to
[install the Spring driver](https://docs.chaostoolkit.org/drivers/spring/#install).

#### Install the Chaos Toolkit driver for Kubernetes

Once you have your Python virtual environment ready, as per the installation
procedure above, make sure to
[install the AWS driver](https://docs.chaostoolkit.org/drivers/kubernetes/#install).

This is only required if you want to run some of the Kubernetes experiments.

## Build/test the apps

The backend and frontend apps are dummy SpringBoot application, both
configured with the
[Chaos Monkey for Spring plugin](https://github.com/codecentric/chaos-monkey-spring-boot).

Both are exposed to the public. The frontend on port 8080 and the backend on
port 8090.

When you call `http://<ftontend-address>/multiply?a=6&b=7`, you should
receive the response 42 (of course). That is computed by the backend called
from the frontend.

The apps are already built and available via docker, you may still want to
build and test them. This is not mandatory but should provide you with
the means to modify them for your own needs.

```
$ cd apps/backend
$ mvn test
$ mvn package dockerfile:build
```

The first maven command will build and run the unit tests. The second line
will build and package the app as a Docker image.

You can do the same with the frontend app.

### Create a Kubernetes cluster with EKS

The quickest way to get started with Kubernetes on AWS is by using the
[EKS](https://aws.amazon.com/eks/) service. To create a cluster quickly, please
consider using [eksctl](https://eksctl.io/), here is an example:

```console
$ eksctl create cluster --name=chaos-cluster --auto-kubeconfig
```

#### Deploy the Kubernetes resources

Once the EKS cluster is created, you can simply apply the Kubernetes
manifests as follows:

```console
$ kubectl --kubeconfig=$HOME/.kube/eksctl/clusters/chaos-cluster \
    apply \
    -f manifests/backend \
    -f manifests/frontend \
    -f manifests/ingress
```

Once all of them, which may take a few minutes for the AWS Load Balancer to
be up and running, lookup the DNS of the ELB:

```console
$ export ELB=`kubectl \
    --kubeconfig=$HOME/.kube/eksctl/clusters/chaos-cluster \
    -n kube-system get \
    svc traefik-ingress-service \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'`
$ export ELB_ROOT_URL="http://${ELB}"
$ kubectl --kubeconfig=$HOME/.kube/eksctl/clusters/chaos-cluster \
    patch ing app-ing \
    --type='json' \
    -p='[{"op": "replace", "path": "/spec/rules/0/host", "value":"'${ELB}'"}]'
```

Those lines are important. The first one captures the DNS of the AWS ELB into
a local environment variable. The second export command will be used by the
Chaos Toolkit experiment and the patch the ingress indicates to tell which
host we want to resolve on requests.

## Full cleanup

Do not forget to destroy your resources when you are finished.

```
$ kubectl --kubeconfig=$HOME/.kube/eksctl/clusters/chaos-cluster delete \
    -f manifests
$ eksctl delete cluster --name chaos-cluster
```

## The Experiments

Now you have installed and configured properly your local machine, please
enjoy the various experiments you will find in this repository, and don't
hesitate to submit yours for others to benefit from as well.

### Latency of a Spring Boot application hosted in EKS

This experiment attempts to give you the basis for exploring how latency, at
the application level, could impact in your system.

You may simple run it as follows:

```console
$ chaos run experiments/latency-impact.json
```

It connects to the frontend and computes the multiplication of `6 x 7`,
expecting a response in less than a second. Then it enables the chaos monkey
for Spring that is embedded in the backend and make it response with a rather
long delay. In turn, the frontend should now take more than 1 second to respond
failing our experiment.