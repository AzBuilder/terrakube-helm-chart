# Terrakube Helm Chart

## Requirements

To install Terrakube in a Kubernetes cluster you will need the following:

- Azure Active Directory
- Azure Storage Account with the followings containers:
  - registry (blob)
  - tfstate (private)
  - tfoutput (private)
- Supported databases:
  - SQL Azure
  - PostgreSQL
  - Mysql
- Create a YAML file with all the parameters.

Example: 

```yaml
name: "terrakube-sample"
databaseType: "SQL_AZURE" 
securityType: "AZURE"

azureAppClientId: "XXX"
azureAppTenantId: "XXX"
azureAppSecret: "XXX"

datasourceHostname: "XXX.database.windows.net"
datasourceDatabase: "XXX"
datasourceUser: "XXX"
datasourcePassword: "XXX"

apiDomain: "XXX"
apiPath: "XXX"

apiVersion: "2.0.0"
registryVersion: "2.0.0"
executorVersion: "1.5.3 "

registryDomain: "XXX"

terraformStateType: "AzureTerraformStateImpl"
terraformOutputType: "AzureTerraformOutputImpl"

azureStorageAccountResourceGroup: "XXX"
azureStorageAccountName: "XXX"
azureStorageAccountAccessKey: "XXX"

```

## Instalation

```bash
git clone https://github.com/AzBuilder/terrakube-heml-chart.git
helm install --debug --values .\sample-values.yaml terrakube .\terrakube-heml-chart\
```
