{{/*
Expand the name of the chart.
*/}}
{{- define "kservectl.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kservectl.fullname" -}}
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
{{- define "kservectl.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kservectl.labels" -}}
helm.sh/chart: {{ include "kservectl.chart" . }}
{{ include "kservectl.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kservectl.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kservectl.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kservectl.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kservectl.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Values keys that used to mean something, with what to write instead: this chart's half
of the check `config.py` does over the files it renders.

A cluster's accelerators and presets come from its values file, and a preset's own
retired keys (`resources`, `node_selector`, `lmcache_enabled`, ...) reach kservectl
verbatim and are refused there by name. The keys below never reach it -- nothing renders
them -- so dropping them silently is how a values file still written for 0.1.x installs
as a kservectl with no presets and no accelerators, which then dies naming the empty
accelerator list rather than the file that is out of date. Failing the render instead
says what to migrate, and leaves the running release untouched while it is.
*/}}
{{- define "kservectl.validateValues" -}}
{{- $retired := dict
  "models" "renamed to `presets`, whose entries name an `accelerator:` instead of writing their own `resources` and `node_selector`; the accelerators themselves go under `accelerators:`"
  "default_accelerator" "removed: sizing is never guessed, so a deploy names its `accelerator` or is refused"
  "sites_url" "removed with the per-cloud layer; every cluster is EKS"
  "ingress" "replaced by `httpRoute`, a Gateway API HTTPRoute, and off by default"
-}}
{{- $found := list -}}
{{- range $key, $replacement := $retired }}
{{- if hasKey $.Values $key }}
{{- $found = append $found (printf "`%s` was %s" $key $replacement) }}
{{- end }}
{{- end }}
{{- if $found }}
{{- fail (printf "kservectl: this values file is written for an older chart. %s" (join "; also " $found)) }}
{{- end }}
{{- end }}
