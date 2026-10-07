# Observability

Observability is how well you can understand what is happening inside a system from the data it sends out.

## The three pillars

Metrics, logs and traces.

### Metrics

Numbers measured over time, like CPU usage or requests per second. They are cheap to store and good for dashboards and alerts.

### Logs

Timestamped records of single events. They give the detail of what happened.

### Traces

The path of one request through several services, with the time spent in each. They show where the slow part is.

### How they work together

A metric alert says something is wrong, a trace shows which service, and the logs of that service show why.

## Why observability and not just monitoring

Monitoring answers questions you thought of in advance, like "is CPU above 80%". Observability lets you ask new questions about problems you did not predict, which matters when there are many small services.

## Common tools

Prometheus and Grafana for metrics, Loki or the ELK stack for logs, Jaeger or Tempo for traces, and OpenTelemetry to collect all three.

## Observability in Kubernetes

Kubernetes has basic tools built in, and add-ons provide the rest.

### Built in kubectl commands

```bash
kubectl logs <pod>                 # container stdout/stderr
kubectl logs <pod> -c <container>  # one container in a multi-container Pod
kubectl logs <pod> --previous      # logs of the last crashed container
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl describe pod <pod>         # status plus recent events for that Pod
kubectl top nodes
kubectl top pods
```

### metrics-server

Collects live CPU and memory from the kubelets for `kubectl top` and the HPA. It keeps no history.

```bash
minikube addons enable metrics-server
```

### kube-state-metrics

Turns the state of Kubernetes objects into metrics, such as replica counts and whether a pod is ready.

### node-exporter

Runs on every node and exposes machine metrics like CPU, memory, disk and network.

### Collecting logs: agent vs sidecar

A node agent (a DaemonSet such as Fluent Bit) reads every container's log files on the node and is the usual choice. A sidecar is an extra container in the pod, used when an app writes logs to files instead of stdout.

## Summary

Metrics show that something is wrong, traces show where, and logs show why.
