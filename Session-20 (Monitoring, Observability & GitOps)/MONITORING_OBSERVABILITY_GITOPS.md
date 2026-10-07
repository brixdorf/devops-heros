# Monitoring, Observability & GitOps Homework

## Task 1: Monitoring

Installed kube-prometheus-stack (Prometheus, Grafana, Alertmanager) on Minikube with Helm, deployed a demo app plus a pod that burns CPU on purpose, and wrote two alert rules. Covered:

| Topic | Where it shows up |
|---|---|
| Metrics | PromQL queries in Prometheus for CPU and memory per pod |
| Logs | `kubectl logs` on the nginx pods |
| Alerts | `HighPodCPU` going Pending, then Firing, then resolving |
| CPU utilization | `kubectl top`, Prometheus, Grafana |
| Memory utilization | Prometheus query and Grafana dashboard |
| Application health | Readiness and liveness probes, and the `PodNotReady` alert |

Commands, manifests and screenshots: [01-monitoring/README.md](01-monitoring/README.md).

## Task 2: Observability

Metrics, logs and traces, why observability is needed beyond plain monitoring, common tools, and how it all applies to Kubernetes: [02-observability/README.md](02-observability/README.md).

## Task 3: GitOps

What GitOps is (Git as the source of truth, declarative configuration, continuous reconciliation, the GitOps workflow), plus a hands-on Argo CD demo on Minikube. In the demo a change pushed to Git rolled out by itself, and a manual change made in the cluster was undone automatically: [03-gitops/README.md](03-gitops/README.md).
