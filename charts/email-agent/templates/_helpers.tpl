{{/*
Expand the name of the chart.
*/}}
{{- define "email-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "email-agent.fullname" -}}
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
Per-component names. Both Deployments and Services live under one release, so
each needs its own suffix; main-agent reaches the subagent at the second one.
*/}}
{{- define "email-agent.mainAgent.fullname" -}}
{{- printf "%s-main" (include "email-agent.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "email-agent.subagent.fullname" -}}
{{- printf "%s-subagent" (include "email-agent.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "email-agent.labels" -}}
helm.sh/chart: {{ include "email-agent.name" . }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "email-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Tracing env shared by both components -- identical on purpose, so their spans
land in one project under one identity.
*/}}
{{- define "email-agent.tracingEnv" -}}
- name: ENABLE_TRACING
  value: {{ .Values.tracing.enabled | quote }}
- name: OTLP_ENDPOINT
  value: {{ .Values.tracing.otlpEndpoint | quote }}
- name: IF_TRACE_USER
  value: {{ .Values.tracing.ifUser | quote }}
- name: IF_TRACE_PROJECT
  value: {{ .Values.tracing.ifProject | quote }}
- name: IF_TRACE_SYSTEM
  value: {{ .Values.tracing.ifSystem | quote }}
- name: IF_TRACE_LICENSE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secretName }}
      key: if-trace-license-key
      optional: true
{{- end }}
