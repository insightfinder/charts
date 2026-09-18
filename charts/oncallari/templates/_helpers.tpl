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

{{/*
Temporal
*/}}
{{- define "insightfinder.temporalServiceName" -}}
{{- printf "%s-temporal" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.temporalSecretName" -}}
{{- .Values.temporal.postgresql.existingSecret | default (printf "%s-temporal-secret" (include "insightfinder.fullname" .)) }}
{{- end }}

{{- define "insightfinder.temporalWebServiceName" -}}
{{- printf "%s-temporal-web" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.temporalUiIngressName" -}}
{{- printf "%s-temporal-ui" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.temporalBasicAuthMiddlewareName" -}}
{{- printf "%s-temporal-basic-auth" (include "insightfinder.fullname" .) }}
{{- end }}

{{- define "insightfinder.temporalBasicAuthSecretName" -}}
{{- .Values.temporal.ingress.basicAuth.secretName | default (printf "%s-temporal-basicauth" (include "insightfinder.fullname" .)) }}
{{- end }}
