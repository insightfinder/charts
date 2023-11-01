## Prometheus
InsightFinder Kubernetes Agent uses Prometheus to collect metric data in the cluster.

## Installation
### Add the repo
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```
### Install Prometheus
```bash
helm install prometheus \
    --set server.persistentVolume.size=20Gi \
    --set server.retention=1d \
    prometheus-community/prometheus
```