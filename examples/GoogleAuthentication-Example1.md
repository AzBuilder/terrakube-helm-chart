# Terrakube with Google Cloud Identity Authentication

## Requirements

To use this examples you will need the following:

- Google Cloud Identity
- Google Storage Bucket

## YAML Example

Replace ***<<CHANGE_THIS>>*** with the real values

```Yaml
## Global Name
name: "terrakube"

## Terrakube Security
security:
  adminGroup: "<<CHANGE_THIS>>" # The value should be a gcp group (format: group_name@yourdomain.com example: terrakube_admin@terrakube.org)
  patSecret: "<<CHANGE_THIS>>"  # Sample Key 32 characters z6QHX!y@Nep2QDT!53vgH43^PjRXyC3X 
  internalSecret: "<<CHANGE_THIS>>" # Sample Key 32 characters Kb^8cMerPNZV6hS!9!kcD*KuUPUBa^B3 
  dexClientId: "google"
  dexClientScope: "email openid profile offline_access groups"
  dexIssuerUri: "<<CHANGE_THIS>>" #The value should be like https://terrakube-api.yourdomain.com/dex
  gcpCredentials: |
    ## GCP JSON CREDENTIALS for service account with API Scope https://www.googleapis.com/auth/admin.directory.group.readonly
    {
      "type": "service_account",
      "project_id": "",
      "private_key_id": "",
      "private_key": "",
      "client_email": "",
      "client_id": "",
      "auth_uri": "",
      "token_uri": "",
      "auth_provider_x509_cert_url": "",
      "client_x509_cert_url": ""
    } 


## Terraform Storage
storage:
  gcp:
    projectId: "<<CHANGE_THIS>>"
    bucketName: "<<CHANGE_THIS>>"
    credentials: |
      ## GCP JSON CREDENTIALS for service account with access to read/write to the storage bucket
      {
        "type": "service_account",
        "project_id": "",
        "private_key_id": "",
        "private_key": "",
        "client_email": "",
        "client_id": "",
        "auth_uri": "",
        "token_uri": "",
        "auth_provider_x509_cert_url": "",
        "client_x509_cert_url": ""
      } 


## Dex
dex:
  enabled: true
  version: "v2.32.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources:
    limits:
      cpu: 512m
      memory: 256Mi
    requests:
      cpu: 256m
      memory: 128Mi
  properties:
    config:
      issuer: https://terrakube-api.yourdomain.com/dex #<<CHANGE_THIS>>
      storage:
        type: memory
      oauth2:
        responseTypes: ["code", "token", "id_token"] 
      web:
        allowedOrigins: ["*"]
  
      staticClients:
      - id: google
        redirectURIs:
        - 'https://terrakube-ui.yourdomain.com' #<<CHANGE_THIS>>
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'google'
        public: true

      connectors:
      - type: google
        id: google
        name: google
        config:
          clientID: "<<CHANGE_THIS>>"
          clientSecret: "<<CHANGE_THIS>>"
          redirectURI: "https://terrakube-api.yourdomain.com/dex/callback"
          serviceAccountFilePath: "/etc/gcp/secret/gcp-credentials" # GCP CREDENTIAL FILE WILL BE IN THIS PATH
          adminEmail: "<<CHANGE_THIS>>" 

## API properties
api:
  enabled: true
  version: "2.10.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  properties:
    databaseType: "H2"

## Executor properties
executor:
  enabled: true
  version: "2.10.0"  
  replicaCount: "1"
  serviceType: "ClusterIP"
  properties:
    toolsRepository: "https://github.com/AzBuilder/terrakube-extensions"
    toolsBranch: "main"

## Registry properties
registry:
  enabled: true
  version: "2.10.0"
  replicaCount: "1"
  serviceType: "ClusterIP"

## UI Properties
ui:
  enabled: true
  version: "2.10.0"
  replicaCount: "1"
  serviceType: "ClusterIP"

## Ingress properties
ingress:
  useTls: true
  ui:
    enabled: true
    domain: "terrakube-ui.yourdomain.com"
    path: "/(.*)"
    pathType: "Prefix" 
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      cert-manager.io/cluster-issuer: letsencrypt
  api:
    enabled: true
    domain: "terrakube-api.yourdomain.com"
    path: "/(.*)"
    pathType: "Prefix"
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
      cert-manager.io/cluster-issuer: letsencrypt
  registry:
    enabled: true
    domain: "terrakube-reg.yourdomain.com"
    path: "/(.*)"
    pathType: "Prefix"
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
      cert-manager.io/cluster-issuer: letsencrypt
  dex:
    enabled: true
    path: "/dex/(.*)"
    pathType: "Prefix"
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
      cert-manager.io/cluster-issuer: letsencrypt

```