#!/bin/bash
set -eo pipefail

function init_cluster () {
    local driver=$1
    shift
    
    minikube start --vm-driver=$driver --memory=4096 --cpus=2 \
        --extra-config=apiserver.Authorization.Mode=RBAC
    sleep 2s
}

function update_namespaces () {
    echo "Creating namespaces"
    kubectl apply -f manifests/ns.yaml
    sleep 2s
    
    echo "Creating RBAC Policies"
    kubectl apply -f manifests/rbac.yaml
    sleep 2s
}

function install_helm () {
    echo "Setting up helm"
    helm init --service-account tiller --tiller-namespace=default
    # unfortunately, helm init doesn't actually wait long enough
    while true;
    do
        echo "Waiting for helm to be ready"
        sleep 5s
        if kubectl get pods --selector name=tiller | grep Running; then
            # even now it's a lie, we need to really wait a bit longer
            sleep 10s
            break
        fi
    done
}

function deploy_jeager_opentracing () {
    echo "Deploying Jeager open tracer"
    kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-kubernetes/master/all-in-one/jaeger-all-in-one-template.yml
}

function init_db () {
    echo "Creating database cluster"
    kubectl create -f manifests/postgresql.yaml
    while true;
    do
        echo "Waiting for database operator to be ready"
        sleep 5s
        if kubectl get crd postgresqls.acid.zalan.do; then
            sleep 10s
            break
        fi
    done

    kubectl create -f manifests/database.yaml
    while true;
    do
        echo "Waiting for database to be initialized"
        sleep 5s
        if kubectl logs -l name=postgres-operator | grep "cluster has been created"; then
            break
        fi
    done

    local user="frontend"
    local password=$(kubectl get secret frontend.frontend-db.credentials -o 'jsonpath={.data.password}' | base64 -d)
    local dbname="cosmos"
    local podname=$(kubectl get pod -l spilo-role=master -o jsonpath='{.items[0].metadata.name}')

    kubectl cp apps/frontend/db.sql $podname:/tmp/db.sql
    kubectl exec $podname -- bash -c "PGPASSWORD=$password psql -U $user -d $dbname -a -f /tmp/db.sql"
    sleep 3s
    echo "Database created and populated"
}

function boot () {
    init_db

    echo "Deploying nginx ingress"
    helm install --tiller-namespace=default \
        --name nginx-ing stable/nginx-ingress \
        --set controller.stats.enabled=true \
        --set rbac.create=true

    echo "Uploading TLS certs for frontend application"
    kubectl create secret tls frontend-tls --key apps/frontend/tls.key \
        --cert apps/frontend/tls.crt

    deploy_jeager_opentracing

    echo "Deploying the application"
    kubectl create -f manifests/frontend.yaml
    while true;
    do
        echo "Waiting for the application to be available"
        sleep 3s
        if kubectl get pods --selector name=frontend-app | grep "Running"; then
            break
        fi
    done

    echo
    echo
    echo "Done! The ip of your cluster is $(minikube ip)"
    echo "Please, add that address to your /etc/hosts file so you can resolve it locally:"
    echo
    echo "./expose-domain.sh"
    echo
    echo "Then you can point your browser at: https://app.cosmos.foo/"
    echo
    echo "You can also view traces at: $(minikube service jaeger-query --url)"
    echo
}

function usage() { 
    echo "Usage: $0 [-d|--vm-driver kvm2|virtualbox|none] [-c|--no-create-cluster] [-n|--no-apply-namespaces] [-w|--no-deploy-helm]" 1>&2;
    exit 1;
}

function main () {
    local start_cluster=true
    local apply_ns=true
    local deploy_helm=true
    local vm_driver=virtualbox

    while test -n "$1"; do
        case "$1" in
        -h|--help)
            usage
            ;;
        -d|--vm-driver)
            vm_driver=$2
            shift 2
            ;;
        -c|--no-create-cluster)
            start_cluster=false
            shift 1
            ;;
        -n|--no-apply-namespaces)
            apply_ns=false
            shift 1
            ;;
        -w|--no-deploy-helm)
            deploy_helm=false
            shift 1
            ;;
        *) break
            ;;
        esac
    done
    shift $((OPTIND -1))

    if [[ "$show_usage" == true ]]; then
        usage
    fi

    if [[ "$start_cluster" == true ]]; then
        init_cluster $vm_driver
    fi

    if [[ "$apply_ns" == true ]]; then
        update_namespaces
    fi

    if [[ "$deploy_helm" == true ]]; then
        install_helm
    fi

    boot
}

main "$@" || exit 1
exit 0
