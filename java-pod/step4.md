Aller dans le setup helm:

Executer `cd ~/killercoda-training/microservice-1/src/main/helm/simple`{{exec}}

On peut prévisualiser l'injection des values avec :

`helm template .`{{exec}}

On lance l'installation avec :

`helm install demo-java .`{{exec}}

On peut consulter les installations avec :

`helm list`{{exec}}

Vérifier que les 3 pods tournent:

`kubectl get pods -l app=web`{{exec}}

On peut désinstaller avec :

`helm uninstall demo-java`{{exec}}

Vérifier que les pods ne tournent plus :

`kubectl get pods -l app=web`{{exec}}

