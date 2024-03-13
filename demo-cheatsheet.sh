mkdir -r data
cd data

# Init git repo
git init
git remote add origin http://$NODE_IP:$NODE_PORT/$USERNAME/$REPO_NAME.git

# Install all required CAPI Operator manifests
git add providers.yaml
git commit -m "Add operator providers"
git push

# Prepare initial cluster manifests
git add cluster.yaml
git commit -m "Add first cluster"
git push

# Add addon providers
git add addons.yaml
git commit -m "Add velero and helm addon providers"
git push

# Optionally - setup different CNI for the cluster
git add calico.yaml
git commit -m "Add CNI solution for each cluster"
git push

# Optionally - setup GCP credentials for velero
kubectl create secret generic -n default gcp-credentials --from-file=gcp=credentials-velero

# Optionally - Setup velero installation and schedule
git add velero.yaml
git commit -m "Add velero installation and schedule"
git push
