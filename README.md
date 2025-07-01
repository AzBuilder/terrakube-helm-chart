# Terrakube Helm Chart

This Helm chart deploys Terrakube, an open-source Terraform management platform, on Kubernetes.

## Features

- **Multi-Cloud Ingress Support**: Generic, AWS ALB, and GKE ingress controllers
- **TLS/SSL Configuration**: Per-service TLS configuration with custom certificates
- **Google Cloud Integration**: GKE managed certificates, Cloud Armor, and BackendConfig support
- **AWS Integration**: ALB ingress with shared load balancer support
- **Authentication**: Dex OIDC integration with GitHub, Google, and other providers
- **Storage**: MinIO S3-compatible storage or external S3
- **Database**: PostgreSQL support with optional external database
- **Module Registry**: Private Terraform module registry
- **Workspace Management**: Terraform workspace execution and management

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Ingress controller (nginx, AWS Load Balancer Controller, or GKE ingress)

## Installation

### Basic Installation

```bash
helm repo add terrakube https://charts.terrakube.io
helm repo update
helm install terrakube terrakube/terrakube
```

### Ingress Configuration

Terrakube supports three ingress controllers: `generic` (nginx), `aws` (ALB), and `gke` (Google Cloud Load Balancer).

#### Generic Ingress (Default)

Uses standard Kubernetes ingress with nginx controller:

```yaml
ingress:
  controller: "generic"
  ui:
    enabled: true
    domain: "terrakube-ui.example.com"
    ingressClassName: "nginx"
  api:
    enabled: true
    domain: "terrakube-api.example.com"
    ingressClassName: "nginx"
  registry:
    enabled: true
    domain: "terrakube-registry.example.com"
    ingressClassName: "nginx"
  executor:
    enabled: false
```

#### AWS ALB Ingress

Uses AWS Application Load Balancer for ingress:

```yaml
ingress:
  controller: "aws"
  ui:
    enabled: true
    hostname: "terrakube-ui.example.com"
  api:
    enabled: true
    hostname: "terrakube-api.example.com"
  registry:
    enabled: true
    hostname: "terrakube-registry.example.com"
  executor:
    enabled: false
```

#### GKE Ingress

Uses Google Cloud Load Balancer for ingress:

```yaml
ingress:
  controller: "gke"
  ui:
    enabled: true
    hostname: "terrakube-ui.example.com"
  api:
    enabled: true
    hostname: "terrakube-api.example.com"
  registry:
    enabled: true
    hostname: "terrakube-registry.example.com"
  executor:
    enabled: false
```

## Helm Repository

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

  helm repo add terrakube-repo https://AzBuilder.github.io/terrakube-helm-chart

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
terrakube-repo` to see the charts.

To install the chart:

    kubectl create namespace terrakube
    helm install terrakube terrakube-repo/terrakube -n terrakube

To uninstall the chart:

    helm delete terrakube -n terrrakube

## Minikube

To quickly test Terrakube in Minikube please follow [this](https://docs.terrakube.io/getting-started/deployment/minikube)

## Advance Installation

To install Terrakube in a Kubernetes cluster you will need the following:

- Dex connector with support for the groups claim. For example:
  - [Azure Active Directory](https://dexidp.io/docs/connectors/microsoft/)
  - [Google Cloud Identity](https://dexidp.io/docs/connectors/google/)
  - [Github](https://dexidp.io/docs/connectors/github/)
  - [Gitlab](https://dexidp.io/docs/connectors/gitlab/)
- Azure Storage Account, Amazon S3 bucket, GCP Bucket and MinIO(Using AWS Endpoint)
- Supported database:
  - SQL Azure
  - PostgreSQL
  - Mysql
- Create a YAML file with all the require parameters.

## Installation

## Requirements.

Please make sure to have a kubernetes setup with some ingress setup completed for example Nginx Ingress, but any other kubernetes ingress should work.

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
        allowedOrigins: ['*']

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

### 2. Terrakube Admin Group and Internal Security

In order to use Terrakube you will have to define the one administrator group, for example:
- TERRAKUBE_ADMIN

Members of these groups are the only users inside terrakube that can create ***organizations*** and ***handle team access***

Example:

```
security:
  adminGroup: "TERRAKUBE_ADMIN"
  patSecret: "<<CHANGE_THIS>>"  # Sample Key 32 characters z6QHX!y@Nep2QDT!53vgH43^PjRXyC3X
  internalSecret: "<<CHANGE_THIS>>" # Sample Key 32 characters Kb^8cMerPNZV6hS!9!kcD*KuUPUBa^B3
```

> The patSecret and internalSecret should be a 32 character base64 compatible string.

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

#### 3.3 MinIO

Terrakube require an Storage bucket to save the state/output for the jobs and to save the terraform modules when using terraform CLI.

To create the MinIO Storage you can use the following [terraform module]() (Work in Progress).

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
- Github Authentication
  - [Ngnix Ingress + H2 Database + Azure Storage Account](examples/GithubAuthentication-Example1.md)
- Amazon AWS Cognito
  - [Ngnix Ingress + H2 Database + AWS S3 Bucket](examples/CognitoAuthentication-Example1.md)

### 4.1 Helm Value Properties

| Key                                       | Required | Description                                                            |
|:------------------------------------------|----------|------------------------------------------------------------------------|
| name                                      | Yes      | Use "Terrakube"                                                        |
| global.imagePullSecrets                   | No       | Global Secret used to pull images from private repository              |
| security.adminGroup                       | Yes      | Admin group inside Terrakube                                           |
| security.patSecret                        | Yes      | 32 Character secret to sign personal access token                      |
| security.internalSecret                   | Yes      | 32 Character secret to sing internal                                   |
| security.dexClientId                      | Yes      | Based on Dex config file                                               |
| security.dexClientScope                   | Yes      | Use "email openid profile offline_access groups"                       |
| security.gcpCredentials                   | No       | JSON Credentials for Google Identity Authentication                    |
| security.caCerts                          | No       | Custom CA certificates to be added at runtime                          |
| ingress.controller                        | Yes      | Ingress controller type: "generic", "aws", or "gke"                    |
| ingress.includeTlsHosts                   | No       | Include TLS hosts in ingress configuration (default: true)             |
| ingress.ui.enabled                        | Yes      | Enable UI ingress (default: true)                                      |
| ingress.ui.domain                         | Yes      | Domain name for UI service                                             |
| ingress.ui.path                           | Yes      | URL path for UI service (default: "/")                                 |
| ingress.ui.pathType                       | Yes      | Path matching type: "Prefix", "Exact", or "ImplementationSpecific"     |
| ingress.ui.ingressClassName               | No       | Ingress class name (e.g., "nginx", "gce")                             |
| ingress.ui.useTls                         | No       | Enable TLS/SSL for UI (default: false)                                |
| ingress.ui.tlsSecretName                  | No       | Kubernetes TLS secret name for UI certificates                         |
| ingress.ui.annotations                    | No       | Custom annotations for UI ingress                                       |
| ingress.api.enabled                       | Yes      | Enable API ingress (default: true)                                     |
| ingress.api.domain                        | Yes      | Domain name for API service                                            |
| ingress.api.path                          | Yes      | URL path for API service (default: "/")                                |
| ingress.api.pathType                      | Yes      | Path matching type: "Prefix", "Exact", or "ImplementationSpecific"     |
| ingress.api.ingressClassName              | No       | Ingress class name (e.g., "nginx", "gce")                             |
| ingress.api.useTls                        | No       | Enable TLS/SSL for API (default: false)                               |
| ingress.api.tlsSecretName                 | No       | Kubernetes TLS secret name for API certificates                        |
| ingress.api.annotations                   | No       | Custom annotations for API ingress                                      |
| ingress.registry.enabled                  | Yes      | Enable Registry ingress (default: true)                               |
| ingress.registry.domain                   | Yes      | Domain name for Registry service                                       |
| ingress.registry.path                     | Yes      | URL path for Registry service (default: "/")                           |
| ingress.registry.pathType                 | Yes      | Path matching type: "Prefix", "Exact", or "ImplementationSpecific"     |
| ingress.registry.ingressClassName         | No       | Ingress class name (e.g., "nginx", "gce")                             |
| ingress.registry.useTls                   | No       | Enable TLS/SSL for Registry (default: false)                          |
| ingress.registry.tlsSecretName            | No       | Kubernetes TLS secret name for Registry certificates                   |
| ingress.registry.annotations              | No       | Custom annotations for Registry ingress                                 |
| ingress.executor.enabled                  | No       | Enable Executor ingress (default: false, usually internal-only)        |
| ingress.executor.domain                   | No       | Domain name for Executor service                                       |
| ingress.executor.path                     | No       | URL path for Executor service (default: "/")                           |
| ingress.executor.pathType                 | No       | Path matching type: "Prefix", "Exact", or "ImplementationSpecific"     |
| ingress.executor.ingressClassName         | No       | Ingress class name (e.g., "nginx", "gce")                             |
| ingress.executor.useTls                   | No       | Enable TLS/SSL for Executor (default: false)                          |
| ingress.executor.tlsSecretName            | No       | Kubernetes TLS secret name for Executor certificates                   |
| ingress.executor.annotations              | No       | Custom annotations for Executor ingress                                 |
| ingress.dex.path                          | No       | URL path for Dex OIDC service (default: "/dex")                       |
| ingress.dex.pathType                      | No       | Path matching type for Dex service (default: "Prefix")                |
| ingress.aws.enabled                       | No       | Enable AWS ALB ingress features (default: false)                      |
| ingress.aws.certificateArn               | No       | AWS ACM certificate ARN for SSL termination                           |
| ingress.aws.sharedLoadBalancer.enabled   | No       | Use shared ALB across multiple ingresses (default: false)             |
| ingress.aws.sharedLoadBalancer.groupName | No       | ALB group name for shared load balancer                               |
| ingress.aws.annotations                   | No       | Global AWS ALB annotations applied to all ingresses                   |
| ingress.gke.enabled                       | No       | Enable GKE ingress features (default: false)                          |
| ingress.gke.managedCertificate.create     | No       | Create GCP managed SSL certificates (default: false)                  |
| ingress.gke.backendConfig.create          | No       | Create BackendConfig resources for health checks (default: false)     |
| ingress.gke.backendConfig.timeout         | No       | Backend timeout in seconds (default: 30)                              |
| ingress.gke.backendConfig.uiSecurityPolicy      | No       | Cloud Armor security policy for UI service (restrict user access)     |
| ingress.gke.backendConfig.apiSecurityPolicy     | No       | Cloud Armor security policy for API service (usually empty)           |
| ingress.gke.backendConfig.registrySecurityPolicy | No       | Cloud Armor security policy for Registry service (usually empty)      |
| ingress.gke.backendConfig.executorSecurityPolicy | No       | Cloud Armor security policy for Executor service (usually empty)      '
| ingress.gke.frontendConfig.create         | No       | Create FrontendConfig resources (default: false)                      |
| ingress.gke.externalDNS.proxyEnabled      | No       | Enable Cloudflare proxy for external-dns (default: "false")           |
| ingress.gke.externalDNS.perIngressProxy   | No       | Per-service Cloudflare proxy settings                                 |
| ingress.gke.annotations                   | No       | Global GKE annotations applied to all ingresses                       |
| ingress.gke.uiStaticIPName                | No       | GCP static IP name for UI service                                      |
| ingress.gke.apiStaticIPName               | No       | GCP static IP name for API service                                     |
| ingress.gke.registryStaticIPName          | No       | GCP static IP name for Registry service                                |
| ingress.gke.executorStaticIPName          | No       | GCP static IP name for Executor service                                |
| openldap.adminUser                        | Yes      | LDAP deployment admin user                                             |
| openldap.adminPass                        | Yes      | LDAP deployment admin password                                         |
| openldap.baseRoot                         | Yes      | LDAP baseDN (or suffix) of the LDAP tree                               |
| openldap.image                            | Yes      | LDAP deployment image repository                                       |
| openldap.version                          | Yes      | LDAP deployment image tag                                              |
| openldap.imagePullSecrets                 | No       | Secret used to pull images from private repository                     |
| openldap.initContainers                   | No       | Init containers for LDAP deployment                                    |
| openldap.podLabels                        | No       | Pod labels for LDAP deployment                                         |
| openldap.securityContext                  | No       | Security context for LDAP deployment                                   |
| openldap.containerSecurityContext         | No       | Container security context for LDAP deployment                         |
| storage.defaultStorage                    | No       | Enable default storage using minio helm chart                          |
| storage.gcp.projectId                     | No       | GCP Project Id for the storage                                         |
| storage.gcp.bucketName                    | No       | GCP Bucket name for the storage                                        |
| storage.gcp.credentials                   | No       | GCP JSON Credentials for the storage                                   |
| storage.azure.storageAccountName          | No       | Azure storage account name                                             |
| storage.azure.storageAccountResourceGroup | No       | Azure storage resource group                                           |
| storage.azure.storageAccountAccessKey     | No       | Azure storage access key                                               |
| storage.aws.accessKey                     | No       | Aws access key                                                         |
| storage.aws.secretKey                     | No       | Aws secret key                                                         |
| storage.aws.bucketName                    | No       | Aws bucket name                                                        |
| storage.aws.region                        | No       | Aws region name (Example: us-east-1)                                   |
| storage.aws.endpoint                      | No       | Setup custom endpoint (MinIO)                                          |
| dex.enabled                               | No       | Enable Dex OIDC authentication component                              |
| dex.*                                     | No       | Setup based on https://github.com/dexidp/helm-charts                   |
| minio.*                                   | No       | Setup based on https://github.com/bitnami/charts/tree/main/bitnami/minio    |
| postgres.*                                | No       | Setup based on https://github.com/bitnami/charts/tree/main/bitnami/postgres |
| redis.*                                   | No       | Setup based on https://github.com/bitnami/charts/tree/main/bitnami/redis    |
| api.enabled                               | Yes      | Enable API component deployment                                        |
| api.defaultRedis                          | No       | Enable default Redis using Bitnami helm chart                          |
| api.defaultDatabase                       | No       | Enable default database using postgresql helm chart                    |
| api.image                                 | No       | API image repository                                                   |
| api.version                               | Yes      | Terrakube API version                                                  |
| api.replicaCount                          | Yes      | Number of API pod replicas                                             |
| api.serviceAccountName                    | No       | Kubernetes Service Account name                                        |
| api.serviceType                           | Yes      | Kubernetes service type (ClusterIP/NodePort/LoadBalancer)             |
| api.env                                   | No       | Environment variables for API pods                                     |
| api.volumes                               | No       | Volume mounts for API pods                                             |
| api.volumeMounts                          | No       | Volume mount points for API pods                                       |
| api.properties.databaseType               | Yes      | Database type: H2/SQL_AZURE/POSTGRESQL/MYSQL                          |
| api.properties.databaseHostname           | No       | External database hostname                                             |
| api.properties.databaseName               | No       | External database name                                                 |
| api.properties.databaseUser               | No       | External database username                                             |
| api.properties.databasePassword           | No       | External database password                                             |
| api.securityContext                       | No       | Pod security context for API                                           |
| api.containerSecurityContext              | No       | Container security context for API                                     |
| api.imagePullSecrets                      | No       | Specific Secret used to pull images from private repository            |
| api.initContainers                        | No       | Init containers for API deployment                                     |
| executor.enabled                          | Yes      | Enable Executor component deployment                                   |
| executor.image                            | No       | Executor image repository                                              |
| executor.version                          | Yes      | Terrakube Executor version                                             |
| executor.replicaCount                     | Yes      | Number of Executor pod replicas                                        |
| executor.serviceAccountName               | No       | Kubernetes Service Account name                                        |
| executor.serviceType                      | Yes      | Kubernetes service type (ClusterIP/NodePort/LoadBalancer)             |
| executor.env                              | No       | Environment variables for Executor pods                                |
| executor.volumes                          | No       | Volume mounts for Executor pods                                        |
| executor.volumeMounts                     | No       | Volume mount points for Executor pods                                  |
| executor.properties.toolsRepository       | Yes      | Git repository for Terraform tools (e.g., GitHub extensions repo)     |
| executor.properties.toolsBranch           | Yes      | Git branch for tools repository (typically "main")                    |
| executor.securityContext                  | No       | Pod security context for Executor                                     |
| executor.containerSecurityContext         | No       | Container security context for Executor                               |
| executor.imagePullSecrets                 | No       | Specific Secret used to pull images from private repository            |
| executor.initContainers                   | No       | Init containers for executor deployment                                |
| registry.enabled                          | Yes      | Enable Registry component deployment                                   |
| registry.image                            | No       | Registry image repository                                              |
| registry.version                          | Yes      | Terrakube Registry version                                             |
| registry.replicaCount                     | Yes      | Number of Registry pod replicas                                        |
| registry.serviceAccountName               | No       | Kubernetes Service Account name                                        |
| registry.serviceType                      | Yes      | Kubernetes service type (ClusterIP/NodePort/LoadBalancer)             |
| registry.env                              | No       | Environment variables for Registry pods                                |
| registry.volumes                          | No       | Volume mounts for Registry pods                                        |
| registry.volumeMounts                     | No       | Volume mount points for Registry pods                                  |
| registry.securityContext                  | No       | Pod security context for Registry                                     |
| registry.containerSecurityContext         | No       | Container security context for Registry                               |
| registry.imagePullSecrets                 | No       | Specific Secret used to pull images from private repository            |
| registry.initContainers                   | No       | Init containers for registry deployment                                |
| ui.enabled                                | Yes      | Enable UI component deployment                                         |
| ui.image                                  | No       | UI image repository                                                    |
| ui.version                                | Yes      | Terrakube UI version                                                   |
| ui.replicaCount                           | Yes      | Number of UI pod replicas                                              |
| ui.serviceAccountName                     | No       | Kubernetes Service Account name                                        |
| ui.serviceType                            | Yes      | Kubernetes service type (ClusterIP/NodePort/LoadBalancer)             |
| ui.securityContext                        | No       | Pod security context for UI                                           |
| ui.containerSecurityContext               | No       | Container security context for UI                                     |
| ui.imagePullSecrets                       | No       | Specific Secret used to pull images from private repository            |
| ui.initContainers                         | No       | Init containers for UI deployment                                      |
| ingress.ui.ingressClassName               | Yes      | Default is set to nginx                                                |
| ingress.ui.useTls                         | Yes      | true/false                                                             |
| ingress.ui.enabled                        | Yes      | true/false                                                             |
| ingress.ui.domain                         | Yes      |                                                                        |
| ingress.ui.path                           | Yes      | ImplementationSpecific/Exact/Prefix                                    |
| ingress.ui.pathType                       | Yes      |                                                                        |
| ingress.ui.annotations                    | Yes      | Ingress annotations                                                    |
| ingress.api.ingressClassName              | Yes      | Default is set to nginx                                                |
| ingress.api.useTls                        | Yes      |                                                                        |
| ingress.api.enabled                       | Yes      |                                                                        |
| ingress.api.domain                        | Yes      |                                                                        |
| ingress.api.path                          | Yes      |                                                                        |
| ingress.api.pathType                      | Yes      | ImplementationSpecific/Exact/Prefix                                    |
| ingress.api.annotations                   | Yes      | Ingress annotations                                                    |
| ingress.registry.ingressClassName         | Yes      | Default is set to nginx                                                |
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


#### Per-Service Security Policies

You can apply Cloud Armor security policies to individual services:

```yaml
ingress:
  controller: "gke"
  gke:
    enabled: true
    backendConfig:
      create: true
      timeout: 30
      # Only restrict UI access - keep APIs open for external agents
      uiSecurityPolicy: "terrakube-ui-security-policy"
      # apiSecurityPolicy: ""          # Empty - external agents need access
      # registrySecurityPolicy: ""     # Empty - module downloads need access
```

### 4.2 Node Affinity, NodeSelector, Taints and Tolerations.

The API, Registry, Executor and UI support using affinity, taints and tolerations. Use the following examples as reference:

#### Example API.

```yaml
api:
  enabled: true
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

### 5. Custom CA certificates at runtime

To add custom CA certificate to Terrakube components use the folowing configuration example:

Example property ***security.caCerts***

```
security:
  .....
  caCerts:
    terrakubeDemo1.pem: |
      -----BEGIN CERTIFICATE-----

      CERTIFICATE DATA

      -----END CERTIFICATE-----
    terrakubeDemo2.pem: |
      -----BEGIN CERTIFICATE-----

      CERTIFICATE DATA

      -----END CERTIFICATE-----
  ....
```

Terrakube components configuration with custom CA certificates:

```yaml
## API properties
api:
  enabled: true
  replicaCount: "1"
  serviceType: "ClusterIP"
  env:
  - name: SERVICE_BINDING_ROOT
    value: /mnt/platform/bindings
  volumes:
    - name: ca-certs
      secret:
        secretName: terrakube-ca-secrets
        items:
        - key: "terrakubeDemo1.pem"
          path: "terrakubeDemo1.pem"
        - key: "terrakubeDemo2.pem"
          path: "terrakubeDemo2.pem"
        - key: "type"
          path: "type"
  volumeMounts:
  - name: ca-certs
    mountPath: /mnt/platform/bindings/ca-certificates
    readOnly: true
  properties:
    databaseType: "H2"


## Executor properties
executor:
  enabled: true
  replicaCount: "1"
  serviceType: "ClusterIP"
  env:
  - name: SERVICE_BINDING_ROOT
    value: /mnt/platform/bindings
  volumes:
    - name: ca-certs
      secret:
        secretName: terrakube-ca-secrets
        items:
        - key: "terrakubeDemo1.pem"
          path: "terrakubeDemo1.pem"
        - key: "terrakubeDemo2.pem"
          path: "terrakubeDemo2.pem"
        - key: "type"
          path: "type"
  volumeMounts:
  - name: ca-certs
    mountPath: /mnt/platform/bindings/ca-certificates
    readOnly: true
  properties:
    toolsRepository: "https://github.com/AzBuilder/terrakube-extensions"
    toolsBranch: "main"

## Registry properties
registry:
  enabled: true
  replicaCount: "1"
  serviceType: "ClusterIP"
  env:
  - name: SERVICE_BINDING_ROOT
    value: /mnt/platform/bindings
  volumes:
    - name: ca-certs
      secret:
        secretName: terrakube-ca-secrets
        items:
        - key: "terrakubeDemo1.pem"
          path: "terrakubeDemo1.pem"
        - key: "terrakubeDemo2.pem"
          path: "terrakubeDemo2.pem"
        - key: "type"
          path: "type"
  volumeMounts:
  - name: ca-certs
    mountPath: /mnt/platform/bindings/ca-certificates
    readOnly: true
```

If the configuration is correct the pods log will show something like this:

```
Added 2 additional CA certificate(s) to system truststore
```


### 6. Enable OTEL for Terrakube components
To enable OTEL for Terrakube components use the following configuration example:

```yaml
## API properties
api:
  enabled: true
  replicaCount: "1"
  serviceType: "ClusterIP"
  otel:
    enabled: true
    metrics:
      port: 8081
      host: 
    traces:
      type: jaeger # or zipkin
      endpoint: http://jaeger-collector:14268/api/traces


## Executor properties
executor:
  enabled: true
  replicaCount: "1"
  serviceType: "ClusterIP"
  otel:
    enabled: true
    metrics:
      port: 8081
      host: 
    traces:
      type: zupkin # or jaeger
      endpoint: zipkin:9411/api/v2/spans

## Registry properties
registry:
  enabled: true
  replicaCount: "1"
  serviceType: "ClusterIP"
  otel:
    enabled: false # or true
    metrics:
      port: 8081
      host: 
    traces:
      type: zupkin # or jaeger
      endpoint: zipkin:9411/api/v2/spans
```

### 7. Deploy Terrakube using helm chart manually

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
helm install --debug --dry-run --values ./values.yaml terrakube ./terrakube-helm-chart/charts/terrakube/ -n terrakube
```
Running the helm chart.
```bash
helm install --debug --values ./values.yaml terrakube ./terrakube-helm-chart/charts/terrakube/ -n terrakube
```

After installing you should be able to view the app using ui domain inside the values.yaml.
