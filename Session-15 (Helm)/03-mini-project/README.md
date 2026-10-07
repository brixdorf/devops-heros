# Mini Project: Bookshelf Helm Chart

A Helm chart written by hand (not from `helm create`) for a small static website. nginx serves an HTML page that is generated from values, so every release visibly shows its own version, message and colour.

## Chart structure

```text
bookshelf/
├── Chart.yaml              chart name, chart version, app version
├── values.yaml             defaults (release v1)
├── values-v2.yaml          overrides for release v2
├── values-v3-broken.yaml   overrides for release v3, with a bad image tag
└── templates/
    ├── _helpers.tpl        shared name and label snippets
    ├── configmap.yaml      index.html built from .Values.site
    ├── deployment.yaml     nginx mounting the ConfigMap
    ├── service.yaml        NodePort 30015
    └── NOTES.txt           printed after install
```

Two template details worth noting:
- `deployment.yaml` has a `checksum/html` annotation, a hash of the rendered ConfigMap. A ConfigMap change alone does not restart pods, but a changed annotation does, so a new page always triggers a rolling update.
- `values-v2.yaml` only contains the keys that change. Helm merges it on top of `values.yaml`.

## Lint and render

```bash
helm lint ./bookshelf
helm template shop ./bookshelf | head -40
```

`lint` checks the chart for errors (0 failed, only an INFO that an icon is recommended), and `template` renders the YAML locally without touching the cluster. The rendered ConfigMap already has `Bookshelf v1` in the HTML.

![](../image10.png)

## Install (revision 1) and upgrade (revision 2)

```bash
helm install shop ./bookshelf
kubectl rollout status deploy/shop-bookshelf
sleep 5
kubectl get pods -l app.kubernetes.io/instance=shop
minikube ssh -- curl -s http://localhost:30015 | grep h1
helm upgrade shop ./bookshelf -f bookshelf/values-v2.yaml
kubectl rollout status deploy/shop-bookshelf
sleep 5
kubectl get pods -l app.kubernetes.io/instance=shop
minikube ssh -- curl -s http://localhost:30015 | grep h1
```

v1 runs 2 pods and the page says `Bookshelf v1`. After the upgrade there are 3 pods and the page says `Bookshelf v2`. The chart's NOTES suggest `minikube service shop-bookshelf --url`, but with the docker driver on WSL that command keeps a tunnel open in the terminal, so I curled the NodePort from inside the node instead. The short `sleep` is there because my first try curled right after the rollout and the NodePort was not answering yet.

![](../image11.png)

## Broken upgrade (revision 3)

```bash
helm upgrade shop ./bookshelf -f bookshelf/values-v3-broken.yaml
sleep 20
kubectl get pods -l app.kubernetes.io/instance=shop
helm history shop
minikube ssh -- curl -s http://localhost:30015 | grep h1
```

The new pod is stuck in `ImagePullBackOff` because `nginx:1.27-alpine-typo` does not exist. Two old pods are still `Running` and the page still says `Bookshelf v2`, because a rolling update does not remove old pods until new ones are ready. (There are 2 old pods and not 3 because the v3 file does not set `replicaCount`, so it fell back to the default of 2.) Helm still records revision 3 as `deployed`, because without `--wait` it only checks that the YAML was accepted, not that pods became healthy.

![](../image12.png)

## Rollback (revision 4)

```bash
helm rollback shop 2
kubectl rollout status deploy/shop-bookshelf
sleep 5
kubectl get pods -l app.kubernetes.io/instance=shop
helm history shop
minikube ssh -- curl -s http://localhost:30015 | grep h1
```

Back to 3 healthy pods and `Bookshelf v2`. History shows revision 4 as `Rollback to 2`.

![](../image13.png)

## Cleanup

```bash
helm uninstall shop
```
