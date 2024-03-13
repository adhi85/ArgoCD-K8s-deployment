# ArgoCD for Continuos Deployment and Argo Rollouts for deployment strategy (Canary)

## Prerequisites
- minikube installed on your system
- docker installed and configured

## Setup and configuration
1. Start the minikube cluster  `minikube start`
2. Install ArgoCD on the cluster. You can refer the official [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/)
   
      > kubectl create namespace argocd  
      > kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

3. Install Argo Rollouts. [Documentation](https://argo-rollouts.readthedocs.io/en/stable/)
      > kubectl create namespace argo-rollouts  
      > kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

## Setting up Argo CD UI
1. List out the svc in argocd namespace
     > kubectl get svc -n argocd
2. Here we can see that the argocd-server is in ClusterIP mode. We will have to change it to NodePort mode to access this service from browser.
    > kubectl edit svc argocd-server -n argocd    
    - Change type to NodePort. It will be CLusterIP by default.
3. if we need access through browser we need to do port forwarding.
   
     > minikube service argocd-server -n argocd
      - We can get the URL to access the ArgoCD UI now.
      - Paste the URL in browser and login to ArgoCD UI.
4. Default username will be *admin*
5. To get the Password:
    >  kubectl get secret -n argocd  
    > kubectl edit secret argocd-initial-admin-secret -n argocd
6. Copy the password from there and decode it.
    > echo \<Your-copied-password\> | base64 --decode
7. Use the decoded password to login.

## Creating the Gitops Pipeline
1. We have used a simple node application for deployment
2. Build the docker image and push it to any public container registry.

     > docker build -t \<your-username\>/tictactoe:v1 .  
     > docker push \<your-username\>/tictactoe:v1
3. Now we have created the image for our application and pushed it to Docker hub.
4. Deploy the application using ArgoCD.  
    1. I have provided the YAML file.
    2. Create an Application in the ArgoCD UI
        *  Give the repository url: https://github.com/adhi85/ArgoCD-K8s-deployment
        *  Give PATH (This is where the YAML files are):   **canary**
        *  create the application
5. ArgoCD will create the deployments and services into cluster.

## Implementing a Canary Release with Argo Rollouts
1. Modified the YAML files to include the Argo Rollouts specifying canary release strategy.
2. We can make some minor changes to the application and rebuild the docker image and push it to Docker hub.
3. Update the Rollout definition to use the latest image for our app.
    - Previously we used v1. Change it to v2.
4. We can monitor the deployment of new version and ensure that canary release is succesfull.
   * We have set the weight as 20. So 20% of 5 pods, i.e 1 pod will get the new version and 80% will be using previous version    
              <img width="595" alt="argocd" src="https://github.com/adhi85/ArgoCD-K8s-deployment/assets/72289081/f85e0fde-d193-48d9-b7a2-c3284089bccb">
   * We can promote it if we are ready to move to the new version.


## Cleanup
* Delete Deployments and Services
  > kubectl delete deployment deployment-tictactoe   
  > kubectl delete service service-tictactoe
* Delete Argo Rollouts resources
  > kubectl delete rollout rollout-tictactoe
* Delete Argo CD Application
  > kubectl delete application tictactoe -n argocd
* Delete Docker images from the container registry
* (Optional) Delete ArgoCD
     > kubectl delete namespace argocd
   
