# Terrakube with Azure Authentication

## Requirements

To use this examples you will need the following:

- Azure Active Directory for Authentication
- Amazon EKS + Load Balancer
- S3 Bucket
- PostgreSQL Database

## YAML Example

Replace ***<<CHANGE_THIS>>*** with the real values

```Yaml
## Global Name
name: "terrakube"

## Terrakube Security
security:
  adminGroup: "<<CHANGE_THIS>>" # This should be your Azure AD group name
  patSecret: "<<CHANGE_THIS>>"  # Sample Key 32 characters z6QHX!y@Nep2QDT!53vgH43^PjRXyC3X 
  internalSecret: "<<CHANGE_THIS>>" # Sample Key 32 characters Kb^8cMerPNZV6hS!9!kcD*KuUPUBa^B3 
  dexClientId: "microsoft"
  dexClientScope: "email openid profile offline_access groups"
  dexIssuerUri: "https://terrakube-api.domain.com/dex" # Change for your real domain

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
      issuer: https://terrakube-api.domain.com/dex
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
        - 'https://terrakube-ui.domain.com' # Change for your real domain
        - 'http://localhost:3000'
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
          redirectURI: "https://terrakube-api.domain.com/dex/callback" # Change for your real domain
          tenant: "<<CHANGE_THIS>>"

## API properties
api:
  enabled: true
  version: "2.10.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  properties:
    databaseType: "POSTGRESQL"
    databaseHostname: "terrakubedb.database.azure.com" #Change with the real value
    databaseName: "<<CHANGE_THIS>>"
    databaseUser: "<<CHANGE_THIS>>"
    databasePassword: "<<CHANGE_THIS>>"

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
    domain: "terrakube-ui.domain.com" # Change for your real domain
    path: "/(.*)"
    pathType: "Prefix" 
    annotations: # This annotations can change based on requirements. The followin is an example using EKS
      alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
      alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:XXXXXX:certificate/XXXXXXXX # Change this for a real certiricate
      alb.ingress.kubernetes.io/group.name: alb-deployment
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-1-2017-01
      alb.ingress.kubernetes.io/ssl-redirect: "443"
      external-dns.alpha.kubernetes.io/hostname: terrakube-ui.domain.com # Replace with the real domain
      alb.ingress.kubernetes.io/target-type: ip
      kubernetes.io/ingress.class: alb
  api:
    enabled: true
    domain: "terrakube-api.domain.com" # Change for your real domain
    path: "/(.*)"
    pathType: "Prefix"
    annotations: # This annotations can change based on requirements. The followin is an example using EKS
      alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
      alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:XXXXXX:certificate/XXXXXXXX # Change this for a real certiricate
      alb.ingress.kubernetes.io/group.name: alb-deployment
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-1-2017-01
      alb.ingress.kubernetes.io/ssl-redirect: "443"
      external-dns.alpha.kubernetes.io/hostname: terrakube-api.domain.com # Replace with the real domain
      alb.ingress.kubernetes.io/target-type: ip
      kubernetes.io/ingress.class: alb
  registry:
    enabled: true
    domain: "terrakube-reg.domain.com" # Change for your real domain
    path: "/(.*)"
    pathType: "Prefix"
    annotations: # This annotations can change based on requirements. The followin is an example using EKS
      alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
      alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:XXXXXX:certificate/XXXXXXXX # Change this for a real certiricate
      alb.ingress.kubernetes.io/group.name: alb-deployment
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-1-2017-01
      alb.ingress.kubernetes.io/ssl-redirect: "443"
      external-dns.alpha.kubernetes.io/hostname: terrakube-reg.domain.com # Replace with the real domain
      alb.ingress.kubernetes.io/target-type: ip
      kubernetes.io/ingress.class: alb
  dex:
    enabled: true
    path: "/dex/(.*)"
    pathType: "Prefix"
    annotations: # This annotations can change based on requirements. The followin is an example using EKS
      alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
      alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:XXXXXX:certificate/XXXXXXXX # Change this for a real certiricate
      alb.ingress.kubernetes.io/group.name: alb-deployment
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-1-2017-01
      alb.ingress.kubernetes.io/ssl-redirect: "443"
      external-dns.alpha.kubernetes.io/hostname: terrakube-reg.domain.com # Replace with the real domain
      alb.ingress.kubernetes.io/target-type: ip
      kubernetes.io/ingress.class: alb

```