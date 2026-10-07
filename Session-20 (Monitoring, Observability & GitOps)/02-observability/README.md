# Observability

**Observability** is how well you can understand what is happening inside a running system just by looking at the data it sends out. If a user says "checkout is slow", an observable system lets you find out why without adding new code or logging into servers one by one.

The data a system sends out about itself is called **telemetry**. Most people group telemetry into three types, called the three pillars: metrics, logs and traces.

## The three pillars

### Metrics

A **metric** is a number measured over time, like CPU usage, requests per second or error count. Each value has a timestamp and usually some **labels** (key/value tags such as `pod="web-1"` or `status="500"`) so you can filter and group.

Example: a Prometheus style metric for an API.

```
http_requests_total{service="orders", status="500"}  42
```

If this counter jumps from 42 to 400 in five minutes, something is wrong. Metrics are cheap to store and great for dashboards and alerts, but they only tell you *that* something changed, not the full story.

### Logs

A **log** is a text record of a single event, written by the app at a specific moment. Logs carry the details that a number cannot.

Example: a structured (JSON) log line from the same service.

```json
{"time":"2026-10-07T10:15:02Z","level":"error","service":"orders","msg":"payment API timeout","order_id":"A1029"}
```

Now I know *which* order failed and *why*. The downside is volume: logs from many Pods add up to a lot of data, so they cost more to store and search.

### Traces

A **trace** follows one request as it travels through several services. Each step is called a **span** (a timed piece of work, like "call payment service, 1.8s"). All spans of one request share a **trace ID**, so a tool can draw them as a timeline.

Example: one checkout request.

```
checkout request            2.1s
 |-- orders-service          2.0s
 |   |-- inventory-service   0.1s
 |   `-- payment-service     1.8s   <- the slow part
```

Traces answer "where did the time go?" in a microservices app, which neither metrics nor logs can do on their own.

### How they work together

A typical investigation uses all three: an alert fires on a metric (error rate is up), a trace shows the slow or failing service, and the logs of that service explain the exact error. Good tools let you jump between them, for example by putting the trace ID inside each log line.

## Why observability and not just monitoring

**Monitoring** means watching a set of known signals and alerting when they cross a limit, like "CPU above 90%" or "website is down". It answers questions you thought of in advance.

Observability goes further: it lets you ask *new* questions you did not plan for. In a monolith on one server, monitoring was often enough. In Kubernetes with dozens of microservices, Pods that come and go, and requests that cross many services, failures are often new and strange. A dashboard might show everything green while one customer's requests fail because of one bad combination of services.

So in short:

- Monitoring tells you **something is wrong**.
- Observability helps you find **why it is wrong and where**.

Monitoring is still part of observability. You still need alerts, you just also need rich data to dig into after the alert.

## Common tools

| Tool | What it does |
|------|--------------|
| **Prometheus** | Collects and stores metrics. It *pulls* (scrapes) numbers from apps over HTTP and has its own query language, PromQL. CNCF graduated. |
| **Grafana** | Dashboards. Shows data from Prometheus, Loki, Tempo, Elasticsearch and many others in one place. |
| **Loki** | Log storage from Grafana Labs. Indexes only the labels of each log stream, not the full text, which keeps it cheap. |
| **ELK / EFK** | Elasticsearch (stores and searches logs), Logstash or Fluentd/Fluent Bit (collect and ship logs), Kibana (UI). The "F" version is common on Kubernetes. |
| **Jaeger** | Distributed tracing backend and UI. CNCF graduated. |
| **Tempo** | Grafana's tracing backend, designed to store lots of traces cheaply. |
| **OpenTelemetry (OTel)** | A vendor neutral standard plus SDKs and a Collector for producing and sending telemetry. Traces, metrics and logs are stable in the specification; profiling is a newer signal still in an early stage. You instrument once and can send data to any backend. |
| **Datadog, New Relic, Dynatrace** | Paid SaaS platforms that handle metrics, logs and traces in one product. Less setup, but it costs money as data grows. |

A popular free stack is Prometheus + Loki + Tempo, all shown in Grafana, with OpenTelemetry for instrumentation.

## Observability in Kubernetes

### Built in kubectl commands

These work on any cluster and are the first place to look:

```bash
kubectl logs <pod>                 # container stdout/stderr
kubectl logs <pod> -c <container>  # one container in a multi-container Pod
kubectl logs <pod> --previous      # logs of the last crashed container
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl describe pod <pod>         # status plus recent events for that Pod
kubectl top nodes
kubectl top pods
```

**Events** are short messages from Kubernetes itself, such as `FailedScheduling`, `BackOff` or `Pulling image`. They are only kept for a limited time (one hour by default), so they are good for recent problems only.

### metrics-server

`kubectl top` does not work out of the box. It needs **metrics-server**, a small component that collects current CPU and memory usage from each node's kubelet (the agent running on every node) and exposes it through the Kubernetes API. The Horizontal Pod Autoscaler uses the same data. It only keeps the latest values, so it is not a monitoring system with history. On Minikube:

```bash
minikube addons enable metrics-server
```

### kube-state-metrics

**kube-state-metrics** watches the Kubernetes API and turns the *state of objects* into Prometheus metrics. Examples: how many replicas a Deployment wants vs how many are ready, Pods stuck in `Pending`, container restart counts. It does not measure CPU or memory; it answers "what does the cluster look like right now?"

### node-exporter

**node-exporter** is a Prometheus exporter (a small program that exposes metrics for Prometheus to scrape) that runs on every node, usually as a DaemonSet (one Pod per node). It reports machine level data: CPU, memory, disk space, network traffic, load average.

The `kube-prometheus-stack` Helm chart installs Prometheus, Grafana, node-exporter and kube-state-metrics together, which is the usual way to get started.

### Collecting logs: agent vs sidecar

Containers should write logs to stdout/stderr. The container runtime saves them to files on the node, which is what `kubectl logs` reads. Those files are lost when Pods are cleaned up, so we ship them somewhere central. There are two common patterns:

- **Node agent (DaemonSet):** one log collector Pod per node (Fluent Bit, Grafana Alloy, the OTel Collector) reads all container log files on that node and sends them to Loki or Elasticsearch. Apps need no changes and it uses few resources. This is the default choice.
- **Sidecar:** an extra container inside the app's Pod that reads the app's logs (for example from a shared emptyDir volume) and ships them. Useful when an app can only write to a file, or needs special processing. The cost is one extra container in every Pod.

## Summary

Metrics show the trend, logs show the details, traces show the path of a request. Monitoring alerts on known problems, observability helps debug unknown ones. In Kubernetes, start with `kubectl logs/top/events`, add metrics-server, then a Prometheus + Grafana stack with kube-state-metrics and node-exporter, and a DaemonSet log agent.
