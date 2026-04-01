# response-time-receiver-agent

A Helm chart for deploying the [response-time-receiver-agent](https://github.com/insightfinder/InsightAgent/tree/master/response-time-receiver-agent) — a lightweight Go/Fiber HTTP server that receives metric data from ServiceNow agents and forwards it to the InsightFinder platform.

## How It Works

External agents (e.g. ServiceNow) send HTTP POST requests to `/api/v1/data`. The receiver maps incoming metric names against a configured `metriclistMap` and forwards matched metrics to one or more InsightFinder environments (staging/production).

## Resources

| Resource | Description |
|----------|-------------|
| `Deployment` | Single replica of the receiver agent |
| `ConfigMap` | Mounts `configs/config.yaml` into the container |
| `Service` | ClusterIP on port 8080 |
| `HTTPRoute` | Gateway API route via `traefik-gateway` (enabled by default) |

## Configuration

All application config is under the `config` key in `values.yaml`, which is rendered as `configs/config.yaml` inside the container.

## Install

```bash
helm install response-time-receiver-agent ./charts/response-time-receiver-agent -n <namespace>
```

Override credentials via a separate values file:

```bash
helm install response-time-receiver-agent ./charts/response-time-receiver-agent \
  -f my-values.yaml -n <namespace>
```

## Test

```bash
helm test response-time-receiver-agent -n <namespace> --logs
```

Runs two tests:

1. `GET /health` — expects HTTP 200
2. `POST /api/v1/data` — sends a sample ServiceNow payload, expects `"success":true`

The test pod is automatically deleted after completion.
