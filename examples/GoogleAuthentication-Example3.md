# Terrakube with Google Cloud Identity Authentication

## Requirements

To use this examples you will need the following:

- Google Cloud Identity
- Google Storage Bucket
- MySQL

> Before running the helm chart it is require to have a working ingress setup in your cluster (For example Ngnix Ingress but any other ingress should work)

## YAML Example

Replace **_<<CHANGE_THIS>>_** with the real values

```Yaml
## Global Name
name: "terrakube"

## Terrakube Security
security:
  adminGroup: "<<CHANGE_THIS>>" # The value should be a gcp group (format: group_name@yourdomain.com example: terrakube_admin@terrakube.io)
  patSecret: "<<CHANGE_THIS>>"  # Sample Key 32 characters z6QHX!y@Nep2QDT!53vgH43^PjRXyC3X
  internalSecret: "<<CHANGE_THIS>>" # Sample Key 32 characters Kb^8cMerPNZV6hS!9!kcD*KuUPUBa^B3
  dexClientId: "google"
  dexClientScope: "email openid profile offline_access groups"
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
  defaultStorage: false
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
  replicaCount: "1"
  serviceType: "ClusterIP"
  properties:
    databaseType: "MYSQL"
    databaseHostname: "terrakubedb.database.com" #Change with the real value
    databaseName: "<<CHANGE_THIS>>"
    databaseUser: "<<CHANGE_THIS>>"
    databasePassword: "<<CHANGE_THIS>>"

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
