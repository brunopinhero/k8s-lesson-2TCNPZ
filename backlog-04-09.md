kubectl get nodes
kubectl config use-context docker-desktop

kubectl apply -f pod.yaml

kubectl apply -f exercicio1-pod-simples.yaml

kubectl get pods

kubectl port-forward pod/meu-pod 8080:80

acessar http://localhost:8080/

kubectl apply -f service.yaml

kubectl get svc

kubectl describe svc meuapp-service | grep NodePort

kubectl edit pod meu-pod

kubectl delete -f pod.yaml

kubectl delete -f service.yaml

kubectl apply -f deployment.yaml

kubectl get pods -o wide

kubectl scale deployment meuapp-deployment --replicas=10

kubectl scale deployment meuapp-deployment --replicas=2

kubectl delete pod meuapp-deployment-544475f8d8-nqslt

kubectl get pods

kubectl set image deployment/meuapp-deployment meu-container=httpd:latest

kubectl rollout status deployment/meuapp-deployment