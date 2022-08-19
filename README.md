# Terrakube Helm Chart

## Requirements

To install Terrakube in a Kubernetes cluster you will need the following:

- Dex connector with support for the groups claim.
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
      issuer: https://terrakube-api.domain.com/dex
      storage:
        type: memory
      oauth2:
        responseTypes: ["code", "token", "id_token"] 
      web:
        allowedOrigins: ['**']
  
      staticClients:
      - id: microsoft
        redirectURIs:
        - 'https://terrakube-ui.domain.com'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'microsoft'
        public: true
      - id: github
        redirectURIs:
        - 'https://terrakube-ui.domain.com'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'github-web'
        public: true
      - id: gitlab
        redirectURIs:
        - 'https://terrakube-ui.domain.com'
        - 'http://localhost:3000'
        - 'http://localhost:10001/login'
        - 'http://localhost:10000/login'
        - '/device/callback'
        name: 'gitlab'
        public: true
      - id: google
        redirectURIs:
        - 'https://terrakube-ui.domain.com'
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

In order to use Terrakube you will have to define the one administrator group, for example:
- TERRAKUBE_ADMIN

Members of these groups are the only users inside terrakube that can create ***organizations*** and ***handle team access***, to define more than one admin group use the ***security.admins*** 

Example:

```
security:
  admins: "TERRAKUBE_ADMIN"
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

Once you have completed the above steps you can complete the file values.yaml to deploy the helm chart, you can check the example folder:

- Google Identity Authentication 
  - [Ngnix Ingress + H2 Database + GCP Storage Bucket](examples/GoogleAuthentication-Example1.md)
  - [Ngnix Ingress + PostgreSQL +  GCP Storage Bucket](examples/GoogleAuthentication-Example3.md)
  - [Ngnix Ingress + MySQL +  GCP Storage Bucket](examples/GoogleAuthentication-Example3.md)
- Azure Authentication 
  - [Ngnix Ingress + H2 Database + Azure Storage Account](examples/AzureAuthentication-Example1.md)
  - [Ngnix Ingress + SQL Azure + Azure Storage Account](examples/AzureAuthentication-Example2.md)
  - [Ngnix Ingress + PostgreSQL + Azure Storage Account](examples/AzureAuthentication-Example3.md)
  - [Amazon Load Balancer + PostgreSQL + S3 Bucket](examples/AzureAuthentication-Example4.md)
- Amazon AWS Cognito
  - WIP.

### 4.1 Helm Value Properties


| Key                                       | Required | Description                                                            |
|:------------------------------------------|----------|------------------------------------------------------------------------|
| name                                      | Yes      | Use "Terrakube"                                                        |
| security.adminGroup                       | Yes      | Admin group inside Terrakube                                           |
| security.patSecret                        | Yes      | 32 Character secret to sign personal access token                      |
| security.internalSecret                   | Yes      | 32 Character secret to sing internal                                   |
| security.dexClientId                      | Yes      | Based on Dex config file                                               |
| security.dexClientScope                   | Yes      | Use "email openid profile offline_access groups"                       |
| security.dexIssuerUri                     | Yes      | Should be "https://apiDomain/dex"                                      |
| security.gcpCredentials                   | No       | JSON Credentials for Google Identity Authentication                    |
| storage.gcp.projectId                     | No       | GCP Project Id for the storage                                         |
| storage.gcp.bucketName                    | No       | GCP Bucket name for the storage                                        |
| storage.gcp.credentials                   | No       | GCP JSON Credentials for the storage                                   |
| storage.azure.storageAccountName          | No       | Azure storage account name                                             |
| storage.azure.storageAccountResourceGroup | No       | Azure storage resource group                                           |
| storage.azure.storageAccountAccessKey     | No       | Azure storage access key                                               |
| dex.enabled                               | No       | Enable Dex component                                                   |
| dex.version                               | Yes      | Dex [version](https://github.com/dexidp/dex/releases)                  |
| dex.replicaCount                          | Yes      |                                                                        |
| dex.serviceType                           | Yes      | ClusterIP/NodePort/LoadBalancer/ExternalName                           |
| dex.resources                             | No       |                                                                        |
| dex.properties.config                     | Yes      | Dex configuration file                                                 |
| dex.volumeMounts                          | No       |                                                                        |
| dex.volumes                               | No       |                                                                        |
| api.enabled                               | Yes      | true/false                                                             |
| api.version                               | Yes      | Terrakube API version                                                  |
| api.replicaCount                          | Yes      |                                                                        |
| api.serviceType                           | Yes      |                                                                        |
| api.properties.databaseType               | Yes      | H2/SQL_AZURE/POSTGRESQL/MYSQL                                          |
| api.properties.databaseHostname           | No       |                                                                        |
| api.properties.databaseName               | No       |                                                                        |
| api.properties.databaseUser               | No       |                                                                        |
| api.properties.databasePassword           | No       |                                                                        |
| executor.enabled                          | Yes      | true/false                                                             |
| executor.version                          | Yes      | Terrakube Executor version                                             |
| executor.replicaCount                     | Yes      |                                                                        |
| executor.serviceType                      | Yes      | ClusterIP/NodePort/LoadBalancer/ExternalName                           |
| executor.properties.toolsRepository       | Yes      | Example: https://github.com/AzBuilder/terrakube-extensions             |
| executor.properties.toolsBranch           | Yes      | Example: main                                                          |
| registry.enabled                          | Yes      |                                                                        |
| registry.version                          | Yes      |                                                                        |
| registry.replicaCount                     | Yes      |                                                                        |
| registry.serviceType                      | Yes      | ClusterIP/NodePort/LoadBalancer/ExternalName                           |
| ui.enabled                                | Yes      | true/false                                                             |
| ui.version                                | Yes      |                                                                        |
| ui.replicaCount                           | Yes      |                                                                        |
| ui.serviceType                            | Yes      | ClusterIP/NodePort/LoadBalancer/ExternalName                           |
| ingress.ui.useTls                         | Yes      | true/false                                                             |
| ingress.ui.enabled                        | Yes      | true/false                                                             |
| ingress.ui.domain                         | Yes      |                                                                        |
| ingress.ui.path                           | Yes      | ImplementationSpecific/Exact/Prefix                                    |
| ingress.ui.pathType                       | Yes      |                                                                        |
| ingress.ui.annotations                    | Yes      | Ingress annotations                                                    |
| ingress.api.useTls                        | Yes      |                                                                        |
| ingress.api.enabled                       | Yes      |                                                                        |
| ingress.api.domain                        | Yes      |                                                                        |
| ingress.api.path                          | Yes      |                                                                        |
| ingress.api.pathType                      | Yes      | ImplementationSpecific/Exact/Prefix                                    |
| ingress.api.annotations                   | Yes      | Ingress annotations                                                    |
| ingress.registry.useTls                   | Yes      |                                                                        |
| ingress.registry.enabled                  | Yes      |                                                                        |
| ingress.registry.domain                   | Yes      |                                                                        |
| ingress.registry.path                     | Yes      |                                                                        |
| ingress.registry.pathType                 | Yes      | ImplementationSpecific/Exact/Prefix                                    |
| ingress.registry.annotations              | Yes      | Ingress annotations                                                    |
| ingress.dex.enabled                       | Yes      |                                                                        |
| ingress.dex.domain                        | Yes      |                                                                        |
| ingress.dex.path                          | Yes      |                                                                        |
| ingress.dex.pathType                      | Yes      | ImplementationSpecific/Exact/Prefix                                    |
| ingress.dex.annontations                  | Yes      | Ingress annotations                                                    |


### 4.2 Node Affinity, NodeSelector, Taints and Tolerations.

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
