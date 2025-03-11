{{/*
Expand the name of the chart.
*/}}
{{- define "terrakube.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "terrakube.fullname" -}}
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
{{- define "terrakube.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "terrakube.labels" -}}
helm.sh/chart: {{ include "terrakube.chart" . }}
{{ include "terrakube.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "terrakube.selectorLabels" -}}
app.kubernetes.io/name: {{ include "terrakube.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
API labels
*/}}
{{- define "terrakube-api.labels" -}}
app.kubernetes.io/component: terrakube-api
{{ include "terrakube.selectorLabels" . }}
{{- end }}

{{/*
Executor labels
*/}}
{{- define "terrakube-executor.labels" -}}
app.kubernetes.io/component: terrakube-executor
{{ include "terrakube.selectorLabels" . }}
{{- end }}

{{/*
OpenLDAP labels
*/}}
{{- define "terrakube-openldap.labels" -}}
app.kubernetes.io/component: terrakube-openldap
{{ include "terrakube.selectorLabels" . }}
{{- end }}

{{/*
Registry labels
*/}}
{{- define "terrakube-registry.labels" -}}
app.kubernetes.io/component: terrakube-registry
{{ include "terrakube.selectorLabels" . }}
{{- end }}

{{/*
UI labels
*/}}
{{- define "terrakube-ui.labels" -}}
app.kubernetes.io/component: terrakube-ui
{{ include "terrakube.selectorLabels" . }}
{{- end }}