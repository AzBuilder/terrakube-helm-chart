# Terrakube with Github Authentication

## Requirements

To use this examples you will need the following:

- Github Organization with some Teams [setup](https://dexidp.io/docs/connectors/github/)
- Azure Storage Account with these containers:

  - registry (blob)
  - tfstate (private)
  - tfoutput (private)

  > Before running the helm chart it is require to have a working ingress setup in your cluster (For example Ngnix Ingress but any other ingress should work)

## YAML Example

Replace **_<<CHANGE_THIS>>_** with the real values

```Yaml
## Global Name
name: "terrakube"

## Terrakube Security
security:
  adminGroup: "<<CHANGE_THIS>>" # This should be your Github team the format is OrganizationName:TeamName
  patSecret: "<<CHANGE_THIS>>"  # Sample Key 32 characters z6QHX!y@Nep2QDT!53vgH43^PjRXyC3X
  internalSecret: "<<CHANGE_THIS>>" # Sample Key 32 characters Kb^8cMerPNZV6hS!9!kcD*KuUPUBa^B3
  dexClientId: "github"
  dexClientScope: "email openid profile offline_access groups"

## Terraform Storage
storage:
  defaultStorage: false
  azure:
    storageAccountName: "<<CHANGE_THIS>>"
    storageAccountResourceGroup: "<<CHANGE_THIS>>"
    storageAccountAccessKey: "<<CHANGE_THIS>>"

dex:
  enabled: true
  config:
    issuer: https://terrakube-api.domain.com/dex
    storage:
      type: memory
    oauth2:
      responseTypes: ["code", "token", "id_token"]
      skipApprovalScreen: true
    web:
      allowedOrigins: ["*"]

    staticClients:
    - id: github
      redirectURIs:
      - 'https://terrakube-ui.domain.com'
      - 'http://localhost:10001/login'
      - 'http://localhost:10000/login'
      - '/device/callback'
      name: 'github'
      public: true

    connectors:
    - type: github
      id: github
      name: gitHub
      config:
        clientID: "<<CHANGE_THIS>>"
        clientSecret: "<<CHANGE_THIS>>"
        redirectURI: "https://terrakube-api.domain.com/dex/callback"
        loadAllGroups: true


## Ingress properties
ingress:
  useTls: true
  ui:
    enabled: true
    domains: 
    - "terrakube-ui.domain.com" # Change for your real domain
    path: "/(.*)"
    pathType: "Prefix"
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      cert-manager.io/cluster-issuer: letsencrypt
  api:
    enabled: true
    domains: 
    - "terrakube-api.domain.com" # Change for your real domain
    path: "/(.*)"
    pathType: "Prefix"
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
      cert-manager.io/cluster-issuer: letsencrypt
  registry:
    enabled: true
    domains: 
    - "terrakube-reg.domain.com" # Change for your real domain
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
