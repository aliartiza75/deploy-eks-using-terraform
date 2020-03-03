# Payever DevOps Task

## Overview

This repository contains the mainfest of the trial task given by Payever team.

## PART-I

### Repository Structure

The root repository contains the following files and folders.

```bash
├── aws
├── es-to-prom-exporter
├── mysql
├── monitoring
├── logging
├── namespaces.yaml
└── README.md
```

### Tools/Utilities Required

List of tools/utilities are given below:

1. aws
2. kubectl
3. aws-iam-authenticator
4. helm
5. terraform
6. Any editor for manifest manipulaton


## Files and Folder Details


### 1. namespaces.yaml
It contains the manifest for all the namespaces requried in subsequent steps. 

1. Create the namespaces using the command given below:
```
kubectl apply -f namespaces.yaml
```

2. Verify namespaces are created:
```bash
kubectl get namespaces
```

### 2. aws

It contains the manifest regarding the cluster infrastructure. Detials of this folder is given below:

```bash
├── eks # it contains the mainfest for the infrastucture
│   ├── kubeconfig_eks-cluster # it is generated by terraform
│   ├── main.tf # it contains the information regarding the eks cluster infrastructure and user permissions
│   ├── terraform.tfstate # it contains the state of the infrastructure generated by terraform using the main.tf file
│   └── terraform.tfstate.backup # it contains the terraform's state backup
└── users # it contains the manifest for user and related resource creation
    ├── eks-user-policy.json # it contains the required permission for the user to create an eks cluster
    ├── main.tf # it contains the information regarding the user creation
    ├── terraform.tfstate # it contains the state of the user and related resources created by terraform
    └── terraform.tfstate.backup # it contains the backup of terraform's state
```

#### Deployment



1. For the deployment of the above resource we need terraform (version: v0.12.21(for user creation), v0.11.14(for eks cluster creation)). Two version are required due to support for the manifests. This can be resolved by some research.

2. Move inside the `users` folder and run the following command:

```bash
terraform apply # it will output the plan for resources creation and ask for permission to create the resources.

# it wil create two files regarding the terraform state. Once user is created it ACCESS_KEY and ACCESS_KEY_SECRET needs to be configured on the system in order to create the eks cluster. These secret can be found either in the terraform.tfstate file or AWS IAM console.
```

It will create a user in AWS with limited access.

3. Move inside the `eks` folder and run the following command:

```bash
terraform apply # it will output the plan for resources creation and ask for permission to create the resources.

# it will create three files, two of them contains the terraform state while another files contains the eks cluster kubeconfig. In the above apply command 1 step might fail. It can be resolved by adding the kubeconfig in this file on your system `~/.kube/config`. Once added re-run the above command. 
```

4. Once above steps are completed we will have a user with limited access to create an eks cluster and a runnnig eks cluster.

5. To verify the cluster up use the command given below:
```bash
kubectl get nodes # it will output the cluster nodes based on the configuration provied in eks/main.tf file.
```

### 3. mysql

It contains the manifest for mysql. Detials of this folder is given below:

```bash
├── mysql.yaml # it contains the manifest for the mysql
└── secrets
    └── mysql-passwords.yaml # it contains the secret for the mysql database. It will be used in mysql.yaml file.
```

#### Deployment

1. Move inside the secrets folder and create the mysql secret using the command given below:

```bash
kubectl apply -f mysql-passwords.yaml
```

2. Deploy the mysql database using the command given below:
```bash
kubectl apply -f mysql.yaml
```

3. Verify mysql is deployed:

```bash
kubectl get pods -n storage
```

### 4. monitoring

It contains the manifest for the monitoring services. Detials of this folder is given below:

```bash
├── dashboard # it contains the manifests for the kubernetes dashboard
│   ├── auth-delegator.yaml
│   ├── auth-reader.yaml
│   ├── eks-admin-service-account.yaml
│   ├── metrics-apiservice.yaml
│   ├── metrics-server-deployment.yaml
│   ├── metrics-server-service.yaml
│   └── resource-reader.yaml
├── Makefile # it contains the instructions for the helm operator installation
├── prometheus-operator # it contains the manifests for the prometheus operator operator
│   ├── clusterrolebindings.yaml 
│   ├── clusterrole.yaml
│   ├── crds # crd required by prometheus operator
│   │   ├── crd-alert-manager.yaml
│   │   ├── crd-prometheus-rules.yaml
│   │   ├── crd-prometheus.yaml
│   │   └── crd-servicemonitor.yaml
│   ├── grafana-dashboard  # grafana dashboard for elastic search
│   │   └── elasticsearch.yaml
│   ├── prometheus-operator.yaml # prometheus operator manifest
│   └── secrets # secret required by alertmanager
│       └── alertmanager-config.yaml
└── tiller-rbac.yaml
```

#### Deployment

1. Move inside the dashboard folder and run command to deploy resource required by dashboard:

```bash
kubectl apply -f .
```

2. Apply the dashboard manifests
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
```

3. Run the local proxy server to access the dashboard
```bash
kubectl proxy
```

4. Dashboard will be accessible on this url

```bash
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login
```

5. Token to access the dashboard can be retrieved using the command given below:
```bash
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
```

6. Create the rbac for tiller, it is required by the helm to install its server side componenet(tiller):
```bash
kubectl apply -f tiller-rbac.yaml
```

7. Run the Makefile's `install-helm` target to deploy the helm operator
```bash
make install-helm # wait for it
```

8. Move inside the prometheus-operator folder and create the cluster role and its binding

```bash
kubctl apply -f clusterrole.yaml
kubectl apply -f clusterrolebindings.yaml
```

9. Create the CRDs required by prometheus-operator:
```bash
kubectl apply -f crds/.
```

10. Create the config map for the elasticsearch dashboard, it will loaded in grafana by its sidecar

```bash
kubectl apply -f grafana-dashboard/.
```

11. Now deploy the prometheus-operator:
```bash
kubectl apply -f prometheus-operator.yaml

# it will deploy grafana, prometheus and alertmanager.
```

12. To expose the grafana, prometheus and alertmanager, we will change the service type of these tools from `ClusterIP` to `LoadBalancer`. This change is required due to the unavalibility of domain. Although the right methods would be to create an ingress for it.

```bash
kubectl get svc -n monitoring # it will print the services, no service will have an ExternalIP for now

# to edit a service
kubectl edit service <service-name-(in this case name of the grafana, alertmanager and prometheus service will be used)> -n monitoring

# above command will open the service manifest in the vim editor(it might change on other system), just change the service type from ClusterIP to LoadBalancer.

# to get the service again
kubectl get svc -n monitoring # this time change service will have an External IP. Use the value to access the tool(grafana, prometheus and alertmanager).

```

13. An alert has been configured. I have intentionally configured this alert to be generated.

![alert](./images/alert.png).

It rules is added in the `monitoring/prometheus-operator/prometheus-operator.yaml` manifest:

![image](./images/rule.png)

### 5. logging

This folder have the manifests for the logging services. Details of the folder is given below:

```bash
├── crds # crd required by the konfigurator
│   └── crd-konfigurator.yaml
├── elasticsearch-cluster-client.yaml
├── elasticsearch-cluster-data.yaml
├── elasticsearch-cluster-master.yaml
├── elasticsearch-curator.yaml
├── fluentd-es.yaml
├── kibana.yaml
├── konfigurator-template.yaml
└── konfigurator.yaml
```

#### Deployment

1. Create the crd
```bash
kubectl apply -f crds/.
```

2. Create the services required for logging
```bash
kubectl apply -f .
```

3. It will take a while before everything is deployed:
```bash
# to check
kubectl get pods -n logging
```

4. To expose kibana, it service type needs to be changed from `ClusterIP` to `LoadBalancer`:
```bash
# to get the services
kubectl get svc -n logging

# to edit the service
kubectl edit svc <kibana-service-name> -n logging

# change the service type
# to get the services
kubectl get svc -n logging # use the value provided in ExternalIP column to access kibana
```

### 6. es-to-prom-exporter

This folder contains the manifest to deploy the es metrics exporter. Details of the folder is given below:

```bash
└── es-to-prom-exoporter.yaml
```

#### Deployment

1. To deploy the exporter run the command given below:

```bash
kubectl apply -f es-to-prom-exporter.yaml
```

2. It it is deployed correctly, a target will be added in the prometheus:
![target](./images/target.png)



## PART-II

- What problems did you encounter? How did you solve them?

    1. It didn't have a domain to expose the tools like grafana, prometheus etc. I used `LoadBalancer` service instead of `ClusterIP`.

- How would you setup backups for mysql in production?

    1. I will run a [sidecar container](https://github.com/stakater-docker/mysql-restore-backup) in the mysql pod. That will take the backup of the data in the mysql and push it on the AWS S3 bucket.

- How would you setup failover of mysql for production in k8s? How many nodes?

    1. I would deploy a mysql cluster with atleast two nodes. The nodes needs to be deployed on different kubernetes cluster nodes. So that if one node goes down the other is available. Those node should also be spread across multiple avalibility zones. So that if one avalibility zone goes down the other is not affected. 

    2. Another things that can be done is to assign the mysql pods priority status so that due to some descheduling process(due to resource utilization process) in the cluster doesn't cause the redeployment of the pod on another node. 

    3. Another thing that can be done is by using the by adding few nodes in the cluster that are only assigned for high priority services like database. It can be ensured by using taint and tolerations.


## REMAINING TASK

Alerts is being triggered by prometheus but i was not able to generate a notification for the alert using alertmanager. My plan was to generate an email for each alert.


## Resource

Following resource were used:

https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

https://github.com/kubernetes-sigs/metrics-server/releases/tag/v0.2.1

https://github.com/helm/charts/tree/master/stable/elasticsearch-exporter

https://www.robustperception.io/sending-email-with-the-alertmanager-via-gmail

https://eksworkshop.com/beginner/130_exposing-service/exposing/