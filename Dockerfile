FROM docker:latest

ENV KIND_VERSION=0.20.0

ENV HELM_VERSION=${HELM_VERSION:-3.14.0}

RUN apk update && apk add --no-cache curl git bash bash-completion k9s

RUN curl -Lo /usr/local/bin/kind https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-$(uname)-amd64 && \
    chmod 755 /usr/local/bin/kind && \
    kind completion bash > /usr/share/bash-completion/completions/kind

RUN curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod 755 /usr/local/bin/kubectl && \
    kubectl completion bash > /usr/share/bash-completion/completions/kubectl

RUN curl https://get.helm.sh/helm-v${HELM_VERSION}-linux-386.tar.gz | tar xvz --strip-components 1 -C /usr/local/bin && \
    chmod 755 /usr/local/bin/helm && \
    helm completion bash > /usr/share/bash-completion/completions/helm

RUN curl -Lo /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    chmod 755 /usr/local/bin/argocd && \
    argocd completion bash > /usr/share/bash-completion/completions/argocd

RUN echo "alias ll='ls -alhF --group-directories-first'" > /root/.bashrc

WORKDIR /root
