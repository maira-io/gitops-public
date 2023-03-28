# Installation

By following instructions below you can deployment Maira on any k8s cluster. If you are installing on your laptop, you can use kind or minikube. For a company-wide installtion, you can install it on k8s cluster on public cloud (e.g. Google GKE or Amazon EKS or Azure AKS)

For laptop based deployment, install kind or minikube using instructions below.
[Install kind](kind.md)

[Install minikube](minikube.md)

For cloud based deployment, make sure credentials to access your cloud based k8s cluster are in your kubeconfig file. 


## Application installation

1) Modify Maira configuration in `maira/maira.yml` to set default tenant and admin user email. Admin user email should be your work email address and default tenant should be the domain name for your company (e.g. maira.io)

```
        api:
          ...
          default_tenant: maira.io
          admin_user_email: sbansal@maira.io
          slack:
            bot_server: "localhost:3000"
            socket_mode: true
            slack_app_token: ""
            slack_bot_token: ""
            log_level: info
```

For slack to work, you need the app token and bot token as explained [here](https://docs.maira.io/integrations/docs/slack/#on-prem-deployment)

Note: bot_server is the DNS address of where Maira will be accessible after it is deployed. For laptop based deployment, leave it as `localhost:3000`. For cloud-based deployment, you will need to configure a DNS address where maira can be accessed (e.g. maira.example.com)

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

3) If you are using cloud-based deployment, you should be able to access maira by pointing your browser to the public IP address allocated to Maira.

If you are using laptop-based deployment, port-forward Maira's nginx based loadbalancer to local port 3000

```
$ kubectl -n ingress port-forward services/ingress-ingress-nginx-controller 3000:443
```

After this, you can access Maira on https://localhost:3000
