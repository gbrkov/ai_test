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
