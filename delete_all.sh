kubectl delete service -n gkovacs-ai-test redis

kubectl delete statefulSets -n gkovacs-ai-test redis

kubectl delete ns gkovacs-ai-test

kubectl delete pv local-pv1
kubectl delete pv local-pv2
kubectl delete pv local-pv3

kubectl delete sc local-storage
