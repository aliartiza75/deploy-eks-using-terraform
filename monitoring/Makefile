.ONESHELL:
SHELL= /bin/bash

install-helm:
	kubectl apply -f tiller-rbac.yaml
	helm init --wait --service-account tiller || true
	helm repo add fluxcd https://charts.fluxcd.io && helm repo update
	helm upgrade --version 0.2.0 -i --wait --force helm-operator fluxcd/helm-operator --namespace flux --set createCRD=true,serviceAccount.name=helm-operator,clusterRole.name=helm-operator
