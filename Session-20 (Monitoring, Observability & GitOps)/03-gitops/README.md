# GitOps

## What is GitOps

A way of running applications where a Git repository describes how the system should look, and an automated tool keeps the cluster matching it. To change the cluster, you change Git.

## Git as the source of truth

Git is the one place everyone agrees is correct. That gives history, review through pull requests, rollback with `git revert`, and an easy rebuild of a lost cluster.

## Declarative configuration

You describe what you want, not the steps to get there. The commands below are the imperative way, and a YAML file that says `replicas: 3` is the declarative way.

```bash
kubectl create deployment web --image=nginx:1.27
kubectl scale deployment web --replicas=3
```

## Continuous reconciliation

The tool keeps comparing Git with the cluster and applies the Git version whenever they differ. A manual change, called drift, gets reverted.

## GitOps workflow: push vs pull

### Push model

The CI pipeline runs `kubectl apply` against the cluster. It is simple, but CI needs cluster credentials and nothing fixes manual changes.

### Pull model

An agent inside the cluster pulls from Git and applies it. No credentials leave the cluster, and drift is fixed continuously.

## Kubernetes + GitOps: Argo CD and Flux

Argo CD and Flux are the two main tools. Both are pull based and run as controllers inside the cluster.

### Argo CD

An `Application` object points a Git path at a namespace. It has a web UI that shows Synced or OutOfSync, and it can self-heal and prune.

### Flux

A set of small controllers configured with objects like `GitRepository` and `Kustomization`. It has no built-in UI and is driven by YAML and the `flux` CLI.

### Which one?

Argo CD suits teams that want a dashboard, and Flux suits teams that want everything as lightweight YAML.

## Hands-on Demo: Argo CD on Minikube

`application.yaml` tells Argo CD to keep the `gitops-demo` namespace identical to `03-gitops/manifests/` on `main`, with automated sync, `prune` and `selfHeal`.

### Install Argo CD

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml | tail -5
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=420s
kubectl get pods -n argocd
```

All 7 Argo CD pods running.

![](../image7.png)

### Create the Application

```bash
kubectl apply -f application.yaml
kubectl wait --for=jsonpath='{.status.health.status}'=Healthy application/gitops-web -n argocd --timeout=240s
kubectl get applications -n argocd
kubectl get all -n gitops-demo
```

The application is `Synced` and `Healthy`, with 2 pods deployed.

![](../image8.png)

### Argo CD UI

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

The Argo CD UI with the app tree: Service, Deployment, ReplicaSet and Pods.

![](../image9.png)

### Change Git, watch the cluster follow

```bash
sed -i 's/replicas: 2/replicas: 3/' "Session-20 (Monitoring, Observability & GitOps)/03-gitops/manifests/deployment.yaml"
git add "Session-20 (Monitoring, Observability & GitOps)/03-gitops/manifests/deployment.yaml"
git commit -m "gitops demo: scale to 3"
git.exe push origin main
date +%T
kubectl get pods -n gitops-demo -w
date +%T
kubectl get applications -n argocd
```

After pushing `replicas: 3`, a third pod appeared about 2 minutes later without any `kubectl apply`.

![](../image10.png)

### Self-healing

```bash
kubectl scale deployment gitops-web -n gitops-demo --replicas=1
kubectl get pods -n gitops-demo -w
kubectl get deployment gitops-web -n gitops-demo
kubectl get applications -n argocd
```

A manual scale to 1 was reverted to 3 within seconds.

![](../image11.png)

### Cleanup

```bash
kubectl delete -f application.yaml
kubectl delete namespace gitops-demo argocd
```
