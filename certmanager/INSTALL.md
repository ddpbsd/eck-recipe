# install cert-manager

taken from medium.com/geekculture/a-simple-ca-setup-with-kubernetes-cert-manager-bc8ccbd9c2

> [!NOTE]
> I installed metallb before this ;)

## add the helm repo

```text
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

## install cert-manager

```text
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.18.2 \
  --set installCRDs=true
```

## create ca

```yaml
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: self-signed-issuer
  namespace: cert-manager
spec:
  selfSigned: {}
```

### create a cert

```yaml
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: init-ca
  namespace: cert-manager
spec:
  isCA: true
  commonName: init-ca
  subject:
    organizations:
      - wafflelab
    organizationalUnits:
      - k8s
  secretName: init-ca-secret
  privateKey:
    algorithm: ECDSA
    size: 256
    rotationPolicy: Always
  issuerRef:
    name: selfsigned-issuer
    kind: Issuer
    group: cert-manager.io
```

This will fail. Tracking it down with these commands:

```text
kubectl get certificate -n cert-manager
kubectl get issuer -n cert-manager
kubectl describe certificate init-ca -n cert-manager
```

And possibly others.
Turns out my Issuer (`selfsigned-issuer`) does not exist, it should be `self-signed-issuer`.
Oops.

Now I get the correct secrets:

```text
[ddp@geidi cert-manager]$ kubectl get secret -n cert-manager
NAME                                 TYPE                 DATA   AGE
cert-manager-webhook-ca              Opaque               3      32m
init-ca-secret                       kubernetes.io/tls    3      2m22s
sh.helm.release.v1.cert-manager.v1   helm.sh/release.v1   1      32m
```

### create the correct ca cert

What I created above isn't the right thing exactly, so let's fix that.

```yaml
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wafflelab-ca
  namespace: cert-manager
spec:
  isCA: true
  commonName: wafflelab-ca
  subject:
    organizations:
      - wafflelab
    organizationalUnits:
      - k8s
  secretName: wafflelab-ca-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: self-signed-issuer
    kind: Issuer
    group: cert-manager.io
```

## create ca issuer

Making a `ClusterIssuer` so this can give out certs in more namespaces.

```yaml
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: wafflelab-ca
  namespace: cert-manager
spec:
  ca:
    secretName: wafflelab-ca-secret
```

## test it out

verify the server cert with the CA cert:

```text
openssl verify -CAfile <(kubectl -n cert-manager get secret wafflelab-ca-secret  -o jsonpath='{.data.ca\.crt}' | base64 -d) <(kubectl -n test get secret test-server-tls -o jsonpath='{.data.tls\.crt}' | base64 -d)
```

### test client and server

#### server

```text
echo 'hello world' > test.txt
openssl s_server -cert <(kubectl -n test get secret test-server-tls -o jsonpath='{.data.tls\.crt}' | base64 -d) -key <(kubectl -n test get secret test-server-tls -o jsonpath='{.data.tls\.key}' | base64 -d) -CAfile <(kubectl -n cert-manager get secret wafflelab-ca-secret  -o jsonpath='{.data.ca\.crt}' | base64 -d) -WWW -port 12345 -verify_return_error -Verify 1
```

#### client

```text
echo -e 'GET /test.txt HTTP/1.1\r\n\r\n' | openssl s_client -cert <(kubectl -n test get secret test-client-tls -o jsonpath='{.data.tls\.crt}' | base64 -d) -key <(kubectl -n test get secret test-client-tls -o jsonpath='{.data.tls\.key}' | base64 -d) -CAfile <(kubectl -n cert-manager get secret wafflelab-ca-secret  -o jsonpath='{.data.ca\.crt}' | base64 -d) -connect localhost:12345 -quiet
```

## echo server



