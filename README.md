[![Build status](https://badge.buildkite.com/994055227611f9339ad651c5944fafe950d2fbbd1491df321d.svg)](https://buildkite.com/zaffarano/argocd-sandbox)
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/szaffarano/argocd-sandbox)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/szaffarano/argocd-sandbox/latest)

# ArgoCD POC

CI/CD pipeline POC using
- [argocd](https://argo-cd.readthedocs.io/en/stable/)
- [buildkite](https://buildkite.com/)
- [Kubernetes](https://kubernetes.io/), [minikube](https://minikube.sigs.k8s.io/docs/start/)

## Environment setup

1. [Install](https://minikube.sigs.k8s.io/docs/start/) minikube and create a testing environment with nginx ingress support

```bash
minikube start
minikube addons enable ingress
```

2. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
3. Patch the ingress by adding `--enable-ssl-passthrough` to the container args:

```bash
kubectl edit deployments.apps -n ingress-nginx ingress-nginx-controller

```

For instance:

```yaml
      containers:
      - args:
        - /nginx-ingress-controller
        - --election-id=ingress-nginx-leader
        - --controller-class=k8s.io/ingress-nginx
        - --watch-ingress-without-class=true
        - --configmap=$(POD_NAMESPACE)/ingress-nginx-controller
        - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
        - --udp-services-configmap=$(POD_NAMESPACE)/udp-services
        - --validating-webhook=:8443
        - --validating-webhook-certificate=/usr/local/certificates/cert
        - --validating-webhook-key=/usr/local/certificates/key
        - --enable-ssl-passthrough
```

4. Create argocd Ingress

```bash
kubectl apply -f infra/argocd/ingress.yaml -n argocd
```

In order to access the argocd web app or use the CLI, as well as for the examples to work, you have to include `argocd.local` in your `/etc/hosts` (also `production.local` and `staging.local` are needed to test the environments managed by CI/CD)


```bash
cat /etc/hosts
...
192.168.49.2 argocd.local staging.local production.local
```
Check the IP address running

```bash
kubectl get ingress -n argocd
```

(Do the same once the [staging/production](./infra/k8s/base/ingress.yaml) ingress are created by ArgoCD or manually)

5. Login and change the password

```bash
argocd admin initial-password -n argocd
argocd login argocd.local
argocd account update-password
```

6. Install image updater

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
```

6. Create staging and production namespaces

```
k create namespace production
k create namespace staging
```

6. Create the argocd apps

```
k apply -f infra/argocd/apps/staging.yaml
k apply -f infra/argocd/apps/production.yaml
```

After a while both staging and production namespaces should have been deployed.  You can test them using `curl`

``` bash
curl staging.local/version
{"Version":"dev-59e8506","Commit":"59e8506"}

curl production.local/version
{"Version":"v0.1.7","Commit":"9292973"}
```
