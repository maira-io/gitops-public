# Installation

Prefered option is using minikube since it allows to do port forwarding on mac os.

## Using Kind

We use https://kind.sigs.k8s.io/ instead of minikube to run tests on local laptop.

```
$ go install sigs.k8s.io/kind@v0.17.0
go: downloading sigs.k8s.io/kind v0.17.0
go: downloading github.com/spf13/cobra v1.4.0
go: downloading github.com/alessio/shellescape v1.4.1
go: downloading github.com/pelletier/go-toml v1.9.4
go: downloading github.com/evanphx/json-patch/v5 v5.6.0
go: downloading github.com/google/safetext v0.0.0-20220905092116-b49f7bc46da2
go install sigs.k8s.io/kind@v0.17.0

$ kind create cluster
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.25.3) 🖼
⢎⡰ Preparing nodes 📦  ^R
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/
```

Kubernetes should be running

## Using Minikube

```
$ kubectl get node
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   56s   v1.25.3
```

```
brew install virtualbox minikube
```

```
minikube start
j.pavlik@C02FN35KMD6R:~$ minikube start
😄  minikube v1.25.2 on Darwin 12.6.2
✨  Using the hyperkit driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
🔄  Restarting existing hyperkit VM for "minikube" ...
🐳  Preparing Kubernetes v1.23.3 on Docker 20.10.12 ...
    ▪ kubelet.housekeeping-interval=5m
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass

❗  /usr/local/bin/kubectl is version 1.25.2, which may have incompatibilites with Kubernetes 1.23.3.
    ▪ Want kubectl v1.23.3? Try 'minikube kubectl -- get pods -A'
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

```
$ k get node
NAME       STATUS   ROLES                  AGE   VERSION
minikube   Ready    control-plane,master   22h   v1.23.3
```

## Application installation

1) Modify Maira configuration in `maira/maira.yml` to set default tenant and admin user email.

```
        ui:
          env:
          - name:  BASE_URL
            value: https://localhost:8000/v1
          - name:  DOMAIN
            value: maira-demo.us.auth0.com
          - name:  CLIENT_ID
            value: mtLWusyXtPIm98r7Mo2E601YKlTfhFOM
          - name: audience
            value: https://api.maira-demo.maira.io
        api:
          auth0_tenant: maira-demo
          default_tenant: maira.io
          admin_user_email: sbansal@maira.io
```

2) Now execute install.sh script, which generates secrets and bootstrap argocd with all helm charts

```
$ ./install.sh
namespace/maira created
namespace/argocd created
Generating a 2048 bit RSA private key
........................................................+++++
..............+++++
writing new private key to 'tls.key'
-----
secret/maira-tls-secret created
secret/maira-gitops-repo created
secret/maira-helm-chart-repo created
secret/macro-context-293714 created
secret/maira-db-uri-secret created
secret/temporal-default-store created
"argo" already exists with the same configuration, skipping
Release "argocd" does not exist. Installing it now.
NAME: argocd
LAST DEPLOYED: Wed Mar  8 12:18:32 2023
NAMESPACE: argocd
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
In order to access the server UI you have the following options:

1. kubectl port-forward service/argocd-server -n argocd 8080:443

    and then open the browser on http://localhost:8080 and accept the certificate

2. enable ingress in the values file `server.ingress.enabled` and either
      - Add the annotation for ssl passthrough: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#option-1-ssl-passthrough
      - Set the `configs.params."server.insecure"` in the values file and terminate SSL at your ingress: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#option-2-multiple-ingress-objects-and-hosts


After reaching the UI the first time you can login with username: admin and the random password generated during the installation. You can find the password by running:

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

(You should delete the initial secret afterwards as suggested by the Getting Started Guide: https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli)
deployment.apps/argocd-server condition met
ArcoCD username admin and password: ksd7M1d-Vu2F2dbf
Apply apps into Argo CD
application.argoproj.io/apps configured
Wait for for databases
temporal-worker-5bc7fbdbd8-rvc5l       1/1     Running   0              3m14s
pod/temporal-worker-5bc7fbdbd8-rvc5l condition met
waiting for temporal-worker to get created
NAME                                   READY   STATUS            RESTARTS   AGE
cassandra-0                            1/1     Running           0          8m10s
maira-api-b987654f8-lcrq5              1/1     Running           0          2m58s
maira-cloud-worker-85ccd95b8c-nj7td    0/1     PodInitializing   0          2m58s
maira-sitemanager-b786674b7-ztfbh      1/1     Running           0          2m58s
maira-ui-6f77d87b9-2c58k               1/1     Running           0          2m58s
mongodb-8597475bdd-tncdm               0/1     Running           0          8m9s
temporal-admintools-6f74f59b7f-jq8fb   1/1     Running           0          3m43s
temporal-frontend-554b78785d-k4qxb     1/1     Running           0          3m43s
temporal-history-7d69954555-qfqjj      1/1     Running           0          3m43s
temporal-matching-686ccdd745-hmrkk     1/1     Running           0          3m43s
temporal-web-649f7dcc66-nm5tr          1/1     Running           0          3m43s
temporal-worker-5bc7fbdbd8-5p8fq       1/1     Running           0          3m43s
maira-cloud-worker-85ccd95b8c-nj7td    1/1     Running           0          3m3s
Maira is ready
```

It can take between 10-15 minutes based image pull time.
In case of issues, port forward to access argocd on localhost:8080 use `admin` and password from the command bellow.

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
kubectl port-forward service/argocd-server -n argocd 8080:443
```

## Clean up the environment

Destroy minikube by the following command.

```
$ minikube delete
```