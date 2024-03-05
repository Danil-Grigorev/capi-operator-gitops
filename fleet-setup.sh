kind create cluster --config config.yaml

helm repo add gitea-charts https://dl.gitea.com/charts/
helm repo add fleet https://rancher.github.io/fleet-helm-charts/

helm -n cattle-fleet-system install --create-namespace --wait fleet-crd fleet/fleet-crd
helm install --create-namespace -n cattle-fleet-system fleet fleet/fleet --wait
helm install gitea gitea-charts/gitea --values values.yaml --wait

export USERNAME=gitea_admin
export PASSWORD=admin
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services gitea-http)
export REPO_NAME=test

curl \
  -X POST "http://$NODE_IP:$NODE_PORT/api/v1/user/repos" \
  -H "accept: application/json" \
  -u $USERNAME:$PASSWORD \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$REPO_NAME\"}" \
  -i

kubectl create ns fleet-local
kubectl create secret generic basic-auth-secret -n fleet-local --type=kubernetes.io/basic-auth --from-literal=username=$USERNAME --from-literal=password=$PASSWORD

kubectl apply -n fleet-local -f - <<EOF
kind: GitRepo
apiVersion: fleet.cattle.io/v1alpha1
metadata:
  name: fleet-repo
spec:
  repo: http://$NODE_IP:$NODE_PORT/$USERNAME/$REPO_NAME.git
  branch: master
  forceSyncGeneration: 1
  clientSecretName: basic-auth-secret
EOF
