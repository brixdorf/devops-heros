# Helm Homework

Helm is a package manager for Kubernetes. A **chart** is a folder of templated YAML plus a `values.yaml` file of defaults, a **release** is one installed copy of a chart in the cluster, and every install, upgrade or rollback creates a new numbered **revision** of that release.

## Task 1: Helm Commands

### helm create

```bash
helm version
helm create my-first-chart
find my-first-chart -type f | sort
```

I am on Helm v4.3.0. `helm create` generated a working starter chart that deploys nginx: `Chart.yaml` (name and version), `values.yaml` (defaults), and `templates/` (Deployment, Service, Ingress, HTTPRoute, HPA, ServiceAccount, helpers and a test).

![](image1.png)

### helm install, list, status

```bash
helm install web ./my-first-chart
helm list
helm status web
kubectl get pods,svc
```

`install` renders the templates with the values and applies the result as release `web`. `list` shows releases with their revision and status, and `status` shows the state of one release, its resources, and the chart's NOTES. The release was `deployed` at revision 1 and the pod was already `Running`.

![](image2.png)

### helm get

```bash
helm get values web
helm get values web --all | head -20
helm get manifest web | head -30
```

`get values` shows only the values I overrode (`null`, since there are none yet), `--all` shows every value including defaults, and `get manifest` shows the exact YAML Helm sent to the cluster.

![](image3.png)

### helm upgrade, history, rollback

```bash
helm upgrade web ./my-first-chart --set replicaCount=2
helm history web
helm rollback web 1
helm history web
```

`upgrade` changes a running release and creates revision 2. `rollback` goes back to revision 1, but as a new revision 3, so the history is never rewritten.

![](image4.png)

### helm repo, search, uninstall

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm repo list
helm search repo prometheus-community/kube-prometheus-stack
helm search hub redis | head -5
helm uninstall web
helm list
```

`repo add` registers a chart repository, `repo update` refreshes its index, `search repo` searches the added repos (it found kube-prometheus-stack chart version 92.1.0), and `search hub` searches Artifact Hub (the public catalog of charts). `uninstall` removes every resource of the release, and `helm list` was empty afterwards.

![](image5.png)

## Task 2: Helm Rollback Workflow

Install, upgrade, verify, upgrade again, verify, rollback, verify, using the chart from Task 1 and changing the nginx image tag each time.

### Install (revision 1)

```bash
helm install web ./my-first-chart --set image.tag=1.26
kubectl get deploy web-my-first-chart -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Revision 1 is deployed and the Deployment runs `nginx:1.26`.

![](image6.png)

### Upgrade and verify (revision 2)

```bash
helm upgrade web ./my-first-chart --set image.tag=1.27
kubectl rollout status deploy/web-my-first-chart
kubectl get deploy web-my-first-chart -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

The release moved to revision 2, the rollout finished, and the image is now `nginx:1.27`.

![](image7.png)

### Upgrade again and verify (revision 3)

```bash
helm upgrade web ./my-first-chart --set image.tag=1.28
kubectl rollout status deploy/web-my-first-chart
kubectl get deploy web-my-first-chart -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
helm history web
```

Revision 3 runs `nginx:1.28`, and history shows revisions 1 and 2 as `superseded`.

![](image8.png)

### Rollback and verify (revision 4)

```bash
helm rollback web 2
kubectl rollout status deploy/web-my-first-chart
kubectl get deploy web-my-first-chart -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
helm history web
helm uninstall web
```

The image is back to `nginx:1.27`. History shows 4 revisions, with revision 4 described as `Rollback to 2`. Helm keeps the old revisions as Secrets in the namespace, which is what makes rollback possible.

![](image9.png)

## Task 3: Mini Project, Bookshelf Chart

A chart written by hand for a small static site, with its own values files for each release. Install, upgrade, a broken upgrade and a rollback are documented in [03-mini-project/README.md](03-mini-project/README.md).
