# Terrakube with AWS Cognito Authentication

## Requirements

To use this examples you will need the following:

- AWS Cognito 
- AWS S3 Bucket
- PostgreSQL

## YAML Example

Replace ***<<CHANGE_THIS>>*** with the real values

```Yaml
## Global Name
name: "terrakube"

## Terrakube Security
security:
  adminGroup: "<<CHANGE_THIS>>" # The value should be a cognito group (example: TERRAKUBE_ADMIN)
  patSecret: "<<CHANGE_THIS>>"  # Sample Key 32 characters z6QHX!y@Nep2QDT!53vgH43^PjRXyC3X 
  internalSecret: "<<CHANGE_THIS>>" # Sample Key 32 characters Kb^8cMerPNZV6hS!9!kcD*KuUPUBa^B3 
  dexClientId: "cognito"
  dexClientScope: "email openid profile offline_access groups"
  dexIssuerUri: "<<CHANGE_THIS>>" #The value should be like https://terrakube-api.yourdomain.com/dex

## Terraform Storage
storage:
  aws:
    accessKey: "<<CHANGE_THIS>>"
    secretKey: "<<CHANGE_THIS>>"
    bucketName: "<<CHANGE_THIS>>"
    region: "<<CHANGE_THIS>>"

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
        skipApprovalScreen: true
      web:
        allowedOrigins: ["*"]
  
      staticClients:
      - id: cognito
        redirectURIs:
        - 'https://ui.yourdomain.com' #<<CHANGE_THIS>>
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'cognito'
        public: true

      connectors:
      - type: oidc
        id: cognito
        name: cognito
        config:
          issuer: "https://cognito-idp.XXXXX.amazonaws.com/XXXXXXX" #<<CHANGE_THIS>>
          clientID: "XXXX" #<<CHANGE_THIS>>
          clientSecret: "XXXXX" #<<CHANGE_THIS>>
          redirectURI: "https://terrakube-api.yourdomain.com/dex/callback" #<<CHANGE_THIS>>
          scopes:
            - openid
            - email
            - profile
          insecureSkipEmailVerified: true
          insecureEnableGroups: true
          userNameKey: "cognito:username"
          claimMapping: 
            groups: "cognito:groups"

## API properties
api:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  properties:
    databaseType: "POSTGRESQL"
    databaseHostname: "terrakubedb.database.com" #Change with the real value
    databaseName: "<<CHANGE_THIS>>"
    databaseUser: "<<CHANGE_THIS>>"
    databasePassword: "<<CHANGE_THIS>>"

## Executor properties
executor:
  enabled: true
  version: "2.6.0"  
  replicaCount: "1"
  serviceType: "ClusterIP"
  properties:
    toolsRepository: "https://github.com/AzBuilder/terrakube-extensions"
    toolsBranch: "main"

## Registry properties
registry:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"

## UI Properties
ui:
  enabled: true
  version: "2.6.0"
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