# acme

I had originally planned on using the gandi webhook, but I had questions the documentation didn't answer.
I'm sure if I knew more about it all it would be obvious, but I'd rather move on than fuck with it now.

## cloudflare

I'm not a huge fan of the company, but it seemed the easiest at the moment.
I'll reconsider using it later.

### api key

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token-secret
type: Opaque
stringData:
  api-token: APITOKEN
```

### issuer

```yaml
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: hids-one-issuer
spec:
  acme:
    solvers:
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token-secret
            key: api-token
```

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
