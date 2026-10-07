# Kubernetes Troubleshooting Homework

## Task 1: Troubleshooting Commands

Deployed a small nginx app with 2 replicas and a service, then used it to practice every core troubleshooting command.

```bash
kubectl apply -f 01-commands/demo-app.yaml
kubectl rollout status deployment/demo-web
kubectl get pods
kubectl get pods -o wide
kubectl describe pod demo-web-b9764cd7c-7slwq
```

`get` gives the quick status of every pod, `-o wide` adds the pod IP and the node it runs on, and `describe` shows the full spec plus the Events section at the bottom, which is usually where the actual error shows up. Here both pods were `Running` on the `minikube` node, and the Events were the normal Scheduled, Pulled, Created, Started.

![](image1.png)

```bash
kubectl logs deploy/demo-web
kubectl exec deploy/demo-web -- sh -c "nginx -v; ls /usr/share/nginx/html"
kubectl events --for deployment/demo-web
```

`logs` prints what the container wrote to stdout and stderr (here the nginx startup lines), `exec` runs a command inside a running container (nginx 1.27.5, with `50x.html` and `index.html` in the web root), and `events` lists what the cluster did to the object in time order. For the deployment that was a single event, scaling the replica set from 0 to 2.

![](image2.png)

```bash
kubectl explain pod.spec.containers.livenessProbe
kubectl top nodes
kubectl top pods
```

`explain` is built-in documentation for any field of any resource, so there is no need to guess YAML field names. `top` shows live CPU and memory usage, and needs the metrics-server addon. The node was at 176m CPU and 818Mi memory, and the two idle nginx pods used 7m and 3m of CPU.

![](image3.png)

## Task 2: Troubleshooting Common Issues

Recreated 8 common failures on purpose, each with a broken and a fixed manifest, and went through identify, investigate, root cause, fix, and verify for every one. The full write-up for each issue is in [02-issues/README.md](02-issues/README.md).

| Issue | Root cause | Fix |
|---|---|---|
| CrashLoopBackOff | Container command exits with code 1 | Corrected the command |
| ErrImagePull / ImagePullBackOff | Image tag does not exist | Used a real tag, nginx:1.27 |
| Pending | Requested 64 CPUs and 64Gi memory, more than the node has | Lowered the requests |
| ContainerCreating | Mounted Secret web-tls did not exist | Created the Secret |
| Service connectivity | Service targetPort 8080, nginx listens on 80 | Set targetPort to 80 |
| DNS | Short name used across namespaces | Used the FQDN backend.team-b.svc.cluster.local |
| Pod networking | App bound to 127.0.0.1 only | Bound to 0.0.0.0 |
| Configuration | ConfigMap key DB_HOST missing (CreateContainerConfigError) | Added the key |

## Task 3: Mini Project, Broken Bookstore

Deployed a bookstore app (frontend plus books-api backend) that had three bugs planted in it at once, then found and fixed all three. Full write-up with problem statement, investigation, root cause, solution and before/after output is in [03-mini-project/README.md](03-mini-project/README.md).

## Cleanup

```bash
kubectl delete -f 01-commands/demo-app.yaml
```

The cleanup commands for Task 2 and Task 3 are at the end of their own READMEs.
