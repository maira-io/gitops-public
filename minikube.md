## Installing Minikube

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

## Clean up the environment

Destroy minikube by the following command.

```
$ minikube delete
```
