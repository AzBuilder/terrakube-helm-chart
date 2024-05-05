# Terrakube with Azure Authentication

## Requirements

To use this examples you will need the following:

- Entra ID Directory ( formerly known as Azure AD Directory ) 
- Azure Storage Account with these containers:
  - registry (blob)
  - tfstate (private)
  - tfoutput (private)
- SQL Azure Database

> Before running the helm chart it is require to have a working ingress setup in your cluster (For example Ngnix Ingress but any other ingress should work)

## YAML Example

Replace **_<<CHANGE_THIS>>_** with the real values

```Yaml
## Global Name
name: "terrakube"

## Terrakube Security
security:
  adminGroup: "<<CHANGE_THIS>>" # This should be your Entra ID (formerly Azure AD) group name
  patSecret: "<<CHANGE_THIS>>"  # Sample Key 32 characters z6QHX!y@Nep2QDT!53vgH43^PjRXyC3X
  internalSecret: "<<CHANGE_THIS>>" # Sample Key 32 characters Kb^8cMerPNZV6hS!9!kcD*KuUPUBa^B3
  dexClientId: "microsoft"
  dexClientScope: "email openid profile offline_access groups"

## Terraform Storage
storage:
  defaultStorage: false
  azure:
    storageAccountName: "<<CHANGE_THIS>>"
    storageAccountResourceGroup: "<<CHANGE_THIS>>"
    storageAccountAccessKey: "<<CHANGE_THIS>>"

## Dex
dex:
  config:
    issuer: https://<<CHANGE_THIS>>/dex # Change this to your terrakube api url for example terrakube-api.example.com
    storage:
      type: memory
    oauth2:
      responseTypes: ["code", "token", "id_token"] 
      skipApprovalScreen: true
    web:
      allowedOrigins: ['*']
  
    staticClients:
    - id: microsoft
      redirectURIs:
      - 'https://<<CHANGE_THIS>>' # Change this to your Terrakube UI URL for example terrakube.example.com
      - 'http://localhost:10001/login'
      - 'http://localhost:10000/login'
      - '/device/callback'
      name: 'microsoft'
      public: true

    connectors:
    - type: microsoft
      id: microsoft
      name: microsoft
      config:
        clientID: "<<CHANGE_THIS>>"
        clientSecret: "<<CHANGE_THIS>>"
        redirectURI: "https://<<CHANGE_THIS>>/dex/callback" # Change this to your terrakube api url for example terrakube-api.example.com
        tenant: "<<CHANGE_THIS>>"

## API properties
api:
  enabled: true
  replicaCount: "1"
  serviceType: "ClusterIP"
  properties:
    databaseType: "SQL_AZURE"
    databaseHostname: "<<CHANGE_THIS>>" #Change with the real value for example terrakubedb.database.azure.com
    databaseName: "<<CHANGE_THIS>>"
    databaseUser: "<<CHANGE_THIS>>"
    databasePassword: "<<CHANGE_THIS>>"

## Ingress properties
ingress:
  useTls: true
  ui:
    enabled: true
    domain: "<<CHANGE_THIS>>" # Change this to your Terrakube UI URL for example terrakube.example.com
    path: "/(.*)"
    pathType: "Prefix"
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      cert-manager.io/cluster-issuer: letsencrypt
  api:
    enabled: true
    domain: "<<CHANGE_THIS>>" # Change this to your terrakube api url for example terrakube-api.example.com
    path: "/(.*)"
    pathType: "Prefix"
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
      cert-manager.io/cluster-issuer: letsencrypt
  registry:
    enabled: true
    domain: "<<CHANGE_THIS>>" # Change this to your terrakube registry url for example terrakube-registry.example.com
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
