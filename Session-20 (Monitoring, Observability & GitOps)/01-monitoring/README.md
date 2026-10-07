# Monitoring Demo: Prometheus, Grafana and Alerts on Minikube

Monitoring means collecting numbers and events about a system and raising an alarm when something crosses a line.

## Install the stack

```bash
minikube start --cpus=4 --memory=6144
minikube addons enable metrics-server
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
kubectl wait --for=condition=Ready pods --all -n monitoring --timeout=420s
kubectl get pods -n monitoring
```

The stack installed with Helm, with the Prometheus pod still starting when the screenshot was taken.

![](../image1.png)

## Deploy the demo app and alert rules

An nginx Deployment with probes, a `cpu-burner` pod, and two alerts: `HighPodCPU` (over 0.2 cores for 1 minute) and `PodNotReady`.

```bash
kubectl apply -f demo-app.yaml
kubectl apply -f alert-rules.yaml
kubectl get pods -n monitoring-demo
kubectl get prometheusrule -n monitoring demo-alerts
```

## CPU and memory utilization

```bash
kubectl top nodes
kubectl top pods -n monitoring-demo
```

The burner sits at its 300m CPU limit while nginx is near zero.

![](../image2.png)

## Metrics in Prometheus

Port-forwarded Prometheus and ran the two queries below at `http://localhost:9090`.

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
```

```text
sum by (pod) (rate(container_cpu_usage_seconds_total{namespace="monitoring-demo", container!=""}[2m]))
sum by (pod) (container_memory_working_set_bytes{namespace="monitoring-demo", container!=""})
```

CPU cores per pod as a graph, and memory per pod as a table.

![](../image3.png)

## Alerts

`HighPodCPU` went from Pending to Firing for `cpu-burner` once the condition had lasted 1 minute.

![](../image4.png)

## Grafana dashboards

```bash
kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d; echo
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

The Kubernetes / Compute Resources / Namespace (Pods) dashboard for `monitoring-demo`.

![](../image5.png)

## Logs and application health

Health comes from the readiness and liveness probes. Deleting the burner made `HighPodCPU` resolve on its own.

```bash
kubectl logs -n monitoring-demo deploy/web --tail=5
kubectl get pods -n monitoring-demo
kubectl delete pod cpu-burner -n monitoring-demo
```

nginx access logs from the kubelet probes, and all pods ready.

![](../image6.png)

## Cleanup

```bash
kubectl delete -f demo-app.yaml -f alert-rules.yaml --ignore-not-found
helm uninstall monitoring -n monitoring
kubectl delete namespace monitoring
```
