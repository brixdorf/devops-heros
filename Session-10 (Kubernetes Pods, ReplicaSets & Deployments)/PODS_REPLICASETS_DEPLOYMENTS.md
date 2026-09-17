# Kubernetes Pods, ReplicaSets & Deployments Homework

## Task 1: Pod Lifecycle

Ran all 12 lifecycle example files, one at a time, checking status with kubectl get pods, kubectl describe pod, and kubectl logs for each.

```bash
kubectl apply -f pod-lifecycle/01-running.yaml
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

Repeated the same pattern for all 12 files: running, pending, succeeded, failed, crashloopbackoff, imagepullbackoff, readiness, liveness, startup, init-container, multi-container, termination.

![](image1.png)
![](image2.png)
![](image3.png)
![](image4.png)
![](image5.png)
![](image6.png)
![](image7.png)
![](image8.png)
![](image9.png)
![](image10.png)
![](image11.png)
![](image12.png)

## Task 2: ReplicaSet, Deploy, Scale Up, Scale Down

```bash
kubectl apply -f replicaset/backend-rs.yaml
kubectl get rs
kubectl get pods
kubectl scale rs/yatri-backend-rs --replicas=5
kubectl get pods
kubectl scale rs/yatri-backend-rs --replicas=0
kubectl get pods
```

![](image13.png)
![](image14.png)
![](image15.png)

## Task 3: Deployment, Deploy v1, Scale, Roll Out v2

```bash
kubectl apply -f deployment/deployment-v1.yaml
kubectl get all
kubectl scale deployment yatri-backend --replicas=5
kubectl get pods

kubectl apply -f deployment/deployment-v2.yaml
kubectl get pods -w
```

![](image16.png)
![](image17.png)
![](image18.png)

## Task 4: Selector Mismatch and Broken Image

```bash
kubectl apply -f troubleshooting/selector-mismatch.yaml
```

Got a validation error since the selector does not match the pod template labels.

![](image19.png)

```bash
kubectl apply -f troubleshooting/broken-image.yaml
kubectl get pods
kubectl describe pod <pod-name>
```

Pod went into ImagePullBackOff since the image does not exist. Old pods stayed healthy the whole time because of maxSurge and maxUnavailable protecting the rollout.

![](image20.png)

## Task 5: Rollout History and Rollback, V1 to V4, Then V4 Straight Back to V1

Made 4 small revisions by changing the version label each time and applying after each change.

```bash
kubectl apply -f deployment-v1.yaml
kubectl apply -f deployment-v1.yaml
kubectl apply -f deployment-v1.yaml
kubectl apply -f deployment-v1.yaml
kubectl rollout history deployment/yatri-backend
```

![](image21.png)

Rolled back directly from V4 to V1 using a targeted rollback instead of calling rollout undo four times, since undo only toggles between the two most recent revisions and would not reliably land on V1.

```bash
kubectl rollout undo deployment/yatri-backend --to-revision=1
kubectl get pods -l app=yatri-backend --show-labels
```

![](image22.png)

## Task 6: Deployment Strategies, Recreate, Blue Green, Canary

```bash
cd 04-recreate
kubectl apply -f deployment-v1.yaml
kubectl apply -f service.yaml
kubectl apply -f deployment-v2.yaml
```

![](image23.png)

```bash
cd ../02-blue-green
kubectl apply -f deployment-blue.yaml
kubectl apply -f service-blue.yaml
kubectl apply -f deployment-green.yaml
kubectl apply -f service-green.yaml
```

![](image24.png)

```bash
cd ../03-canary
kubectl apply -f deployment-stable.yaml
kubectl apply -f service.yaml
kubectl apply -f deployment-canary.yaml
```

![](image25.png)

## Task 7: Written Answers

**StatefulSet vs DaemonSet vs Deployment**

A Deployment manages a set number of interchangeable pods, any pod can be replaced by any other pod, names are randomly suffixed and change on every recreation. It is the right fit for stateless apps like a web frontend or an API server where it does not matter which specific pod handles a request.

A DaemonSet ensures exactly one copy of a pod runs on every node in the cluster, including any new node added later. There is no replicas field since the count is implied by the number of nodes. It is used for node level agents like logging or monitoring tools that need to run everywhere.

A StatefulSet is for workloads where pod identity matters. Each pod gets a stable, predictable name like app-0, app-1, app-2, and if a pod is deleted its replacement keeps the same name rather than getting a new random one. It is paired with a headless service so each pod also gets its own individually addressable DNS name. This is the right fit for databases and other stateful, distributed systems like Kafka or MongoDB where a specific replica's identity needs to be reachable directly.

**ReplicaSet vs Deployment**

A ReplicaSet only knows how to maintain a fixed number of pod replicas, it can scale up or down but has no concept of updating the pods to a new version without manual intervention, and it keeps no history of past states.

A Deployment sits on top of a ReplicaSet and adds what a ReplicaSet cannot do on its own, controlled rolling updates, automatic revision history, and one command rollback to any previous revision. Practically, a ReplicaSet is rarely created directly, a Deployment is used instead since it manages a ReplicaSet automatically while giving you version control style history and rollback for free.