#!/bin/bash

# Generate password for all services
PASSWORD=${PASSWORD:-$(openssl rand -base64 8 | md5)}
API_KEY=${API_KEY:-$(openssl rand -base64 8 | md5)}

if ! command -v gpg &> /dev/null
then
    echo "gpg was not found. Please install or add to path and retry"
    exit
fi

if ! command -v helm &> /dev/null
then
    echo "helm was not found. Please install or add to path and retry"
    exit
fi

if ! command -v kubectl &> /dev/null
then
    echo "kubectl was not found. Please install or add to path and retry"
    exit
fi

kubectl create ns maira
kubectl create ns argocd
# create key and cert for maira.local
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=*.localdev.me" -addext "subjectAltName = DNS:*.localdev.me"
kubectl create -n maira secret tls maira-tls-secret --cert=tls.crt --key=tls.key

# set API key for maira
sed -i "s/<generated key>/$API_KEY/g" maira/maira.yml
sed -i "s/<generated key>/$API_KEY/g" maira/maira-gateway.yml

kubectl create -n maira secret generic maira-db-uri-secret --from-literal=db_uri="mongodb://root:$PASSWORD@mongodb.maira:27017/?authSource=admin"
kubectl create -n maira secret generic temporal-default-store --from-literal=cassandra-password="$PASSWORD" \
    --from-literal=mongodb-root-password="$PASSWORD" \
    --from-literal=password="$PASSWORD"

# bootstrap argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install --create-namespace --version 5.24.3 --values argocd/values.yml --namespace argocd argocd argo/argo-cd

# Wait for agrocd to start
kubectl wait --for=condition=available --timeout=180s deployment/argocd-server -n argocd
echo -n "ArgoCD username admin and password: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

echo "Apply apps into Argo CD"
kubectl apply -f apps/apps.yml

echo "Wait for databases"
until kubectl -n maira get po | grep temporal-worker
do
    echo "waiting for temporal-worker to get created"
    kubectl -n maira get po -A
    sleep 5
done
kubectl -n maira wait --for=condition=ready pod -l app.kubernetes.io/component=worker --timeout=180s
echo "Temporal worker is ready"

kubectl apply -f maira/maira.yml

echo "Wait for maira"
until kubectl -n maira get po | grep maira-cloud-worker | grep 1/1
do
    echo "waiting for temporal-worker to get created"
    kubectl -n maira get po
    sleep 5
done
echo "Maira API is ready"

echo "Do you want to deploy Maira Gateway? [y/N]"
read answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "User confirmed. Continuing with installation..."
    kubectl apply -f maira/maira-gateway.yml
    echo "Maira Gateway installatin is done."
else
    echo "User cancelled. Installation done. Exiting..."
    exit 0
fi
