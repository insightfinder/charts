{{/*
Trimmed from the insightfinder umbrella chart's own _helpers.tpl: this is a
standalone chart, so only the helpers these templates actually reference are
kept. The `insightfinder.*` names are deliberately unchanged -- renaming them
would touch every template for no functional gain, and keeping them makes the
templates diff cleanly against the umbrella-chart original they came from.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "insightfinder.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "insightfinder.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "insightfinder.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "insightfinder.labels" -}}
helm.sh/chart: {{ include "insightfinder.chart" . }}
{{ include "insightfinder.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "insightfinder.selectorLabels" -}}
app.kubernetes.io/name: {{ include "insightfinder.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ARI On-Call Agent
*/}}
{{- define "insightfinder.ariOncallAgentApiServiceName" -}}
{{- printf "%s-api" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.ariOncallAgentWorkerName" -}}
{{- printf "%s-worker" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.ariOncallAgentSecretName" -}}
{{- .Values.ariOncallAgent.existingSecret | default (printf "%s-secret" (include "insightfinder.fullname" .)) }}
{{- end }}

{{- define "insightfinder.ariOncallAgentRepoCacheClaimName" -}}
{{- .Values.ariOncallAgent.persistence.repoCache.existingClaim | default (printf "%s-repo-cache" (include "insightfinder.fullname" .)) }}
{{- end }}

{{- define "insightfinder.ariOncallAgentBuildCacheClaimName" -}}
{{- .Values.ariOncallAgent.persistence.buildCache.existingClaim | default (printf "%s-build-cache" (include "insightfinder.fullname" .)) }}
{{- end }}

{{- define "insightfinder.ariOncallAgentTaskStoreClaimName" -}}
{{- .Values.ariOncallAgent.persistence.taskStore.existingClaim | default (printf "%s-task-store" (include "insightfinder.fullname" .)) }}
{{- end }}

{{/*
ARI Jenkins Agent

Distinct "-jenkins-*" suffixes (rather than reusing the oncall agent's
"-api"/"-worker"/"-secret") so both agents' resources can coexist under one
Helm release without name collisions -- these are two independently
toggleable agent kinds sharing one chart and one Temporal server, not
variants of the same deployment.
*/}}
{{- define "insightfinder.ariJenkinsAgentApiServiceName" -}}
{{- printf "%s-jenkins-api" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.ariJenkinsAgentWorkerName" -}}
{{- printf "%s-jenkins-worker" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.ariJenkinsAgentSecretName" -}}
{{- .Values.ariJenkinsAgent.existingSecret | default (printf "%s-jenkins-secret" (include "insightfinder.fullname" .)) }}
{{- end }}

{{/*
Same reasoning as the "-jenkins-*" suffixes above: a third independently
toggleable agent kind under the same release needs its own "-action-*"
names. This kind's images come from a different repository entirely
(insightfinder/ari-agent-demo), so unlike the other two it does NOT share
the ari-agent-api image -- see values.yaml's ariActionAgent.api.image.
*/}}
{{- define "insightfinder.ariActionAgentApiServiceName" -}}
{{- printf "%s-action-api" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.ariActionAgentWorkerName" -}}
{{- printf "%s-action-worker" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.ariActionAgentSecretName" -}}
{{- .Values.ariActionAgent.existingSecret | default (printf "%s-action-secret" (include "insightfinder.fullname" .)) }}
{{- end }}

{{/*
ARI Kubernetes Agent -- a fourth independently toggleable kind; "-k8s-*"
suffixes keep its resources from colliding with the other kinds' under one
release. Its ServiceAccount (and the cluster-scoped RBAC names) are only
used by the worker.
*/}}
{{- define "insightfinder.ariK8sAgentApiServiceName" -}}
{{- printf "%s-k8s-api" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.ariK8sAgentWorkerName" -}}
{{- printf "%s-k8s-worker" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.ariK8sAgentSecretName" -}}
{{- .Values.ariK8sAgent.existingSecret | default (printf "%s-k8s-secret" (include "insightfinder.fullname" .)) }}
{{- end }}

{{- define "insightfinder.ariK8sAgentTaskStoreClaimName" -}}
{{- .Values.ariK8sAgent.persistence.taskStore.existingClaim | default (printf "%s-k8s-task-store" (include "insightfinder.fullname" .)) }}
{{- end }}

{{/*
Refuses an ariK8sAgent configuration that would run but be unsafe or broken.
Whoever holds an API key can both propose and approve changes, and the worker
can patch Deployments cluster-wide, so a guessable key is a cluster credential;
without a payload key, request data sits in Temporal's history in plaintext;
the A2A task store is one pod's volume (or memory), so a second API replica
would lose proposals between pods.
*/}}
{{- define "insightfinder.ariK8sAgentValidate" -}}
{{- $a := .Values.ariK8sAgent -}}
{{- if not $a.existingSecret -}}
{{- if or (not $a.agentApiKeys) (eq (toString $a.agentApiKeys) "change-me") -}}
{{- fail "ariK8sAgent.agentApiKeys must be set to a generated key (or use ariK8sAgent.existingSecret): any holder of it can approve cluster changes" -}}
{{- end -}}
{{- if and (not $a.temporalPayloadEncryptionKeySecret.name) (not $a.temporalPayloadEncryptionKey) -}}
{{- fail "ariK8sAgent needs a Temporal payload encryption key: set temporalPayloadEncryptionKeySecret.name (preferred) or temporalPayloadEncryptionKey" -}}
{{- end -}}
{{- end -}}
{{- if gt (int $a.api.replicaCount) 1 -}}
{{- fail "ariK8sAgent.api.replicaCount must be 1: the A2A task store holding proposals that wait for approval belongs to one pod" -}}
{{- end -}}
{{- if and (not $a.serviceAccount.create) (not $a.serviceAccount.name) -}}
{{- fail "ariK8sAgent.serviceAccount.name is required when serviceAccount.create is false" -}}
{{- end -}}
{{- end }}

{{- define "insightfinder.ariK8sAgentServiceAccountName" -}}
{{- .Values.ariK8sAgent.serviceAccount.name | default (printf "%s-k8s" (include "insightfinder.fullname" .)) }}
{{- end }}

{{/*
Name shared by the ClusterRole and ClusterRoleBinding (and the prefix of the
kube-system Role/RoleBinding). Release-prefixed because these are cluster
scoped / live outside the release namespace.
*/}}
{{- define "insightfinder.ariK8sAgentRbacName" -}}
{{- printf "%s-k8s" (include "insightfinder.fullname" .) }}
{{- end }}

{{/*
TEMPORAL_PAYLOAD_ENCRYPTION_KEY from a pre-existing Secret (preferred).
Renders nothing when temporalPayloadEncryptionKeySecret.name is unset, in
which case the key (if any) comes from the release Secret via envFrom.
*/}}
{{- define "insightfinder.ariK8sAgentEncryptionKeyEnv" -}}
{{- with .Values.ariK8sAgent.temporalPayloadEncryptionKeySecret }}
{{- if .name }}
- name: TEMPORAL_PAYLOAD_ENCRYPTION_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .name }}
      key: {{ .key | default "TEMPORAL_PAYLOAD_ENCRYPTION_KEY" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Shared multi-agent Ingress (routes one domain's path prefixes to each
agent kind's own, already-existing API Service -- see values.yaml's
sharedIngress block and templates/shared-agents-ingress.yaml)
*/}}
{{- define "insightfinder.sharedAgentsStripPrefixMiddlewareName" -}}
{{- printf "%s-agents-strip-prefix" (include "insightfinder.fullname" .) }}
{{- end }}

{{/*
Chat gateway (Slack and Microsoft Teams front ends for an ARI agent)
*/}}
{{- define "insightfinder.chatGatewayName" -}}
{{- printf "%s-chat" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.chatGatewaySecretName" -}}
{{- printf "%s-chat-secret" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.chatGatewayAgentUrl" -}}
{{- if .Values.chatGateway.agentUrl }}
{{- .Values.chatGateway.agentUrl }}
{{- else if .Values.ariOncallAgent.enabled }}
{{- printf "http://%s" (include "insightfinder.ariOncallAgentApiServiceName" .) }}
{{- else }}
{{- fail "chatGateway.agentUrl is required when ariOncallAgent is not enabled in this release" }}
{{- end }}
{{- end }}

{{- define "insightfinder.chatGatewayAgentApiKey" -}}
{{- if .Values.chatGateway.agentApiKey }}
{{- .Values.chatGateway.agentApiKey }}
{{- else if .Values.ariOncallAgent.enabled }}
{{- splitList "," .Values.ariOncallAgent.agentApiKeys | first | trim }}
{{- end }}
{{- end }}

{{- define "insightfinder.chatGatewayEnv" -}}
- name: ARI_AGENT_URL
  value: {{ include "insightfinder.chatGatewayAgentUrl" . | quote }}
{{- range $name, $value := .Values.chatGateway.env }}
- name: {{ $name }}
  value: {{ $value | toString | quote }}
{{- end }}
{{- end }}

{{- define "insightfinder.chatGatewayEnvFrom" -}}
- secretRef:
    name: {{ include "insightfinder.chatGatewaySecretName" . }}
{{- with .Values.chatGateway.existingSecret }}
- secretRef:
    name: {{ . }}
{{- end }}
{{- end }}
