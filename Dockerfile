FROM docker:dind

RUN apk update && apk add --no-cache bash ansible

RUN ansible-galaxy collection install kubernetes.core community.docker

RUN echo "alias ll='ls -alhF --group-directories-first'" > /root/.bashrc
RUN echo "alias k=kubectl" >> /root/.bashrc
RUN echo "complete -o default -F __start_kubectl k" >> /root/.bashrc

WORKDIR /root
