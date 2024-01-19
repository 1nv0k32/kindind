# Bootstrap a k8s cluster with crucial services

A solution to run KinD in DinD with following ready to use services:

- MetalLB
- Ingress-Nginx
- ArgoCD
- Gitea

## Requirements

- Tools: `docker` (with privileged access)
- Empty CIDR: `172.29.0.0/16`

## Run

```sh
chmod +x run.sh
./run.sh
```

Access the applications with bellow URLs:

- ArgoCD
  - URL: [ArgoCD](https://172.29.255.200/argocd/)
  - User: `admin`
  - Password: `argo`
- Gitea
  - URL: [Gitea](https://172.29.255.200/gitea/)
  - User: `gitea`
  - Password: `gitea`

## TODOs

- [ ] Use Ansible instead of the bash script
- [ ] Automate CIDR choice
- [ ] Connect Argo to Gitea
