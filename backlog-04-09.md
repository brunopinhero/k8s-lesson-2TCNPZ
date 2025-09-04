kubectl get nodes
kubectl config use-context docker-desktop
kubectl apply -f pod.yaml
kubectl apply -f exercicio1-pod-simples.yaml
kubectl get pods
kubectl port-forward pod/meu-pod 8080:80