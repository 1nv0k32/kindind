#!/bin/env bash

set +e

KINDIND_IMAGE_TAG=kindind:latest
CONTAINER_NAME=kdd

EXEC="docker exec ${CONTAINER_NAME}"

if ! command -v docker &> /dev/null
then
    echo "docker could not be found!"
    exit 1
fi

cleaner() {
    while true; do
        read -p "Do you wish to cleanup the cluster? [y]Yes / [n]No / [e]Yes&Exit " yn
        case $yn in
        [Yy]* )
            ${EXEC} kind delete cluster &> /dev/null
            docker network rm kind &> /dev/null || true
            docker rm --force ${CONTAINER_NAME} &> /dev/null
            break;;
        [Ee]* )
            ${EXEC} kind delete cluster &> /dev/null
            docker network rm kind &> /dev/null || true
            docker rm --force ${CONTAINER_NAME} &> /dev/null
            exit 0
            break;;
        [Nn]* )
            exit 0
            break;;
        esac
    done
}

cleaner

# Run base infra with customized DinD
echo "*** Building and Running base infrastructure ***"
docker build --quiet --tag ${KINDIND_IMAGE_TAG} --file ./Dockerfile . > /dev/null
docker run --detach --privileged --rm --network host --volume "/var/run/docker.sock:/var/run/docker.sock" --volume "./infra:/infra" --volume "./apps:/apps" --name ${CONTAINER_NAME} ${KINDIND_IMAGE_TAG} sleep infinity > /dev/null

sleep 5

echo "*** Creating KinD cluster ***"
${EXEC} kind delete cluster
docker network create --driver bridge --subnet 172.29.0.0/16 --gateway 172.29.0.1 kind > /dev/null
${EXEC} kind create cluster --config /infra/kind_cluster.yaml
${EXEC} kubectl wait --for=condition=ready node --selector=kubernetes.io/os=linux --timeout=90s

echo "*** Installing MetalLB ***"
${EXEC} helm upgrade --install metallb metallb --repo https://metallb.github.io/metallb --namespace metallb-system --create-namespace > /dev/null
${EXEC} kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
${EXEC} kubectl apply -f /infra/metallb_l2.yaml

echo "*** Installing Ingress-Nginx ***"
${EXEC} helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace --values /infra/ingress_nginx_values.yaml > /dev/null
${EXEC} kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s

echo "*** Installing ArgoCD ***"
${EXEC} helm upgrade --install argocd argo-cd --repo https://argoproj.github.io/argo-helm --namespace argocd --create-namespace --values /infra/argocd_values.yaml > /dev/null
${EXEC} kubectl wait --namespace argocd --for=condition=ready pod --selector=app.kubernetes.io/component=application-controller --timeout=90s
${EXEC} kubectl apply -f /infra/argocd_ingress.yaml

echo "*** Installing Gitea ***"
${EXEC} helm upgrade --install gitea gitea --repo https://dl.gitea.com/charts --namespace gitea --create-namespace --values /infra/gitea_values.yaml > /dev/null
${EXEC} kubectl wait --namespace gitea --for=condition=ready pod --selector=app=gitea --timeout=90s
${EXEC} kubectl apply -f /infra/gitea_ingress.yaml

${EXEC} kubectl apply -f /infra/argo/repo.yaml
${EXEC} kubectl apply -f /infra/argo/apps.yaml
${EXEC} kubectl run api-caller --restart=Never --rm --attach --image curlimages/curl -- -sk \
    -X 'POST' 'https://ingress-nginx-controller.ingress-nginx.svc.cluster.local/gitea/api/v1/user/repos' \
    -H 'accept: application/json' \
    -H 'authorization: Basic Z2l0ZWE6Z2l0ZWE=' \
    -H 'Content-Type: application/json' \
    -d '{"default_branch": "main", "name": "apps", "private": false}'

${EXEC} bash -c 'cp -r /apps /tmp/apps && cd /tmp/apps && git config --global user.email "gitea@cluster.local" && git config --global user.name gitea && git config --global http.sslVerify false && git init -b main && git add . && git commit -m "sample app added" && git remote add origin https://172.29.255.200/gitea/gitea/apps.git && git push https://gitea:gitea@172.29.255.200/gitea/gitea/apps.git --all'

${EXEC} kubectl get --all-namespaces all,ingress

docker exec --tty --interactive ${CONTAINER_NAME} k9s
docker exec --tty --interactive ${CONTAINER_NAME} bash

cleaner
