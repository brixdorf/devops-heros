# Monitoring, Observability & GitOps Homework

## Task 1: Monitoring

Installed kube-prometheus-stack (Prometheus, Grafana, Alertmanager) on Minikube with Helm, deployed a demo app with a pod that burns CPU, and wrote two alert rules. It covers metrics, logs, alerts, CPU and memory utilization, and application health: [01-monitoring/README.md](01-monitoring/README.md).

## Task 2: Observability

Metrics, logs and traces, why observability is needed, common tools, and how it applies to Kubernetes: [02-observability/README.md](02-observability/README.md).

## Task 3: GitOps

What GitOps is, plus an Argo CD demo where a change pushed to Git rolled out by itself and a manual change in the cluster was reverted: [03-gitops/README.md](03-gitops/README.md).
