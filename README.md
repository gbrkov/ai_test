# ai_test
This project show how you can use kubernetes with custom app which is using redis and monitroing with prometheus and grafana.

Project start with start_all.sh script. This request default namespace and after deploy a redis flask app and monitoring things into monitoring namespace.

Redis is runnig in cluster master and 2 slave instance and they are using a local storage to keep data after instance kill/restart.

Flask apps are using redis master instance with balancer url to write and all redis instances with balancer for read data.

Flask app run 2 instance default but you can resize with:

kubectl scale -n ${namespace} rs/flaskapp --replicas=10


you can log i all flaskapp instance and you can test endpoints with installed curl command:

get pod names:

kubectl get po -n ${namespace}

login into any flask instance with:

kubectl -n $namesp exec -it "flaskapp-ID"  -- sh 

call endpoint:

curl localhost:8000/healthz

curl localhost:8000/alert

curl localhost:8000/counter

curl localhost:8000/version

commands.

prometheus grafana alerting and alerting install with default config. (Currently not working the alerting system and dashboard)


