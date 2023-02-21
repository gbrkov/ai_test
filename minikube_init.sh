

reqs="kubectl docker minikube docker"

echo "* Start checking requirements: $req"
for req in $reqs
  do
    which $req
    if [[ $? != 0 ]]; then
      echo "* You need install $req"
      exit 2
    fi
  done


echo "* checking minikube status:"
minikube status
if ! [[ $? == 0 ]];then
  echo "starting minikube"
  minikube start --vm-driver=docker
fi

echo "* setting the kubectl context to your minikube instance"
kubectl config use-context minikube

echo "* setting the docker image context to your minikube instance"
eval $(minikube docker-env)

read -p "Which namespace will be using to test? [default: gkovacs-ai-test]" namesp
namesp=${namesp:-gkovacs-ai-test}

echo "checking namespace: ${namesp}"
ns_check=false
while [[ ${ns_check} == false ]]
do 
  kubectl get ns ${namesp}
  if [[ $? == 0 ]];then
    read -r -p "* This namespace is exists: ${namesp} Would you like to use? [y|N] " response
    if ! [[ $response =~ ^(y|yes|Y) ]];then
      read -p "* Which namespace will be using to test? [default: gkovacs-ai-test]" namesp
      namesp=${namesp:-gkovacs-ai-test}
    else
      ns_check=true
    fi
  else
    echo "* ${namesp} is not exists, creating"
    kubectl create ns ${namesp}
    ns_check=true
  fi
done

echo "* get info from ${namesp} namespace"
kubectl get ns ${namesp}

echo "* here is your minikube:"
kubectl get pods --all-namespaces -o wide

#echo "* creating the redis storage, define storage class"
kubectl apply -n ${namesp} -f redis_storage.yaml

#echo "* storage classes:"
kubectl get sc

#echo "* Create redis persistentVolumes" 
kubectl apply -n ${namesp} -f redis_pv.yaml

#echo "* get persistentVolumes"
kubectl get pv

#echo "* apply redis config map"
kubectl apply -n ${namesp} -f redis_config.yaml

#echo "* get config maps from ${namesp} namespace"
kubectl get configmap -n ${namesp}

#echo "* check to redis:6.2.10-alpine version exist in local docker image store"
#docker inspect --type=image redis:6.2.10-alpine
#if [[ $? != 0 ]];then
#  read -r -p "* Would you like to pull redis:6.2.10-alpine version from docker hub?[y|N] " response
#    if [[ $response =~ ^(y|yes|Y) ]];then
#      docker pull redis:6.2.10-alpine
#    else
#      echo "* This script is using redis:6.2.10-alpine docker image, please download from dockerhub and restart this script." 
#      echo "* url: https://hub.docker.com/layers/library/redis/6.2.10-alpine/images/sha256-7b2510ea835cc2e15e3f5402a891be8f076ce505d41a31a4096ea146b970e7cb?context=explore"
#      exit 3
#     fi
#fi

#read -r -p "* Please add redis password " redis_password
#kubectl create secret generic redis --from-literal="REDIS_PASS=${redis_password}"


echo "* set up redis instances"
kubectl apply -n ${namesp} -f redis_statefulset.yaml


echo "* create headless service"
kubectl apply -n ${namesp} -f redis_service.yaml

echo "* create headless master service"
kubectl apply -n ${namesp} -f redis_service_master.yaml

## build docker image to flask service

export GCV=$(git rev-parse --short HEAD)
sed -i "s/GIT_VERSION=.*$/GIT_VERSION=\"${GCV}\"/" ./flask/app.py

docker build -t gkovacs/flask_test ./flask

docker image list | grep gkovacs

echo "** start minikube tunnel to get balancer external port, to this need root password"
echo "* more info: https://minikube.sigs.k8s.io/docs/handbook/accessing/#using-minikube-tunnel"
minikube tunnel -c &>/dev/null

kubectl apply -f flaskapp_service.yaml -n ${namesp}

kubectl apply -f flask_app.yaml -n ${namesp}

watch "echo '#############################################################################\n \
this is a watch session, you can exit with ctrl + c and continue this script\n\
#############################################################################\n\n\n' & kubectl get pods -n ${namesp}"



echo "* application scale with:  kubectl scale -n ${namesp} rs/flaskapp --replicas=10"
