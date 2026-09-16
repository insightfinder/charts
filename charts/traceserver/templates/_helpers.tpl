{{/*
Expand the name of the chart.
*/}}
{{- define "traceserver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "traceserver.fullname" -}}
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
{{- define "traceserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "traceserver.labels" -}}
helm.sh/chart: {{ include "traceserver.chart" . }}
{{ include "traceserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "traceserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "traceserver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Render a Gateway API route. Expects a dict:
  root, kind (HTTPRoute|GRPCRoute), name, route (values block), service, port
*/}}
{{- define "traceserver.route" -}}
{{- $root := .root -}}
{{- $service := .service -}}
{{- $port := .port -}}
{{- $gateway := $root.Values.gateway | default dict -}}
{{- $parentRefs := .route.parentRefs | default $gateway.parentRefs -}}
apiVersion: gateway.networking.k8s.io/v1
kind: {{ .kind }}
metadata:
  name: {{ .name }}
  labels:
    {{- include "traceserver.labels" $root | nindent 4 }}
  {{- with .route.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  parentRefs:
    {{- with $parentRefs }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .route.hostnames }}
  hostnames:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
    {{- range .route.rules }}
    - {{- with .matches }}
      matches:
      {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .filters }}
      filters:
      {{- toYaml . | nindent 8 }}
      {{- end }}
      backendRefs:
        - name: {{ $service }}
          port: {{ $port }}
          weight: 1
    {{- end }}
{{- end }}
