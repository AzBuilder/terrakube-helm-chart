# Terrakube Helm Chart

This Helm chart deploys Terrakube on Kubernetes with support for multiple ingress controllers and cloud providers.

## Ingress Configuration

Terrakube supports three ingress controllers: `generic` (nginx), `aws` (ALB), and `gke` (Google Cloud Load Balancer).

### Generic Ingress (Default)

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

### AWS ALB Ingress

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

### GKE Ingress

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
| dex.enabled                               | No       | Enable Dex component                                                   |
| dex.*                                     | No       | Setup based on https://github.com/dexidp/helm-charts                   |
| minio.*                                   | No       | Setup based on https://github.com/bitnami/charts/tree/main/bitnami/minio    |
| postgres.*                                | No       | Setup based on https://github.com/bitnami/charts/tree/main/bitnami/postgres |
| redis.*                                   | No       | Setup based on https://github.com/bitnami/charts/tree/main/bitnami/redis    |
| api.enabled                               | Yes      | true/false                                                             |
| api.defaultRedis                          | No       | Enable default Redis using Bitnami helm chart                          |
| api.defaultDatabase                       | No       | Enable default database using postgresql helm chart                    |
| api.image                                 | No       | API image repository                                                   |
| api.version                               | Yes      | Terrakube API version                                                  |
| api.replicaCount                          | Yes      |                                                                        |
| api.serviceAccountName                    | No       | Kubernetes Service Account name                                        |
| api.serviceType                           | Yes      |                                                                        |
| api.env                                   | No       |                                                                        |
| api.volumes                               | No       |                                                                        |
| api.volumeMounts                          | No       |                                                                        |
| api.properties.databaseType               | Yes      | H2/SQL_AZURE/POSTGRESQL/MYSQL                                          |
| api.properties.databaseHostname           | No       |                                                                        |
| api.properties.databaseName               | No       |                                                                        |
| api.properties.databaseUser               | No       |                                                                        |
| api.properties.databasePassword           | No       |                                                                        |
| api.securityContext                       | No       | Fill securityContext field                                             |
| api.containerSecurityContext              | No       | Fill securityContext field in the container spec                       |
| api.imagePullSecrets                      | No       | Specific Secret used to pull images from private repository            |
| api.initContainers                        | No       | Init containers for API deployment                                     |
| executor.enabled                          | Yes      | true/false                                                             |
| executor.image                            | No       | Executor image repository                                              |
| executor.version                          | Yes      | Terrakube Executor version                                             |
| executor.replicaCount                     | Yes      |                                                                        |
| executor.serviceAccountName               | No       | Kubernetes Service Account name                                        |
| executor.serviceType                      | Yes      | ClusterIP/NodePort/LoadBalancer/ExternalName                           |
| executor.env                              | No       |                                                                        |
| executor.volumes                          | No       |                                                                        |
| executor.volumeMounts                     | No       |                                                                        |
| executor.properties.toolsRepository       | Yes      | Example: https://github.com/AzBuilder/terrakube-extensions             |
| executor.properties.toolsBranch           | Yes      | Example: main                                                          |
| executor.securityContext                  | No       | Fill securityContext field                                             |
| executor.containerSecurityContext         | No       | Fill securityContext field in the container spec                       |
| executor.imagePullSecrets                 | No       | Specific Secret used to pull images from private repository            |
| executor.initContainers                   | No       | Init containers for executor deployment                                |
| registry.enabled                          | Yes      |                                                                        |
| registry.image                            | No       | Registry image repository                                              |
| registry.version                          | Yes      |                                                                        |
| registry.replicaCount                     | Yes      |                                                                        |
| registry.serviceAccountName               | No       | Kubernetes Service Account name                                        |
| registry.serviceType                      | Yes      | ClusterIP/NodePort/LoadBalancer/ExternalName                           |
| registry.env                              | No       |                                                                        |
| registry.volumes                          | No       |                                                                        |
| registry.volumeMounts                     | No       |                                                                        |
| registry.securityContext                  | No       | Fill securityContext field                                             |
| registry.containerSecurityContext         | No       | Fill securityContext field in the container spec                       |
| registry.imagePullSecrets                 | No       | Specific Secret used to pull images from private repository            |
| registry.initContainers                   | No       | Init containers for registry deployment                                |
| ui.enabled                                | Yes      | true/false                                                             |
| ui.image                                  | No       | UI image repository                                                    |
| ui.version                                | Yes      |                                                                        |
| ui.replicaCount                           | Yes      |                                                                        |
| ui.serviceAccountName                     | No       | Kubernetes Service Account name                                        |
| ui.serviceType                            | Yes      | ClusterIP/NodePort/LoadBalancer/ExternalName                           |
| ui.securityContext                        | No       | Fill securityContext field                                             |
| ui.containerSecurityContext               | No       | Fill securityContext field in the container spec                       |
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
