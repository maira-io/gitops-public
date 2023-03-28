## Installing Kind

We can use https://kind.sigs.k8s.io/ to install Maira on local laptop.

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



## Clean up environment

You can delete kind cluster using the following command:

```
$ kind delete cluster
```
