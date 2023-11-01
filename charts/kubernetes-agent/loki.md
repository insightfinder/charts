## Loki
InsightFinder Kubernetes Agent uses Grafana Loki to collect log data in the cluster.

## Installation
### Add the Helm Repo
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### Install Loki (minimal)
```bash
helm install loki grafana/loki \
    --set monitoring.selfMonitoring.enabled=false \
    --set monitoring.lokiCanary.enabled=false \
    --set test.enabled=false \
    --set loki.auth_enabled=false \
    --set loki.limits_config.retention_period=1h \
    --set loki.compactor.retention_enabled=true \
    --set loki.compactor.compaction_interval=10m \
    --set loki.compactor.retention_delete_worker_count=150 \
    --set loki.commonConfig.replication_factor=1 \
    --set backend.replicas=1 \
    --set read.replicas=1 \
    --set write.replicas=1 \
    --set minio.enabled=true \
    --set minio.replicas=1 \
    --set minio.persistence.size=20Gi
```

### Install Promtail Client
```bash
helm install promtail grafana/promtail
```