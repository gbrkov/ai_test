kubectl create namespace monitoring
kubectl create -f clusterRole.yaml
kubectl create -f config-map.yaml
kubectl create  -f prometheus-deployment.yaml 

kubectl get deployments --namespace=monitoring

kubectl create -f prometheus-service.yaml --namespace=monitoring

