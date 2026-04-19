# acme


## gandi webhook

### helm instructions

The `gandi.yml` file should be a basic yaml file with the following template:

```yaml
---
gandiPat: PERSONAL ACCESS TOKEN
````

Commands to install:


```
## add the repo
helm repo add cert-manager-webhook-gandi https://sintef.github.io/cert-manager-webhook-gandi

## install the chart
helm install -f gandiPat=gandi.yml cert-manager-webhook-gandi cert-manager-webhook-gandi/cert-manager-webhook-gandi
