## Secret Files

All files included in this directory will be inside the kubernetes secret ***terrakube-secret-files***. Kubernetes has a secret size limit of 1MB.

> This is useful when we need to upload some extra files to the helm chart, for example [gcp-credentials.json for GCP authentication](https://dexidp.io/docs/connectors/google/#fetching-groups-from-google)