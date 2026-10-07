# Kubernetes Storage, HPA & Probes Homework

## Task 1: Kubernetes Volumes

Tried emptyDir, hostPath, PersistentVolume, PersistentVolumeClaim, StorageClass and dynamic provisioning, each with its own manifest. Notes, commands and screenshots are in [01-kubernetes-volumes/README.md](01-kubernetes-volumes/README.md).

## Task 2: HPA Hands-on

HPA changes the replica count of a Deployment to keep average CPU near a target. It reads CPU from metrics-server.

### Deploy the application and configure HPA

```bash
minikube addons enable metrics-server
cd 02-hpa
kubectl apply -f deployment.yaml
kubectl apply -f hpa.yml
kubectl rollout status deployment/php-apache
kubectl get pods
kubectl get hpa
```

Pod running, and TARGETS still `<unknown>` because metrics-server had no reading yet.

![](image7.png)

### Verify HPA

```bash
kubectl top pods
kubectl describe hpa php-apache
```

After about a minute it showed 0% of the 50% target with 1 replica.

![](image8.png)

### Deploy the load generator and increase load

```bash
kubectl apply -f load-generator.yaml
kubectl get hpa php-apache --watch
```

CPU jumped to 128% and HPA scaled from 1 to 3 to 5 pods.

![](image9.png)

### Observe CPU utilization and pod scaling

```bash
kubectl get hpa
kubectl get pods
kubectl top pods
kubectl describe hpa php-apache | tail -8
```

With 5 pods (the max) CPU came down to 79%, and the events show both rescales.

![](image10.png)

### Stop the load and scale down

```bash
kubectl delete pod load-generator
kubectl get hpa php-apache --watch
```

CPU fell to 0% quickly, but HPA waited about 5 minutes before scaling down to 2 and then 1.

![](image11.png)

## Task 3: Mini Project, Self-Healing Website with Persistent Storage

An nginx site on a dynamically provisioned PVC, with startup, readiness and liveness probes and an HPA. Write-up in [03-mini-project/README.md](03-mini-project/README.md).

## Cleanup

```bash
kubectl delete -f 02-hpa/ --ignore-not-found
kubectl delete -f 03-mini-project/
```
