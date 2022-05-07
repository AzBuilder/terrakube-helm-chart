# Terrakube Helm Chart

## Requirements

To install Terrakube in a Kubernetes cluster you will need the following:

- Azure Active Directory
- Azure Storage Account
- Supported database:
  - SQL Azure
  - PostgreSQL
  - Mysql
- Create a YAML file with all the require parameters.

## Instalation

### 1. Azure Active Directory Registration

In order to use Terrakube we need to register the application inside Azure Active Directory, to do this use the following Terraform module using the example name "Terrakube":

```bash
git clone https://github.com/AzBuilder/terraform-azurerm-terrakube-app-registration.git
terraform apply --var "app_name=Terrakube"
```

The terraform module will create three applications inside Azure Active Directory:
- Terrakube Base
- Terrakube APP
- Terrakube CLI

Inside ***Terrakube App*** you can get the following information:
- Azure app Client Id
- Azure app Tenant Id 
- Azure app Secret

Inside ***Terrakube Base*** you can get the following information:
- Azure app API Scope

> If you use ***app_name=Terrakube*** the API Scope will be ***api://Terrakube***

### 2. Terrakube Admin Group

In order to use Terrakube the following Azure Active Directory Group should be created:
- TERRAKUBE_ADMIN

Once the group it is created we will need to include ***Terrakube APP*** as a member.

> ***TERRAKUBE_ADMIN*** group members are the only users inside the app that can create ***organization*** and ***teams***

### 3. Terrakube Storage

#### 3.1 Azure Storage Account

Terrakube require an Azure Storage account to save the state/output for the jobs and to save the terraform modules when using terraform CLI and it require the following containers:
- registry (blob)
- tfstate (private)
- tfoutput (private)

To create the Azure storage account you can use the following [terraform module](https://github.com/AzBuilder/terraform-azurerm-terrakube-cloud-storage).

#### 3.2 AWS S3

Terrakube require an Aws S3 to save the state/output for the jobs and to save the terraform modules when using terraform CLI and it require the following:
- Cors Enable for the UI domain
- ACL Enable

To create the Aws S3 you can use the following [terraform module]() (Work in Progress).

### 4. Build Yaml file

Once you have completed the above steps you can complete the file values.yaml to deploy the helm chart

***Example using Nginx Ingress and Azure Storage Account:***

```yaml
## Global Name
name: "terrakube"

## Azure Active Directory Security
security:
  type: "AZURE" # This is the only value supported righ now
  azure:
    appIdURI: "XXX" #Replace with values from Step 1
    appClientId: "XXX"
    appTenantId: "XXX"
    appSecret: "XXX"

## Terraform Storage
storage:
  azure:
    storageAccountName: "XXX" #Replace with values from Step 3
    storageAccountResourceGroup: "XXX"
    storageAccountAccessKey: "XXX"

## API properties
api:
  enabled: true
  version: "2.2.0"
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
  version: "1.6.1"
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
  version: "2.2.0"
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
  version: "0.7.0"
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

***Example using Nginx Ingress and AWS S3:***
```yaml
## Global Name
name: "terrakube"

## Azure Active Directory Security
security:
  type: "AZURE" # This is the only value supported righ now
  azure:
    appIdURI: "XXX" #Replace with values from Step 1
    appClientId: "XXX"
    appTenantId: "XXX"
    appSecret: "XXX"

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
  version: "2.2.0"
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
  version: "1.6.1"
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
  version: "2.2.0"
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
  version: "0.7.0"
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

### 5. Deploy Terrakube using helm chart

Now you have all the information to deploy Terrakube, you can use the following example:

Clone the helm chart repository and fill the values.yaml file
```bash
git clone https://github.com/AzBuilder/terrakube-heml-chart.git
```
Create the kubernetes namespace:
```bash
kubectl create namespace terrakube
```
Test the helm chart before installing:
```bash
helm install --dry-run --debug --values ./values.yaml terrakube ./terrakube-heml-chart/ -n terrakube
```
Running the helm chart.
```bash
helm install --debug --values ./values.yaml terrakube ./terrakube-heml-chart/ -n terrakube
```

After installing you should be able to view the app using ui domain inside the values.yaml. 

Example: 

https://ui.terrakube.docker.internal
