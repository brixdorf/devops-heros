# Troubleshooting Common Kubernetes Issues

Each issue has a `broken.yaml` and a `fixed.yaml`. Each screenshot shows the investigation and then the fix.

## 1. CrashLoopBackOff

**Root cause:** the command reads a config file that does not exist and exits with code 1, so Kubernetes keeps restarting it. **Fix:** corrected the command and recreated the pod. `logs --previous` returned nothing useful here, but plain `logs` showed the error.

```bash
kubectl apply -f 01-crashloopbackoff/broken.yaml
kubectl get pod crash-app -w
kubectl logs crash-app
kubectl logs crash-app --previous
kubectl describe pod crash-app | grep -A3 "Last State"
```

```bash
kubectl replace --force -f 01-crashloopbackoff/fixed.yaml
kubectl wait --for=condition=Ready pod/crash-app --timeout=60s
kubectl get pod crash-app
kubectl logs crash-app
```

Restarts climbing, the error in the logs, then `Running` after the fix.

![](../image4.png)

## 2. ErrImagePull and ImagePullBackOff

**Root cause:** the tag `nginx:1.27-doesnotexist` is not on Docker Hub. **Fix:** applied a real tag, `nginx:1.27`.

```bash
kubectl apply -f 02-imagepullbackoff/broken.yaml
sleep 30
kubectl get pod image-app
kubectl describe pod image-app | tail -8
```

```bash
kubectl apply -f 02-imagepullbackoff/fixed.yaml
kubectl wait --for=condition=Ready pod/image-app --timeout=120s
kubectl get pod image-app
```

`ImagePullBackOff` with `not found` in the events, then `Running`.

![](../image5.png)

## 3. Pending

**Root cause:** the pod requests 64 CPUs and 64Gi of memory, more than the node has. **Fix:** lowered the requests to 100m and 64Mi.

```bash
kubectl apply -f 03-pending/broken.yaml
sleep 5
kubectl get pod big-app -o wide
kubectl describe pod big-app | tail -5
kubectl describe node minikube | grep -A6 "Allocatable"
```

```bash
kubectl replace --force -f 03-pending/fixed.yaml
kubectl wait --for=condition=Ready pod/big-app --timeout=120s
kubectl get pod big-app -o wide
```

`Pending` with `Insufficient cpu`, then scheduled on `minikube`.

![](../image6.png)

## 4. ContainerCreating (stuck)

**Root cause:** the pod mounts a Secret `web-tls` that does not exist. **Fix:** created the Secret, and the kubelet retried on its own.

```bash
kubectl apply -f 04-containercreating/broken.yaml
sleep 15
kubectl get pod mount-app
kubectl describe pod mount-app | tail -5
```

```bash
kubectl apply -f 04-containercreating/fixed.yaml
kubectl get pod mount-app -w
```

`FailedMount` in the events, then `Running` without recreating the pod.

![](../image7.png)

## 5. Service Connectivity

**Root cause:** the Service has `targetPort: 8080`, but nginx listens on 80. **Fix:** set `targetPort` to 80.

```bash
kubectl apply -f 05-service-connectivity/broken.yaml
kubectl rollout status deployment/shop
kubectl get pods -l app=shop
kubectl run tmp --rm -i --quiet --image=busybox:1.36 --restart=Never -- wget -qO- -T 5 http://shop
kubectl get endpoints shop
kubectl describe svc shop | grep -i port
```

```bash
kubectl apply -f 05-service-connectivity/fixed.yaml
kubectl get endpoints shop
kubectl run tmp --rm -i --quiet --image=busybox:1.36 --restart=Never -- wget -qO- -T 5 http://shop
```

`Connection refused` with endpoints on 8080, then the nginx page after the fix.

![](../image8.png)

## 6. DNS

**Root cause:** the client in `default` used the short name `backend`, but the Service is in namespace `team-b`. **Fix:** used the FQDN `backend.team-b.svc.cluster.local`.

```bash
kubectl apply -f 06-dns/backend.yaml
kubectl -n team-b rollout status deployment/backend
kubectl apply -f 06-dns/broken.yaml
kubectl wait --for=jsonpath='{.status.phase}'=Failed pod/dns-client --timeout=60s
kubectl logs dns-client
kubectl get svc -A | grep backend
kubectl run tmp --rm -i --quiet --image=busybox:1.36 --restart=Never -- nslookup backend.team-b.svc.cluster.local
```

```bash
kubectl replace --force -f 06-dns/fixed.yaml
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/dns-client --timeout=60s
kubectl logs dns-client
```

`bad address 'backend'`, then `REACHED BACKEND` with the FQDN.

![](../image9.png)

## 7. Pod Networking

**Root cause:** the server was bound to `127.0.0.1`, so only its own pod could reach it. **Fix:** bound it to `0.0.0.0`.

```bash
kubectl apply -f 07-pod-networking/broken.yaml
kubectl wait --for=condition=Ready pod/api --timeout=180s
kubectl get pod api -o wide
kubectl exec api -- wget -qO- -T 3 http://127.0.0.1:8000 | head -3
kubectl run tmp --rm -i --quiet --image=busybox:1.36 --restart=Never -- wget -qO- -T 5 http://$(kubectl get pod api -o jsonpath='{.status.podIP}'):8000
kubectl exec api -- netstat -tln
```

```bash
kubectl replace --force -f 07-pod-networking/fixed.yaml
kubectl wait --for=condition=Ready pod/api --timeout=180s
kubectl get pod api -o wide
kubectl run tmp --rm -i --quiet --image=busybox:1.36 --restart=Never -- wget -qO- -T 5 http://$(kubectl get pod api -o jsonpath='{.status.podIP}'):8000 | head -3
```

Refused from another pod while listening on 127.0.0.1, then reachable after the fix.

![](../image10.png)

## 8. Configuration Issue

**Root cause:** the pod needs the key `DB_HOST`, but the ConfigMap only had `LOG_LEVEL`. **Fix:** added the key to the ConfigMap.

```bash
kubectl apply -f 08-configuration/broken.yaml
sleep 10
kubectl get pod config-app
kubectl describe pod config-app | tail -5
kubectl get configmap app-settings -o yaml
```

```bash
kubectl apply -f 08-configuration/fixed.yaml
kubectl wait --for=condition=Ready pod/config-app --timeout=180s
kubectl get pod config-app
kubectl logs config-app
```

`CreateContainerConfigError`, then `Running` with both values in the logs.

![](../image11.png)

## Cleanup

```bash
kubectl delete -f 01-crashloopbackoff/fixed.yaml -f 02-imagepullbackoff/fixed.yaml -f 03-pending/fixed.yaml -f 04-containercreating/broken.yaml -f 04-containercreating/fixed.yaml -f 05-service-connectivity/fixed.yaml -f 06-dns/fixed.yaml -f 06-dns/backend.yaml -f 07-pod-networking/fixed.yaml -f 08-configuration/fixed.yaml
```
