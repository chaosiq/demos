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

function init_db () {
    local user="stolon"
    local passwd="password1"
    local dbname="cosmos"

    echo "Creating the application database"
    while true;
    do
        echo "Waiting for database to be available"
        sleep 10s
        if kubectl exec stolon-keeper-0 ps aux | grep "streaming"; then
            break
        fi
    done

    local stolon_port=$(kubectl get svc -o jsonpath='{.spec.ports[0].nodePort}' stolon-proxy-service)

    PGPASSWORD=$passwd psql postgres -h $(minikube ip) -p ${stolon_port} \
        -U $user -w -c "CREATE DATABASE $dbname WITH ENCODING 'UTF8'"

    PGPASSWORD=$passwd psql -h $(minikube ip) -p ${stolon_port} \
        -U $user -d $dbname -w <<EOF
CREATE SEQUENCE star_id_seq START 10000;

CREATE TABLE public.star
(
  id integer NOT NULL DEFAULT nextval('star_id_seq'::regclass),
  name character varying(120) NOT NULL,
  discovered_by character varying(120) NOT NULL,
  description character varying NOT NULL,
  link character varying NOT NULL,
  img_link character varying,
  CONSTRAINT star_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.star
  OWNER TO $user;

CREATE INDEX star_name_idx
  ON public.star
  USING btree
  (name COLLATE pg_catalog."default");
EOF

    echo "Loading some data into the database"
    PGPASSWORD=$passwd psql -h $(minikube ip) -p ${stolon_port} \
        -U $user -d $dbname -w <<EOF
INSERT INTO star (name, discovered_by, description, link, img_link)
VALUES ('Antares', 'Unknown', 'Antares A is a red supergiant star with a stellar classification of M1.5Iab-Ib, and is indicated to be a spectral standard for that class.', 'https://en.wikipedia.org/wiki/Antares', 'https://upload.wikimedia.org/wikipedia/commons/1/15/Redgiants.svg');

INSERT INTO star (name, discovered_by, description, link, img_link)
VALUES ('KY Cygni', 'Unknown', 'KY Cygni is a red supergiant of spectral class M3.5Ia located in the constellation Cygnus. It is one of the largest stars known.', 'https://en.wikipedia.org/wiki/KY_Cygni', 'https://upload.wikimedia.org/wikipedia/commons/0/07/Sadr_Region_rgb.jpg');

EOF
}

function boot () {
    echo "Deploying storage"
    helm repo add rook-master https://charts.rook.io/master 
    # took doesn't seem to match its docker images with what helm suggests
    # local rook_latest=$(helm search rook | awk '{if (NR!=1) print $2}')
    helm install --name rook --tiller-namespace=default rook-master/rook \
        --version v0.6.0-129.g9305bd8 --set image.tag=master
    while true;
    do
        echo "Waiting for storage to be ready"
        sleep 5s
        if kubectl get pods --selector app=rook-agent | grep Running; then
            kubectl apply -f manifests/storage-post-config.yaml
            sleep 10s
            break
        fi
    done
    
    echo "Deploying the K/V store (this may take a couple of minutes)"
    helm install --name etcd incubator/etcd --set StorageClass=rook-block \
        --set Storage=128Mi --tiller-namespace=default
    while true;
    do
        echo "Waiting for K/V store to be ready"
        sleep 15s
        if kubectl get pods --selector component=etcd-etcd | grep Running; then
            break
        fi
    done
    
    echo "Deploying the relational database"
    kubectl apply -f manifests/postgresql.yaml
    while true;
    do
        echo "Waiting for database cluster to be ready"
        sleep 5s
        if kubectl get pods --selector app=stolon-keeper | grep Running; then
            sleep 3s
            # creating a cluster of postgresql instances
            local stolon_cluster_config='{"additionalWalSenders": null, "initMode": "new", "pgParameters": {"datestyle": "iso, mdy", "default_text_search_config": "pg_catalog.english", "dynamic_shared_memory_type": "posix", "lc_messages": "en_US.utf8", "lc_monetary": "en_US.utf8", "lc_numeric": "en_US.utf8", "lc_time": "en_US.utf8", "log_timezone": "UTC", "max_connections": "100", "shared_buffers": "128MB", "timezone": "UTC"}, "pgHBA": null}'
            kubectl exec -it stolon-keeper-0 -- /usr/local/bin/stolonctl --cluster-name=kube-stolon --store-backend=etcd --store-endpoints=http://etcd-etcd:2379 init --yes "${stolon_cluster_config}"
            break
        fi
    done

    echo "Deploying nginx ingress"
    helm install --tiller-namespace=default \
        --name nginx-ing stable/nginx-ingress \
        --set controller.stats.enabled=true \
        --set rbac.create=true

    echo "Uploading TLS certs for frontend application"
    kubectl create secret tls frontend-tls --key apps/frontend/tls.key \
        --cert apps/frontend/tls.crt

    init_db

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
    echo 'echo "$(minikube ip) app.cosmos.foo" | sudo tee -a /etc/hosts'
    echo
    echo "Then you can point your browser at: https://app.cosmos.foo/"
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
