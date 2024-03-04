# Dell Power Collector Kubernetes Release
This is the helm chart for Dell Power Collector helm chart.
Most installation and configuration information can be found inside `values.yaml`

## Installation
1. (Optional) Create imagePullSecret
If you are pulling the image from a private docker registry.
We need to create the image pull secret before we install this helm chart.
Here is the example command to load the local secret to Kubernetes secret:

```bash
kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=<path/to/.docker/config.json> \
    --type=kubernetes.io/dockerconfigjson
```
You can also create the secret from scrath:

```bash
kubectl create secret docker-registry regcred \
  --docker-server=<your-registry-server>  \
  --docker-username=<your-name> \
  --docker-password=<your-pword> \
  --docker-email=<your-email>
```

2. Edit the `values.yaml`:
    - If you created imagePullSecret in step 1, please specify that in `powerCollectorAgent.imagePullSecrets` in `values.yaml`
    - There examples for powerFlex, powerFlexManager, powerScale and powerStore configurations in `powerCollectorAgent.config`. 
    You can put various configurations in this config array to run several collector at the same time.

3. Install using `helm` command:
```bash
# For fresh installation
helm install --atomic if-power-collector-agent .

# For upgrade
helm upgrade --atomic if-power-collector-agent .
```
4. Check the pod running logs by
```bash
kubectl logs -f deployment/if-power-collector-agent-app
```

## Configuration
### Agent configuration
Agent configration are generated by the items under `powerCollectorAgent.config` in `values.yaml` and applied to the configMap automatically.

### Dell Root Certificate Configuration
If the the container is running inside the environment where has trafic/SSL inspection, we need to put the Root CA Certificate inside the container so that we can access InsightFinder API endpoints using SSL/TLS.
We can simply put the Root CA Certificate inside `templates/CACert.yaml` to make it look like the following:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: dell-root-ca-cert
  namespace: {{ .Release.Namespace }}
data:
  cert.pem: |
    -----BEGIN CERTIFICATE-----
    ......
    -----END CERTIFICATE-----
```