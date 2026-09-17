# Homework Tracker — Sessions 9, 10, 11, 12

Covers the four Kubernetes topics you asked about, in correct syllabus order:

| # | Folder | Topic |
|---|---|---|
| 9 | `Session-9 (Kubernetes Fundamentals)` | Kubernetes Fundamentals |
| 10 | `Session-10 (Kubernetes Pods, ReplicaSets & Deployments)` | Pods, ReplicaSets & Deployments |
| 11 | `Session-11 (Kubernetes Networking & Services)` | Networking & Services |
| 12 | `Session-12 (Kubernetes Ingress, ConfigMaps & Secrets)` | Ingress, ConfigMaps & Secrets |

Your class list order is already correct — no reordering needed. This matches your repo's `Session-N (Topic)` convention exactly (same as `Session-8 (Docker Network)`).

Every homework item below is pulled directly from the class transcripts / notes for these four sessions — nothing added that wasn't actually assigned. Where an item was assigned but the *exact* mechanism wasn't fully spelled out live (e.g. targeted rollback), that's flagged. Session 9 is intentionally light — it was an architecture-only, conceptual session with no YAML/hands-on yet, so there's no coding task or screenshot-heavy homework to give it, and inventing one would misrepresent what was actually assigned.

---

## Folder & File Structure to Create

Based on your existing repo pattern (`Session-N (Topic)/TOPIC.md` + `imageN.png` + per-task code subfolders):

```
devops-heros-main/
├── Session-9 (Kubernetes Fundamentals)/
│   └── KUBERNETES_FUNDAMENTALS.md           ← no code subfolder needed, conceptual only
│
├── Session-10 (Kubernetes Pods, ReplicaSets & Deployments)/
│   ├── PODS_REPLICASETS_DEPLOYMENTS.md
│   ├── image1.png, image2.png, ...        ← screenshots, numbered in task order
│   ├── pod-lifecycle/                      ← copy from the class repo, run as-is
│   ├── replicaset/
│   ├── deployment/
│   └── troubleshooting/
│
├── Session-11 (Kubernetes Networking & Services)/
│   ├── NETWORKING_SERVICES.md
│   ├── image1.png, image2.png, ...
│   └── session-11-kubernetes-services/     ← copy from the class repo, run as-is
│
├── Session-12 (Kubernetes Ingress, ConfigMaps & Secrets)/
│   ├── INGRESS_CONFIGMAPS_SECRETS.md
│   ├── image1.png, image2.png, ...
│   └── session-12-ingress-configmaps-secrets/
│
└── (existing Session-2 through Session-8 folders, unchanged)
```

You don't need to rewrite any class YAML — just copy the relevant class-repo subfolders into each session folder (same idea as how your Session-6/7 folders hold `python-app/`, `nginx-app/`, etc. as working subfolders next to the `.md`).

---

## Session 9 — Kubernetes Fundamentals

**Folder:** `Session-9 (Kubernetes Fundamentals)/`
**File:** `KUBERNETES_FUNDAMENTALS.md`

This session covered architecture only (control plane, worker nodes, why Kubernetes exists) — no YAML was written and no Pods were deployed, so there's nothing to screenshot in the usual sense. The homework is setup + reading, confirmed below exactly as assigned.

### Task 1 — Install and verify Minikube

On WSL2 Ubuntu:
```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

minikube start
minikube status
```

**Screenshot:** `minikube status` showing everything (`host`, `kubelet`, `apiserver`, `kubeconfig`) as `Running`/`Configured`. This is genuinely the only screenshot this session needs — it's your proof the environment is ready for every hands-on session after this one.

### Task 2 — Optional: "Hello Minikube" sanity check

Not strictly required, but a reasonable way to confirm the cluster actually works end-to-end before Session 10's real hands-on starts:
```bash
kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
kubectl expose deployment hello-minikube --type=NodePort --port=8080
kubectl get services hello-minikube
minikube service hello-minikube
```

If you do this, a quick screenshot of the browser output is a nice-to-have, not required.

### Task 3 — Reading (no screenshot, just do it before Session 10)

- Official Kubernetes architecture docs: `kubernetes.io/docs/concepts/architecture/` — the instructor was explicit these are the primary source of truth, ahead of any third-party tutorial.
- Optional, if ahead of schedule: the "Deploy an App" module of `kubernetes.io/docs/tutorials/kubernetes-basics/`, as a preview of what Session 10's hands-on looks like.

### Task 4 — Written answer (put directly in the .md, no screenshot needed)

- **Component summary** — one line each for `etcd`, `kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, `kubelet`, `kube-proxy`, and the container runtime (containerd). This is worth writing out yourself rather than copy-pasting, since it's exactly the kind of rapid-fire recap quiz your instructor opens later sessions with.

---

## Session 10 — Pods, ReplicaSets & Deployments

**Folder:** `Session-10 (Kubernetes Pods, ReplicaSets & Deployments)/`
**File:** `PODS_REPLICASETS_DEPLOYMENTS.md`

### Task 1 — Pod Lifecycle (all 12 files)

Run every file in `pod-lifecycle/`, in order, using this loop for each:

```bash
kubectl apply -f pod-lifecycle/01-running.yaml
kubectl get pods -w          # Ctrl+C once you've seen the state settle
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

Files to run, in order: `01-running.yaml`, `02-pending.yaml`, `03-succeeded.yaml`, `04-failed.yaml`, `05-crashloopbackoff.yaml`, `06-imagepullbackoff.yaml`, `07-readiness.yaml`, `08-liveness.yaml`, `09-startup.yaml`, `10-init-container.yaml`, `11-multi-container.yaml`, `12-termination.yaml`.

**Screenshot per file:** the `kubectl get pods` output showing that file's distinctive `STATUS` (Running / Pending / Completed / Error / CrashLoopBackOff / ImagePullBackOff, etc.). You don't need 12 separate screenshots if a few states look visually similar in the same terminal session — group them sensibly, but make sure each of the 6 states you actually studied live (running, pending, succeeded, failed, crashloop, imagepull) has at least one clear screenshot.

### Task 2 — ReplicaSet: deploy, scale up, scale down

```bash
kubectl apply -f replicaset/backend-rs.yaml
kubectl get rs
kubectl get pods
kubectl scale rs/yatri-backend-rs --replicas=5
kubectl get pods                                    # confirm 5
kubectl scale rs/yatri-backend-rs --replicas=0
kubectl get pods                                    # confirm 0
```

**Screenshot:** the 3-pod baseline, the 5-pod scale-up, and the 0-pod scale-down — three separate `kubectl get pods` outputs.

### Task 3 — Deployment: deploy v1, scale, roll out v2

```bash
kubectl apply -f deployment/deployment-v1.yaml
kubectl get all
kubectl scale deployment yatri-backend --replicas=5
kubectl get pods                                    # confirm 5

kubectl apply -f deployment/deployment-v2.yaml
kubectl get pods -w                                 # watch old pods terminate, new ones come up
```

**Screenshot:** `kubectl get all` after v1, the 5-replica scale-up, and the `-w` output mid-rollout (or right after) showing the v2 rollout completing.

### Task 4 — Selector mismatch & broken image (intentional failures)

```bash
kubectl apply -f troubleshooting/selector-mismatch.yaml
# expect: API server validation error (selector doesn't match pod template labels)

kubectl apply -f troubleshooting/broken-image.yaml
kubectl get pods
kubectl describe pod <pod-name>
# expect: ImagePullBackOff, old pods stay healthy (maxSurge/maxUnavailable protecting you)
```

**Screenshot:** the validation error from the first file, and the `ImagePullBackOff` status + relevant `describe` output from the second.

### Task 5 — Rollout history & rollback (V1 → V4, then V4 → V1 directly)

Make 4 small revisions (e.g. change the `version` label each time: `v1`, `v2`, `v3`, `v4`), applying each in sequence:

```bash
# edit deployment-v1.yaml: version label = "v1", apply
kubectl apply -f deployment-v1.yaml
# edit again: version label = "v2", apply
kubectl apply -f deployment-v1.yaml
# repeat for v3, v4
kubectl rollout history deployment/yatri-backend
```

Now roll back **directly from V4 to V1** — not by calling `rollout undo` four times (that just toggles you between the two most recent revisions, it won't land you on V1 reliably):

```bash
kubectl rollout undo deployment/yatri-backend --to-revision=1
kubectl get pods -l app=yatri-backend --show-labels    # confirm version label is back to v1
```

*(Note: the `--to-revision` flag wasn't spelled out explicitly in class — the instructor said "a slightly different command" without finishing the name. This is the standard Kubernetes mechanism for jumping to a specific revision rather than stepping back one at a time, which is what the assignment actually needs.)*

**Screenshot:** `rollout history` showing 4 entries, and the final `--show-labels` output confirming you landed back on v1.

### Task 6 — Deployment strategies: Recreate, Blue-Green, Canary

Explicitly flagged as outside the official syllabus but assigned anyway for interview prep. Each lives in its own repo folder with a README to follow:

```bash
cd 04-recreate && kubectl apply -f deployment-v1.yaml && kubectl apply -f service.yaml
# observe brief downtime during v1 -> v2, unlike rolling update
kubectl apply -f deployment-v2.yaml

cd ../02-blue-green && kubectl apply -f deployment-blue.yaml && kubectl apply -f service-blue.yaml
kubectl apply -f deployment-green.yaml
# flip traffic: apply service-green.yaml, confirm instant cutover

cd ../03-canary && kubectl apply -f deployment-stable.yaml && kubectl apply -f service.yaml
kubectl apply -f deployment-canary.yaml
# scale canary up/down to change traffic ratio, observe via repeated curl
```

**Screenshot:** one clear "before vs after" pair per strategy (e.g. the curl output showing version text changing) is enough — you don't need to screenshot every intermediate step.

### Task 7 — Written answers (put directly in the .md, no screenshot needed)

- **StatefulSet vs. DaemonSet vs. Deployment** — a short paragraph each on what they're for and how Pod naming/lifecycle differs. (StatefulSet wasn't taught yet as of this session — a correct one-paragraph answer based on the DaemonSet/Deployment contrast is enough for now; you'll sharpen the StatefulSet part after Session 11.)
- **ReplicaSet vs. Deployment** — specifically: why Deployment exists on top of ReplicaSet (version history + one-command rollback vs. ReplicaSet's scale-only behavior).

---

## Session 11 — Networking & Services

**Folder:** `Session-11 (Kubernetes Networking & Services)/`
**File:** `NETWORKING_SERVICES.md`

### Task 1 — All 5 Service types

Each has its own subfolder with a working `app-deployment.yaml` + `service.yaml`:

```bash
cd 01-clusterip
kubectl apply -f app-deployment.yaml
kubectl apply -f service.yaml
kubectl get svc web-service-clusterip
kubectl apply -f client-pod.yaml
kubectl exec -it curl-client -- curl -s http://web-service-clusterip:8080
```

Repeat the same shape for `02-nodeport`, `03-loadbalancer`, `04-externalname`, `05-headless` — each folder's README has the exact commands if anything differs (NodePort and LoadBalancer use `minikube service <name> --url` instead of the curl-client trick).

**One combined screenshot, per your own instructor's explicit ask:**
```bash
kubectl get svc -o wide
```
run once after all 5 are deployed together — this single output should show all 5 types (ClusterIP, NodePort, LoadBalancer, ExternalName, Headless) side by side with their distinct `CLUSTER-IP`/`TYPE` columns. This was specifically requested as *the* screenshot to submit for this task.

### Task 2 — StatefulSet naming behavior

```bash
kubectl apply -f 05-headless/app-statefulset.yaml
kubectl get pods -l app=web-headless          # confirm web-stateful-0, -1, -2
kubectl delete pod web-stateful-0
kubectl get pods -l app=web-headless          # confirm the replacement is ALSO named web-stateful-0
```

**Screenshot:** before-delete and after-delete `get pods` output, side by side, showing the name `web-stateful-0` persisted.

### Task 3 — Selector mismatch on a Service (endpoint troubleshooting)

```bash
kubectl apply -f troubleshooting/empty-endpoints.yaml
kubectl get endpoints broken-backend-service
# expect: <none>
```

**Screenshot:** the `<none>` endpoints output — this is the diagnostic signal you're meant to recognize.

### Task 4 — FQDN / CoreDNS hands-on

```bash
kubectl apply -f dns-test/curl-test-pod.yaml
kubectl exec -it curl-test-pod -- sh
# inside the shell:
curl http://web-service-clusterip:8080                                  # short name, same namespace
curl http://web-service-clusterip.default                               # service + namespace
curl http://web-service-clusterip.default.svc.cluster.local             # full FQDN
cat /etc/resolv.conf                                                    # see the nameserver + search suffixes
exit
```

**Screenshot:** the three curl attempts succeeding, plus the `/etc/resolv.conf` contents.

### Task 5 — Written answers

- **What is FQDN? What is CoreDNS? How does Kubernetes DNS resolve automatically?** — a few sentences is enough; base it on what `/etc/resolv.conf` actually showed you in Task 4, that's the most convincing kind of answer here.
- Re-read the class repo's `service.md` and `fqdn.md` reference files before writing this — they're the fuller version of everything demoed live.

---

## Session 12 — Ingress, ConfigMaps & Secrets

**Folder:** `Session-12 (Kubernetes Ingress, ConfigMaps & Secrets)/`
**File:** `INGRESS_CONFIGMAPS_SECRETS.md`

### Task 1 — ConfigMap: deploy and verify

```bash
kubectl apply -f 01-configmap/app-config.yaml
kubectl get configmap yatri-app-config
kubectl get configmap yatri-app-config -o yaml
```

**Screenshot:** the `-o yaml` output showing all 5 keys (`ENVIRONMENT`, `LOG_LEVEL`, `PORT`, `DEFAULT_CURRENCY`, `MAX_BOOKING_DAYS`).

### Task 2 — Secret: encode correctly, deploy, decode

```bash
echo -n "yourusername" | base64          # note: -n matters, plain echo adds a trailing newline that breaks the value
kubectl apply -f 02-secret/db-secret.yaml
kubectl get secrets
kubectl get secret yatri-db-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 --decode
```

**Screenshot:** the `kubectl get secrets` output, and the decoded password confirming it round-trips correctly.

### Task 3 — Full demo: ConfigMap + Secret + Ingress, end to end

```bash
cd 04-full-demo
bash run-demo.sh
# this enables the Minikube ingress addon, applies configmap/secret/frontend/backend/ingress,
# and adds yatri.local to /etc/hosts automatically
```

Then verify both routes:
```bash
curl http://yatri.local              # frontend
curl http://yatri.local/api/         # backend — should show injected ConfigMap + Secret values in the response body
```

**This is the main screenshot task for this session, explicitly assigned by name:** get both `curl http://yatri.local` and `curl http://yatri.local/api/` working and screenshot both outputs. If `curl` doesn't resolve `yatri.local` even after `/etc/hosts` is updated, that's a known environment quirk (seen on some non-Linux setups in class) — try opening `http://yatri.local` directly in a browser instead, or confirm the `/etc/hosts` entry with `cat /etc/hosts | grep yatri`.

Also grab:
```bash
kubectl exec -it deploy/yatri-backend -- env | grep -E 'ENVIRONMENT|LOG_LEVEL|POSTGRES'
```
**Screenshot** this too — it's the clearest proof the ConfigMap/Secret values actually landed inside the running container.

### Task 4 — Written answers

- **Ingress vs. Ingress Controller** — an Ingress is just a YAML routing rule; an Ingress Controller (e.g. NGINX) is the actual running software that reads and enforces those rules. Without a controller installed (`minikube addons enable ingress`), an Ingress resource does nothing.
- **Ways to store secrets in real practice** — a short list is enough: manual base64 (what you did in Task 2, and its limits), HashiCorp Vault, Azure Key Vault, AWS Secrets Manager, and Azure DevOps variable libraries (the free/common approach per the instructor). Mention that base64 is encoding, not encryption.
- **Why does a database need StatefulSet, not Deployment?** — persistent storage and stable identity; a database's data/identity needs to survive Pod recreation in an addressable way, which Deployment's randomly-named, fully-interchangeable Pods don't provide.

---

## Also Still Owed From Session 10/11 (re-assigned mid-Session 12, time-boxed)

Your instructor explicitly re-asked for this at the *start* of the Ingress/ConfigMaps/Secrets session, since it was still missing from most repos — worth doing first if you haven't:

- Push a `README.md` (or fold into `NETWORKING_SERVICES.md`) with `kubectl get svc -o wide` screenshots for **all 5 service types** from Session 11, if Task 1 there isn't already done.

---

## Submitting

1. Commit each session's folder + `.md` + images to your `devops-heros` repo.
2. Push to GitHub.
3. Copy the repo's (or, if requested, the specific folder's) GitHub URL.
4. Paste that URL into the Google Form submission link your instructor shared for attendance/homework tracking. (I don't have that form link myself — grab it from your class chat/LMS; it's the same one used for prior sessions' submissions.)

---

## Estimated Timeline

Assuming you already have Minikube running and the class repo cloned locally:

| Session | Hands-on time | Write-up + screenshots | Total |
|---|---|---|---|
| 9 — Kubernetes Fundamentals | ~15–20 min (Minikube install + start) | ~10 min | **~25–30 min** |
| 10 — Pods/ReplicaSets/Deployments | ~2–2.5 hrs (12 lifecycle files + RS + Deployment + rollback + 3 strategies) | ~45 min | **~3–3.25 hrs** |
| 11 — Networking & Services | ~1.5 hrs (5 service types + StatefulSet + DNS) | ~30 min | **~2 hrs** |
| 12 — Ingress/ConfigMaps/Secrets | ~1–1.5 hrs (mostly `run-demo.sh` + verification) | ~30 min | **~1.5–2 hrs** |
| **Total** | | | **~7–7.75 hrs** |

Session 9 is quick — it's really just "make sure Minikube works," which you likely need before any of the other three sessions run properly anyway, so do it first regardless of order. Session 10 is by far the heaviest (12 separate lifecycle files alone). If you're short on time, the single highest-priority items are: Minikube verification for Session 9, Task 1+3 for Session 10, Task 1 for Session 11, and Task 3 for Session 12 — those were each individually and explicitly called out by name as required deliverables.