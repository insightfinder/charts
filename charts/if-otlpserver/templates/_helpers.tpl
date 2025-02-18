{{/*
Expand the name of the chart.
*/}}
{{- define "if-otlpserver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "if-otlpserver.fullname" -}}
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
{{- define "if-otlpserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "if-otlpserver.labels" -}}
helm.sh/chart: {{ include "if-otlpserver.chart" . }}
{{ include "if-otlpserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "if-otlpserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "if-otlpserver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Define service name
*/}}
{{- define "if-otlpserver.serviceName" -}}
{{ printf "%s-svc" (include "if-otlpserver.fullname" .) }}
{{- end }}



{{/*
Define configmap name
*/}}
{{- define "if-otlpserver.configMapName" -}}
{{ printf "%s-config-cm" (include "if-otlpserver.fullname" .) }}
{{- end }}