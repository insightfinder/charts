# Kubernete Action Server
This is the helm chart repo to install and configure kubernetes action server.

## Configurations

| Field                         | Description                                     | Example Value               |
| ----------------------------- | ----------------------------------------------- | --------------------------- |
| `ingress.ingressClassName`    | The class of the ingress controller.            | `nginx`                     |
| `ingress.host`                | The hostname for the ingress resource.          | `myaction-server.aaa.com`   |
| `ingress.tls.enabled`         | Indicates if TLS is enabled for the ingress.    | `true`                      |
| `ingress.tls.secretName`      | The name of the secret used for TLS in ingress. | `ingress-tls-secret`        |
| `insightfinder.url`           | The URL for the InsightFinder service.          | `https://stg.insightfinder.com` |
| `insightfinder.user`          | The username for accessing InsightFinder.       | `user`                      |
| `insightfinder.licenseKey`    | The license key for InsightFinder (if applicable). | `""` (Empty in this case) |
| `insightfinder.systemId`      | The system ID for InsightFinder (if applicable).| `""` (Empty in this case)   |

## Install
```bash
helm repo add insightfinder https://insightfinder.github.io/charts
helm install if-kubeactions -f values.yaml insightfinder/if-kubeactions --version 0.0.1
```

## Upgrade
```bash
helm upgrade if-kubeactions -f values.yaml insightfinder/if-kubeactions --version 0.0.1
```