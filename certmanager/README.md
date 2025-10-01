# cert-manager

## install helm

```
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
```

or download from https://github.com/kubernetes/helm/releases

## install nginx ingress

C-M needs an ingress controller?
`k3s` might already have this covered.

The `controller.hostNetwork=True` means it will use the host's network for the port, so this will listen on the host 80 and 443.

```
helm install --name my-ingress stable/nginx-ingress \
--set controller.kind=DaemonSet \
--set controller.service.type=NodePort \
--set controller.hostNetwork=True
```

## deploy cert-manager

helm it

```
helm install \
  --name cert-manager \
  -namespace kube-system \
  stable/cert-manager
```

### setup an issuer


```yaml
---
apiVersion: certmanager.k8s.io/v1alpha1 ## check this
kind: Issuer
metadata:
  name: myapp-letsencrypt-staging
  namespace: default
spec: ## this is for letsencrypt :(
  acme:
    server: https://acme-staging.api.letsencrypt.org/directory
    email: my-email
    ## name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: myapp-letsencrypt-staging
    http01: {}
```

create th eissuer:

```text
kubectl create -f issuer-staging.yml
```

### Create a staging certificate

```yaml
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: myapp
  namespace: default
spec:
  secretName: myapp-tls-staging
  issueRef:
    name: myapp-letsencrypt-staging
  commonName: myapp.newtech.academy
  ## dnsNames:
  ## - www.myapp.newtech.academy
  acme:
    config:
    - http01:
        ingress: myapp
      domains:
      - myapp.newtech.academy
      - www.myapp.newtech.academy
```

Then deploy the ingress?
