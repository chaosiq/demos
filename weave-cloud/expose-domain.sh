#!/bin/bash
set -eo pipefail


function main () {
    local domain="app.cosmos.foo"
    local addr=$(minikube ip)

    if grep -q "$domain" /etc/hosts; then
        sudo sed -i "s/[0-9\.]* app.cosmos.foo/${addr} app.cosmos.foo/" /etc/hosts
    else
        echo "${addr} app.cosmos.foo" | sudo tee -a /etc/hosts 1> /dev/null
    fi

    echo "You can now view the application at https://${domain}/"
}

main
exit 0