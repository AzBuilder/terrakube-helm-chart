# Terrakube Helm Chart

## Requirements

To install Terrakube in a Kubernetes cluster you will need the following:

- Azure Storage Account, Amazon S3 bucket or GCP Bucket
- Supported database:
  - SQL Azure
  - PostgreSQL
  - Mysql
- Create a YAML file with all the require parameters.

## Instalation

### 1. Authentication

To handle authentication we use [DEX](https://dexidp.io/) to support different providers using [connectors]((https://dexidp.io/docs/connectors/)), you can use any connectors as long it supports the ***groups scope***. 
For example you can use the following connectors:
- LDAP
- GitHub
- SAML 2.0
- Gitlab
- OpenID Connect
- Google
- Microsoft
- OpenShift
- Etc.

> DEX authentication is only supported from terrakube 2.6.0 and helm chart version 2.0.0 the helm chart values are not backward compatibly with lower version.

Once we have decided which connectors we would like to us we can create Dex configuation. 
The following in an example of Dex configuration using Azure Active Directory, Google Cloud Identit, Github and Gitlab to handle authentication and groups:

```yaml
    config:
      issuer: https://api.terrakube.docker.internal/dex
      storage:
        type: memory
      oauth2:
        responseTypes: ["code", "token", "id_token"] 
      web:
        allowedOrigins: ['ui.terrakube.docker.internal']
  
      staticClients:
      - id: microsoft
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'microsoft'
        public: true
      - id: github
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'github-web'
        public: true
      - id: gitlab
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'gitlab'
        public: true
      - id: google
        redirectURIs:
        - 'https://ui.terrakube.docker.com'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'google'
        public: true

      connectors:
      - type: microsoft
        id: microsoft
        name: microsoft
        config:
          clientID: "<<CLIENT ID FROM FROM AZURE ACTIVE DIRECTORY>>"
          clientSecret: "<<CLIENT SECRET FROM AZURE ACTIVE DIRECTORY>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"
          tenant: "<<TENANT ID FROM AZURE ACTIVE DIRECTORY>>"
      - type: github
        id: github
        name: gitHub
        config:
          clientID: "<<CLIENT ID FROM GITHUB>>"
          clientSecret: "<<CLIENTE SECRET FROM GITHUB>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"
      - type: gitlab
        id: gitlab
        name: gitLab
        config:
          clientID: "<<CLIENT ID FROM GITLAB>>"
          clientSecret: "<<CLIENT SECRET FROM GITLAB>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"
      - type: google
        id: google
        name: google
        config:
          clientID: "<<CLIENT ID FROM GOOGLE CLOUD>>"
          clientSecret: "<<CLIENT SECRET FROM GOOGLE CLOUD>>"
          redirectURI: "https://api.terrakube.docker.com/dex/callback"
          serviceAccountFilePath: "/etc/secrets/gcp-credentials.json"
          adminEmail: "superAdmin@demo.com"
```

To learn more about how to build the Dex configuration file please review the following [documentation](https://dexidp.io/docs/)

- [Azure Active Directory](https://dexidp.io/docs/connectors/microsoft/)
- [Google Cloud Identity](https://dexidp.io/docs/connectors/google/)
- [Github](https://dexidp.io/docs/connectors/github/)
- [Gitlab](https://dexidp.io/docs/connectors/gitlab/)

### 2. Terrakube Admin Group

In order to use Terrakube you will have to define the one or more administrator groups, for example:
- TERRAKUBE_ADMIN

Members of these groups are the only users inside terrakube that can create ***organizations*** and ***handle team access***, to define more than one admin group use the ***security.admins*** separated by ***","***

Example:

```
security:
  ...
  admins: "TERRAKUBE_ADMIN,AZURE_ADMINS,GCP_ADMINS"
```

> For Google Cloud Identity groups name will be like "groupName@yourdomain.com", For Github Authentication will be like "organizationName:teamName"

### 3. Terrakube Storage

#### 3.1 Azure Storage Account

Terrakube require an Azure Storage account to save the state/output for the jobs and to save the terraform modules when using terraform CLI and it require the following containers:
- registry (blob)
- tfstate (private)
- tfoutput (private)

To create the Azure storage account you can use the following [terraform module](https://github.com/AzBuilder/terraform-azurerm-terrakube-cloud-storage).

#### 3.2 AWS S3

Terrakube require an Aws S3 to save the state/output for the jobs and to save the terraform modules when using terraform CLI, it could be a private bucket.

To create the Aws S3 you can use the following [terraform module]() (Work in Progress).

#### 3.2 GCP Storage 

Terrakube require an Storage bucket to save the state/output for the jobs and to save the terraform modules when using terraform CLI.

To create the Gcp Storage you can use the following [terraform module]() (Work in Progress).

### 4. Build Yaml file

Once you have completed the above steps you can complete the file values.yaml to deploy the helm chart, you can check the following examples:

***Google Identity and GCP Storage Bucket***

You will need to include the gcp-credentials.json file inside the secretFiles folder before running the helm install.

```
## Global Name
name: "terrakube"

## Terrakube Security
security:
  patSecret: "XXXXX"
  internalSecret: "XXXXX"
  dexIssuerUri: "https://api.terrakube.docker.com/dex"
  dexClientId: "google"
  dexClientScope: "email openid profile offline_access groups"

## Terraform Storage
storage:
  gcp:
    projectId: "XXXXX"
    bucketName: "XXXXX"
    credentials: "XXXXX"

## Dex
dex:
  enabled: true
  version: "v2.32.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  volumeMounts:
    - name: gcp-credentials
      mountPath: "/etc/secrets"
      readOnly: true
  volumes:
    - name: gcp-credentials
      secret:
        secretName: "terrakube-secret-files"
        items:
          - key: "gcp-credentials.json"
            path: "gcp-credentials.json"
  resources:
    limits:
      cpu: 512m
      memory: 256Mi
    requests:
      cpu: 256m
      memory: 128Mi
  properties:
    config:
      issuer: https://api.terrakube.docker.com/dex
      storage:
        type: memory
      oauth2:
        responseTypes: ["code", "token", "id_token"] 
      web:
        allowedOrigins: ["*"]
  
      staticClients:
      - id: google
        redirectURIs:
        - 'https://ui.terrakube.docker.com'
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
          clientID: "XXXXX"
          clientSecret: "XXXXX"
          redirectURI: "https://api.terrakube.docker.com/dex/callback"
          serviceAccountFilePath: "/etc/secrets/gcp-credentials.json"
          adminEmail: "XXXXX@yourdomain.com"

## API properties
api:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources:
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi
  properties:
    databaseType: "H2"
    DexIssuerUri: "https://api.terrakube.docker.com/dex"

## Executor properties
executor:
  enabled: true
  version: "2.6.0"  
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources:
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi
  properties:
    toolsRepository: "https://github.com/AzBuilder/terrakube-extensions"
    toolsBranch: "main"
    terraformStateType: "GcpTerraformStateImpl"
    terraformOutputType: "GcpTerraformOutputImpl"

## Registry properties
registry:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources:
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi

## UI Properties
ui:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 200m
      memory: 256Mi

## Ingress properties
ingress:
  useTls: true
  ui:
    enabled: true
    domain: "ui.terrakube.docker.com"
    path: "/(.*)"
    pathType: "Prefix" 
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
  api:
    enabled: true
    domain: "api.terrakube.docker.com"
    path: "/(.*)"
    pathType: "Prefix"
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
  registry:
    enabled: true
    domain: "registry.terrakube.docker.com"
    path: "/(.*)"
    pathType: "Prefix"
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
  dex:
    enabled: true
    path: "/dex/(.*)"
    pathType: "Prefix"
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
```


***Example using Nginx Ingress and Azure Storage Account***

```yaml
## Global Name
name: "terrakube"

## Terrakube Security
security:
  # Sample Key 32 characters z6QHX!y@Nep2QDT!53vgH43^PjRXyC3X Base64 ejZRSFgheUBOZXAyUURUITUzdmdINDNeUGpSWHlDM1g=
  patSecret: "ejZRSFgheUBOZXAyUURUITUzdmdINDNeUGpSWHlDM1g=" #<==CHANGE THIS FOR YOUR SECRET

  # Sample Key 32 characters Kb^8cMerPNZV6hS!9!kcD*KuUPUBa^B3 Base64 S2JeOGNNZXJQTlpWNmhTITkha2NEKkt1VVBVQmFeQjM=
  internalSecret: "S2JeOGNNZXJQTlpWNmhTITkha2NEKkt1VVBVQmFeQjM=" #<==CHANGE THIS FOR YOUR SECRET
  dexIssuerUri: "https://api.terrakube.docker.internal/dex"

## Terraform Storage
storage:
  azure:
    storageAccountName: "XXX" #Replace with values from Step 3
    storageAccountResourceGroup: "XXX"
    storageAccountAccessKey: "XXX"

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
      issuer: https://api.terrakube.docker.internal/dex
      storage:
        type: memory
      oauth2:
        responseTypes: ["code", "token", "id_token"] 
      web:
        allowedOrigins: ['ui.terrakube.docker.internal']
  
      staticClients:
      - id: microsoft
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'microsoft'
        public: true
      - id: github
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'github-web'
        public: true
      - id: gitlab
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'gitlab'
        public: true

      connectors:
      - type: microsoft
        id: microsoft
        name: microsoft
        config:
          clientID: "<<CLIENT ID FROM FROM AZURE ACTIVE DIRECTORY>>"
          clientSecret: "<<CLIENT SECRET FROM AZURE ACTIVE DIRECTORY>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"
          tenant: "<<TENANT ID FROM AZURE ACTIVE DIRECTORY>>"
      - type: github
        id: github
        name: gitHub
        config:
          clientID: "<<CLIENT ID FROM GITHUB>>"
          clientSecret: "<<CLIENTE SECRET FROM GITHUB>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"
      - type: gitlab
        id: gitlab
        name: gitLab
        config:
          clientID: "<<CLIENT ID FROM GITLAB>>"
          clientSecret: "<<CLIENT SECRET FROM GITLAB>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"

## API properties
api:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources: #Optional
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi
  properties:
    databaseType: "SQL_AZURE" # Replace with "H2" (ONLY FOR TESTING), "SQL_AZURE", "POSTGRESQL" or "MYSQL"
    databaseHostname: "mysuperdatabse.database.windows.net" # Replace with the real value
    databaseName: "databasename" # Replace with the real value
    databaseUser: "databaseuser" # Replace with the real value
    databasePassword: "XXX" # Replace with the real value

## Executor properties
executor:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources: #Optional
    limits:
      cpu: 1000m
      memory: 1024Mi
    requests:
      cpu: 500m
      memory: 256Mi
  properties:
    toolsRepository: "https://github.com/AzBuilder/terrakube-extensions" # Default extension repository
    toolsBranch: "main" #Default branch for extensions
    terraformStateType: "AzureTerraformStateImpl" # This is the only supported type currently
    terraformOutputType: "AzureTerraformOutputImpl" # This is the only supported type currently

## Registry properties
registry:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources: #Optional
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi

## UI Properties
ui:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 200m
      memory: 256Mi

## Ingress properties
ingress:
  useTls: true
  ui:
    enabled: true
    domain: "ui.terrakube.docker.internal" # Replace with the real value
    path: "/(.*)" # Replace with the real value
    pathType: "Prefix" # Replace with the real value
    annotations: # This annotations can change based on requirements. The followin is an example using nginx ingress and lets encrypt
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      cert-manager.io/cluster-issuer: letsencrypt
  api:
    enabled: true
    domain: "api.terrakube.docker.internal" # Replace with the real value
    path: "/(.*)" # Replace with the real value
    pathType: "Prefix" # Replace with the real value
    annotations: # This annotations can change based on requirements. The followin is an example using nginx ingress and lets encrypt
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/rewrite-target: /$2 
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
      cert-manager.io/cluster-issuer: letsencrypt
  registry: 
    enabled: true
    domain: "registry.terrakube.docker.internal" # Replace with the real value
    path: "/(.*)" # Replace with the real value
    pathType: "Prefix" # Replace with the real value
    annotations: # This annotations can change based on requirements. The followin is an example using nginx ingress and lets encrypt
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      cert-manager.io/cluster-issuer: letsencrypt
  dex:
    enabled: false
    path: "/dex/(.*)" # Replace with the real value
    pathType: "Prefix" # Replace with the real value
    annotations: # This annotations can change based on requirements. The followin is an example using nginx ingress and lets encrypt
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
```

***Example using Nginx Ingress and AWS S3:***
```yaml
## Global Name
name: "terrakube"

## Terrakube Security
security:
  # Sample Key 32 characters z6QHX!y@Nep2QDT!53vgH43^PjRXyC3X Base64 ejZRSFgheUBOZXAyUURUITUzdmdINDNeUGpSWHlDM1g=
  patSecret: "ejZRSFgheUBOZXAyUURUITUzdmdINDNeUGpSWHlDM1g=" #<==CHANGE THIS FOR YOUR SECRET

  # Sample Key 32 characters Kb^8cMerPNZV6hS!9!kcD*KuUPUBa^B3 Base64 S2JeOGNNZXJQTlpWNmhTITkha2NEKkt1VVBVQmFeQjM=
  internalSecret: "S2JeOGNNZXJQTlpWNmhTITkha2NEKkt1VVBVQmFeQjM=" #<==CHANGE THIS FOR YOUR SECRET
  dexIssuerUri: "https://api.terrakube.docker.internal/dex"

## Terraform Storage
storage:
  aws:
    accessKey: "XXX"
    secretKey: "XXX"
    bucketName: "XXX"
    region: "XXX"

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
      issuer: https://api.terrakube.docker.internal/dex
      storage:
        type: memory
      oauth2:
        responseTypes: ["code", "token", "id_token"] 
      web:
        allowedOrigins: ['ui.terrakube.docker.internal']
  
      staticClients:
      - id: microsoft
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'microsoft'
        public: true
      - id: github
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'github-web'
        public: true
      - id: gitlab
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'gitlab'
        public: true

      connectors:
      - type: microsoft
        id: microsoft
        name: microsoft
        config:
          clientID: "<<CLIENT ID FROM FROM AZURE ACTIVE DIRECTORY>>"
          clientSecret: "<<CLIENT SECRET FROM AZURE ACTIVE DIRECTORY>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"
          tenant: "<<TENANT ID FROM AZURE ACTIVE DIRECTORY>>"
      - type: github
        id: github
        name: gitHub
        config:
          clientID: "<<CLIENT ID FROM GITHUB>>"
          clientSecret: "<<CLIENTE SECRET FROM GITHUB>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"
      - type: gitlab
        id: gitlab
        name: gitLab
        config:
          clientID: "<<CLIENT ID FROM GITLAB>>"
          clientSecret: "<<CLIENT SECRET FROM GITLAB>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"

## API properties
api:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources: #Optional
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi
  properties:
    databaseType: "SQL_AZURE" # Replace with "H2" (ONLY FOR TESTING), "SQL_AZURE", "POSTGRESQL" or "MYSQL"
    databaseHostname: "mysuperdatabse.database.windows.net" # Replace with the real value
    databaseName: "databasename" # Replace with the real value
    databaseUser: "databaseuser" # Replace with the real value
    databasePassword: "XXX" # Replace with the real value

## Executor properties
executor:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources: #Optional
    limits:
      cpu: 1000m
      memory: 1024Mi
    requests:
      cpu: 500m
      memory: 256Mi
  properties:
    toolsRepository: "https://github.com/AzBuilder/terrakube-extensions" # Default extension repository
    toolsBranch: "main" #Default branch for extensions
    terraformStateType: "AwsTerraformStateImpl" 
    terraformOutputType: "AwsTerraformOutputImpl" 

## Registry properties
registry:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources: #Optional
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi

## UI Properties
ui:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 200m
      memory: 256Mi

## Ingress properties
ingress:
  useTls: true
  ui:
    enabled: true
    domain: "ui.terrakube.docker.internal" # Replace with the real value
    path: "/(.*)" # Replace with the real value
    pathType: "Prefix" # Replace with the real value
    annotations: # This annotations can change based on requirements. The followin is an example using nginx ingress and lets encrypt
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      cert-manager.io/cluster-issuer: letsencrypt
  api:
    enabled: true
    domain: "api.terrakube.docker.internal" # Replace with the real value
    path: "/(.*)" # Replace with the real value
    pathType: "Prefix" # Replace with the real value
    annotations: # This annotations can change based on requirements. The followin is an example using nginx ingress and lets encrypt
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/rewrite-target: /$2 
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
      cert-manager.io/cluster-issuer: letsencrypt
  registry: 
    enabled: true
    domain: "registry.terrakube.docker.internal" # Replace with the real value
    path: "/(.*)" # Replace with the real value
    pathType: "Prefix" # Replace with the real value
    annotations: # This annotations can change based on requirements. The followin is an example using nginx ingress and lets encrypt
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      cert-manager.io/cluster-issuer: letsencrypt
  dex:
    enabled: false
    path: "/dex/(.*)" # Replace with the real value
    pathType: "Prefix" # Replace with the real value
    annotations: # This annotations can change based on requirements. The followin is an example using nginx ingress and lets encrypt
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
```

***Example using Nginx Ingress and Gcp Storage:***
```yaml
## Global Name
name: "terrakube"

## Terrakube Security
security:
  # Sample Key 32 characters z6QHX!y@Nep2QDT!53vgH43^PjRXyC3X Base64 ejZRSFgheUBOZXAyUURUITUzdmdINDNeUGpSWHlDM1g=
  patSecret: "ejZRSFgheUBOZXAyUURUITUzdmdINDNeUGpSWHlDM1g=" #<==CHANGE THIS FOR YOUR SECRET

  # Sample Key 32 characters Kb^8cMerPNZV6hS!9!kcD*KuUPUBa^B3 Base64 S2JeOGNNZXJQTlpWNmhTITkha2NEKkt1VVBVQmFeQjM=
  internalSecret: "S2JeOGNNZXJQTlpWNmhTITkha2NEKkt1VVBVQmFeQjM=" #<==CHANGE THIS FOR YOUR SECRET
  dexIssuerUri: "https://api.terrakube.docker.internal/dex"

## Terraform Storage
storage:
  gcp:
    projectId: "XXXX"
    bucketName: "XXX"
    credentials: "XXX" #<==JSON CREDENTIAL IN BASE64 ENCODING

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
      issuer: https://api.terrakube.docker.internal/dex
      storage:
        type: memory
      oauth2:
        responseTypes: ["code", "token", "id_token"] 
      web:
        allowedOrigins: ['ui.terrakube.docker.internal']
  
      staticClients:
      - id: microsoft
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'microsoft'
        public: true
      - id: github
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'github-web'
        public: true
      - id: gitlab
        redirectURIs:
        - 'https://ui.terrakube.docker.internal'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'gitlab'
        public: true

      connectors:
      - type: microsoft
        id: microsoft
        name: microsoft
        config:
          clientID: "<<CLIENT ID FROM FROM AZURE ACTIVE DIRECTORY>>"
          clientSecret: "<<CLIENT SECRET FROM AZURE ACTIVE DIRECTORY>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"
          tenant: "<<TENANT ID FROM AZURE ACTIVE DIRECTORY>>"
      - type: github
        id: github
        name: gitHub
        config:
          clientID: "<<CLIENT ID FROM GITHUB>>"
          clientSecret: "<<CLIENTE SECRET FROM GITHUB>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"
      - type: gitlab
        id: gitlab
        name: gitLab
        config:
          clientID: "<<CLIENT ID FROM GITLAB>>"
          clientSecret: "<<CLIENT SECRET FROM GITLAB>>"
          redirectURI: "https://api.terrakube.docker.internal/dex/callback"

## API properties
api:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources: #Optional
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi
  properties:
    databaseType: "SQL_AZURE" # Replace with "H2" (ONLY FOR TESTING), "SQL_AZURE", "POSTGRESQL" or "MYSQL"
    databaseHostname: "mysuperdatabse.database.windows.net" # Replace with the real value
    databaseName: "databasename" # Replace with the real value
    databaseUser: "databaseuser" # Replace with the real value
    databasePassword: "XXX" # Replace with the real value

## Executor properties
executor:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources: #Optional
    limits:
      cpu: 1000m
      memory: 1024Mi
    requests:
      cpu: 500m
      memory: 256Mi
  properties:
    toolsRepository: "https://github.com/AzBuilder/terrakube-extensions" # Default extension repository
    toolsBranch: "main" #Default branch for extensions
    terraformStateType: "GcpTerraformStateImpl" 
    terraformOutputType: "GcpTerraformOutputImpl" 

## Registry properties
registry:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources: #Optional
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi

## UI Properties
ui:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 200m
      memory: 256Mi

## Ingress properties
ingress:
  useTls: true
  ui:
    enabled: true
    domain: "ui.terrakube.docker.internal" # Replace with the real value
    path: "/(.*)" # Replace with the real value
    pathType: "Prefix" # Replace with the real value
    annotations: # This annotations can change based on requirements. The followin is an example using nginx ingress and lets encrypt
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      cert-manager.io/cluster-issuer: letsencrypt
  api:
    enabled: true
    domain: "api.terrakube.docker.internal" # Replace with the real value
    path: "/(.*)" # Replace with the real value
    pathType: "Prefix" # Replace with the real value
    annotations: # This annotations can change based on requirements. The followin is an example using nginx ingress and lets encrypt
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/rewrite-target: /$2 
      nginx.ingress.kubernetes.io/configuration-snippet: "proxy_set_header Authorization $http_authorization;"
      cert-manager.io/cluster-issuer: letsencrypt
  registry: 
    enabled: true
    domain: "registry.terrakube.docker.internal" # Replace with the real value
    path: "/(.*)" # Replace with the real value
    pathType: "Prefix" # Replace with the real value
    annotations: # This annotations can change based on requirements. The followin is an example using nginx ingress and lets encrypt
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/use-regex: "true"
      cert-manager.io/cluster-issuer: letsencrypt
```

***Example using Amazon EKS with Amazon Load Balancer, Amazon S3 Bucket and Postgres database***

We use these domains as an example:

- UI Domain: ***terrakube-ui-dev.aws.dev***
- Registry Domain: ***terrakube-reg-dev.aws.dev***
- API Domain: ***terrakube-api-dev.aws.dev***

You will need to change these with some real public domain

```yaml
## Global Name
name: "terrakube"

## Terrakube Security
security:
  # Sample Key 32 characters z6QHX!y@Nep2QDT!53vgH43^PjRXyC3X Base64 ejZRSFgheUBOZXAyUURUITUzdmdINDNeUGpSWHlDM1g=
  patSecret: "ejZRSFgheUBOZXAyUURUITUzdmdINDNeUGpSWHlDM1g=" #<==CHANGE THIS FOR YOUR SECRET

  # Sample Key 32 characters Kb^8cMerPNZV6hS!9!kcD*KuUPUBa^B3 Base64 S2JeOGNNZXJQTlpWNmhTITkha2NEKkt1VVBVQmFeQjM=
  internalSecret: "S2JeOGNNZXJQTlpWNmhTITkha2NEKkt1VVBVQmFeQjM=" #<==CHANGE THIS FOR YOUR SECRET
  dexIssuerUri: "https://api.terrakube.docker.internal/dex"

## Terraform Storage
storage:
  aws:
    accessKey: "XXX"
    secretKey: "XXX"
    bucketName: "XXX"
    region: "XXX"

## API properties
api:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "NodePort"
  resources: #Optional
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi
  properties:
    databaseType: "POSTGRESQL" # Supported values "SQL_AZURE", "POSTGRESQL" or "MYSQL"
    databaseHostname: "terrakuaws.postgres.database.aws.com" # Replace with the real value
    databaseName: "databasename" # Replace with the real value
    databaseUser: "databaseuser" # Replace with the real value
    databasePassword: "XXX" # Replace with the real value

## Executor properties
executor:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "NodePort"
  resources: #Optional
    limits:
      cpu: 1000m
      memory: 1024Mi
    requests:
      cpu: 500m
      memory: 256Mi
  properties:
    toolsRepository: "https://github.com/AzBuilder/terrakube-extensions" # Default extension repository
    toolsBranch: "main" #Default branch for extensions
    terraformStateType: "AwsTerraformStateImpl" 
    terraformOutputType: "AwsTerraformOutputImpl" 

## Registry properties
registry:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "NodePort"
  resources: #Optional
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi

## UI Properties
ui:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "NodePort"
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 200m
      memory: 256Mi

## Ingress properties
ingress:
  useTls: true
  ui:
    enabled: true
    domain: "terrakube-ui-dev.aws.dev" # Replace with the real domain
    path: "/" 
    pathType: "Prefix" 
    annotations: # This annotations can change based on requirements. The followin is an example using EKS
      alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
      alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:XXXXXX:certificate/XXXXXXXX # Change this for a real certiricate
      alb.ingress.kubernetes.io/group.name: alb-deployment
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-1-2017-01
      alb.ingress.kubernetes.io/ssl-redirect: "443"
      external-dns.alpha.kubernetes.io/hostname: terrakube-ui-dev.aws.dev # Replace with the real domain
      alb.ingress.kubernetes.io/target-type: ip
      kubernetes.io/ingress.class: alb
  api:
    enabled: true
    domain: "terrakube-api-dev.aws.dev" # Replace with the real domain
    path: "/" 
    pathType: "Prefix" 
    annotations: # The followin is an example using EKS
      alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
      alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:XXXXXX:certificate/XXXXXXXX # Replace with real certificate
      alb.ingress.kubernetes.io/group.name: alb-deployment
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-1-2017-01
      alb.ingress.kubernetes.io/ssl-redirect: "443"
      external-dns.alpha.kubernetes.io/hostname: terrakube-api-dev.aws.dev # Replace with the real domain
      alb.ingress.kubernetes.io/target-type: ip
      kubernetes.io/ingress.class: alb
  registry: 
    enabled: true
    domain: "terrakube-reg-dev.aws.dev" # Replace with the real domain
    path: "/" 
    pathType: "Prefix" 
    annotations: # The followin is an example using EKS
      alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
      alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:XXXXXX:certificate/XXXXXXXX # Replace with real certificate
      alb.ingress.kubernetes.io/group.name: alb-deployment
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-1-2017-01
      alb.ingress.kubernetes.io/ssl-redirect: "443"
      external-dns.alpha.kubernetes.io/hostname: terrakube-reg-dev.aws.dev # Replace with the real domain
      alb.ingress.kubernetes.io/target-type: ip
      kubernetes.io/ingress.class: alb
```

### 4.1 Node Affinity, NodeSelector, Taints and Tolerations.

The API, Registry, Executor and UI support using affinity, taints and tolerations. Use the following examples as reference:

#### Example API.

```yaml
api:
  enabled: true
  version: "2.6.0"
  replicaCount: "1"
  serviceType: "ClusterIP"
  resources:
    limits:
      cpu: 500m
      memory: 1024Mi
    requests:
      cpu: 200m
      memory: 256Mi
  tolerations: # OPTIONAL
  - key: "key1"
    operator: "Equal"
    value: "value1"
    effect: "NoSchedule"
  nodeSelector: # OPTIONAL
    disktype: ssd
  affinity:  # OPTIONAL
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: name
            operator: In
            values:
            - terrakube
  properties:
    databaseType: "H2"
```

### 5. Deploy Terrakube using helm chart

Now you have all the information to deploy Terrakube, you can use the following example:

Clone the helm chart repository and fill the values.yaml file
```bash
git clone https://github.com/AzBuilder/terrakube-helm-chart.git
```
Create the kubernetes namespace:
```bash
kubectl create namespace terrakube
```
Test the helm chart before installing:
```bash
helm install --dry-run --debug --values ./values.yaml terrakube ./terrakube-helm-chart/ -n terrakube
```
Running the helm chart.
```bash
helm install --debug --values ./values.yaml terrakube ./terrakube-helm-chart/ -n terrakube
```

After installing you should be able to view the app using ui domain inside the values.yaml. 

Example: 

https://ui.terrakube.docker.internal
