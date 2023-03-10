#!/bin/bash
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
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=*.maira.local"
kubectl create -n maira secret tls maira-tls-secret --cert=tls.crt --key=tls.key


# TODO: remove when all is public
gpg --decrypt argocd/image-pull-secret.yml.gpg 2> /dev/null | kubectl apply -f -

# Generate password for all services
PASSWORD=$(openssl rand -base64 8 | md5)

kubectl create -n maira secret generic maira-db-uri-secret --from-literal=db_uri="mongodb://root:$PASSWORD@mongodb.maira:27017/?authSource=admin"
kubectl create -n maira secret generic temporal-default-store --from-literal=cassandra-password="$PASSWORD" \
    --from-literal=mongodb-root-password="$PASSWORD" \
    --from-literal=password="$PASSWORD"

# bootstrap argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install --create-namespace --version 5.24.3 --values argocd/values.yml --namespace argocd argocd argo/argo-cd

# Wait for agrocd to start
kubectl wait --for=condition=available --timeout=180s deployment/argocd-server -n argocd
echo -n "ArcoCD username admin and password: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

echo "Apply apps into Argo CD"
kubectl apply -f apps/apps.yml

echo "Wait for for databases"
until kubectl -n maira get po | grep temporal-worker
do
    echo "waiting for temporal-worker to get created"
    kubectl -n maira get po -A
    sleep 5
done
kubectl -n maira wait --for=condition=ready pod -l app.kubernetes.io/component=worker --timeout=180s
echo "Temporal worker is ready"

kubectl apply -f maira/maira.yml

echo "Wait for for maira"
until kubectl -n maira get po | grep maira-cloud-worker | grep 1/1
do
    echo "waiting for temporal-worker to get created"
    kubectl -n maira get po
    sleep 5
done
echo "Maira is ready"