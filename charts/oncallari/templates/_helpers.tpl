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
Shared multi-agent Ingress (routes one domain's path prefixes to each
agent kind's own, already-existing API Service -- see values.yaml's
sharedIngress block and templates/shared-agents-ingress.yaml)
*/}}
{{- define "insightfinder.sharedAgentsStripPrefixMiddlewareName" -}}
{{- printf "%s-agents-strip-prefix" (include "insightfinder.fullname" .) }}
{{- end }}
