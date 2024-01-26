# Bootstrap a k8s cluster with crucial services

A solution to run KinD in DinD with following ready to use services:

- MetalLB
- Ingress-Nginx
- ArgoCD
- Gitea

## Requirements

- Tools: `docker` (with privileged access)

## Run

```sh
chmod +x run.sh
./run.sh
```

Access the applications with bellow URLs:

- ArgoCD
  - URL: [ArgoCD](http://localhost/argocd/)
  - User: `admin`
  - Password: `admin`
- Gitea
  - URL: [Gitea](http://localhost/gitea/)
  - User: `gitea`
  - Password: `gitea`

## TODOs

- [x] Use Ansible instead of the bash script
- [x] Connect Argo to Gitea
