kubectl create namespace monitoring
kubectl create -f deployment.yaml
kubectl create -f grafana-datasource-config.yaml
kubectl create -f service.yaml

