# Mini Project: Self-Healing Website with Persistent Storage

This combines all three topics of the session in one small app:
- **Storage:** the website files live on a PVC (`pvc.yaml`) that Minikube's `standard` StorageClass provisions automatically.
- **Probes:** nginx has a startup, readiness and liveness probe.
- **HPA:** `hpa.yaml` scales the Deployment between 1 and 4 pods at 50% CPU.

An init container (a container that runs to completion before the main one starts) writes `index.html` and `healthz.html` onto the volume, but only if they are not there already.

## The three probes

| Probe | Checks | What happens on failure |
|---|---|---|
| startupProbe | `GET /healthz.html` every 2s, up to 15 tries | Other probes wait until it passes. If it never passes, the container is restarted |
| readinessProbe | `GET /` every 5s | Pod is removed from the Service endpoints, so it gets no traffic, but it is not restarted |
| livenessProbe | `GET /healthz.html` every 5s, 3 failures allowed | Container is killed and restarted |

## Deploy

```bash
kubectl apply -f .
kubectl rollout status deployment/site
kubectl get pvc,pv
kubectl get pods -l app=site
kubectl get hpa site
curl -sS -m 5 http://$(minikube ip):30013
minikube ssh -- curl -s http://localhost:30013
```

The PVC went to `Bound` and a PV appeared for it automatically. The pod showed `1/1 Running`. The curl to the node IP timed out, because with the docker driver on WSL the node IP is not reachable from my shell, so I curled the NodePort from inside the node instead and got the page back.

![](../image12.png)

## Prove the data persists

```bash
kubectl exec deploy/site -- sh -c 'echo "<h1>Edited live, stored on the PVC</h1>" > /usr/share/nginx/html/index.html'
kubectl delete pod -l app=site
kubectl rollout status deployment/site
kubectl get pods -l app=site
kubectl exec deploy/site -- cat /usr/share/nginx/html/index.html
```

The replacement pod (new name, 0 restarts) still had the edited page. The init container saw that `index.html` already existed and left it alone.

![](../image13.png)

## Prove liveness self-healing

```bash
kubectl exec deploy/site -- rm /usr/share/nginx/html/healthz.html
kubectl get pods -l app=site -w
kubectl describe pod -l app=site | grep -E "Liveness|Unhealthy|Killing"
kubectl exec deploy/site -- sh -c 'echo ok > /usr/share/nginx/html/healthz.html'
sleep 10
kubectl get pods -l app=site
```

After 3 failed liveness checks (about 15 seconds) the kubelet killed the container and RESTARTS went from 0 to 1. Only the container restarts, not the pod, so the init container does not run again and the health file stays missing. Because of that the startup probe then failed too, and about 30 seconds later the container was restarted a second time. I recreated the health file by hand to stop the loop, and the pod went back to `1/1 Running` with 2 restarts.

![](../image14.png)

That was a useful lesson in itself. A liveness probe only helps when restarting the container actually fixes the problem. Here the broken state was on the persistent volume, so restarting alone could not fix it.

## Scaling

```bash
kubectl run site-load --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://site > /dev/null; done"
kubectl get hpa site -w
kubectl get pods -l app=site
kubectl delete pod site-load
```

The CPU request is only 50m, so the load pushed utilization to 112% and HPA scaled from 1 to 3 pods. With three pods sharing the requests, CPU settled at around 50%, right on the target, so it stopped there and never needed the fourth pod.

![](../image15.png)
