# Mini Project: Fixing a Broken Bookstore

## Problem Statement

The bookstore has a `books-api` backend (2 replicas behind a Service) and a `frontend` pod that calls it every 5 seconds. After applying `broken/app.yaml` nothing works, and the goal is to find and fix every problem with kubectl.

## Before

```bash
kubectl apply -f broken/app.yaml
sleep 30
kubectl get all -n bookstore
```

Both `books-api` pods in `ImagePullBackOff` and the frontend in `CreateContainerConfigError`.

![](../image12.png)

## Investigation

```bash
kubectl describe pod -n bookstore -l app=books-api --show-events=true | grep "Failed to pull"
kubectl describe pod -n bookstore -l app=frontend | tail -4
kubectl get configmap frontend-config -n bookstore -o yaml
kubectl get endpoints books-api -n bookstore
kubectl get pods -n bookstore --show-labels
kubectl get svc books-api -n bookstore -o jsonpath='{.spec.selector}'
```

The bad image tag, the missing ConfigMap key, and a Service with no endpoints.

![](../image13.png)

## Root Causes

1. Image tag typo `nginx:1.27-alpne`, should be `nginx:1.27-alpine`.
2. The frontend reads the key `API_URL`, but the ConfigMap defines `API_HOST`.
3. The Service selector is `app: book-api`, but the pods are labeled `app: books-api`.

## Solution

Fixed all three in `fixed/app.yaml` and applied it.

```bash
kubectl apply -f fixed/app.yaml
kubectl rollout status deploy/books-api -n bookstore
kubectl rollout status deploy/frontend -n bookstore
```

## After

```bash
sleep 15
kubectl get all -n bookstore
kubectl get endpoints books-api -n bookstore
kubectl logs -n bookstore deploy/frontend --tail=5
```

All pods running, 2 endpoints on the Service, and the frontend logging `backend OK`.

![](../image14.png)

## Cleanup

```bash
kubectl delete namespace bookstore
```
