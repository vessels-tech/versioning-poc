##
# Versioning POC
##
SHELL := /bin/bash
PROJECT = "Versioning POC"
DIR = $(shell pwd)
REPO_DIR := $(DIR)/repo
SCRIPTS_DIR := $(DIR)/scripts
ELB_URL = "a2c25768ab0194fe187d21c903b78bf1-475140305.eu-west-2.elb.amazonaws.com"

##
# Runners
##

install: package run-helm-server .add-repos .install-base
	helm search repo local
	# helm upgrade --install versioning-poc local/versioning-poc --version 1.0.0
	helm install versioning-poc local/versioning-poc --version 1.0.0

upgrade-v1.0.0: package
	helm upgrade --install versioning-poc local/versioning-poc --version 1.0.0

upgrade-v1.1.0: package
	helm upgrade --install versioning-poc local/versioning-poc --version 1.1.0

upgrade-v1.2.0: package
	helm upgrade --install versioning-poc local/versioning-poc --version 1.2.0

upgrade-v2.0.0: package
	helm upgrade --install versioning-poc local/versioning-poc --version 2.0.0

upgrade-v2.1.0: package
	helm upgrade --install versioning-poc local/versioning-poc --version 2.1.0

uninstall-poc: mysql-drop-database
	@helm del versioning-poc || echo 'versioning-poc not found'

uninstall-all: uninstall-poc clean-install-base clean-add-repos


##
# Stateful make commands
#
# These create respective `.command-name` files to stop make from
# running the same command multiple times
## 
.add-repos:
	helm repo add public http://storage.googleapis.com/kubernetes-charts-incubator
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo add local http://localhost:8000
	@touch .add-repos

.install-base:
	kubectl apply -f ./deployment_setup.yaml
	helm install kafka public/kafka --values ./kafka_values.yaml
	helm install nginx ingress-nginx/ingress-nginx
	@touch .install-base

clean-add-repos:
	@rm -rf .add-repos

clean-install-base:
	@helm del nginx || echo 'helm del nginx failed - continuing anyway'
	@helm del kafka || echo 'helm del kafka failed - continuing anyway'
	@kubectl delete -f ./deployment_setup.yaml || echo 'kubectl del kafka failed - continuing anyway'
	@rm -rf .install-base


##
# Repo Tools
## 
.PHONY: package clean

package: 
	$(SCRIPTS_DIR)/_package_helm.sh

clean-repo:
	rm -rf $(REPO_DIR)

run-helm-server:
	python3 -m http.server --directory ./repo/ &> /dev/null &
	@echo "started python server"

kill-helm-server:
	@ps aux | grep http.server | grep -v "grep" | awk '{print $$2}' | xargs kill -9

##
# Monitoring Tools
##

kafka-list:
	kubectl exec testclient -- kafka-topics --zookeeper kafka-zookeeper:2181 --list

mysql-show-tables:
	kubectl exec -it pod/mysql-0 -- mysql -u root -ppassword central_ledger -e "show tables"

mysql-describe-transfer:
	kubectl exec -it pod/mysql-0 -- mysql -u root -ppassword central_ledger -e "describe transfer"

mysql-login:
	kubectl exec -it pod/mysql-0 -- mysql -u root -ppassword central_ledger

mysql-drop-database:
	kubectl exec -it pod/mysql-0 -- mysql -u root -ppassword -e "drop database central_ledger; create database central_ledger"

health-check-central-ledger:
	# @kubectl exec testclient -- curl -s centralledger:3001/health | jq
		@curl -H "Host: central-ledger.local"  $(ELB_URL)/health


health-check-ml-api-adapter:
	# @kubectl exec testclient -- curl -s mlapiadapter:3000/health | jq
	@curl -H "Host: ml-api-adapter.local"  $(ELB_URL)/health


##
# Kube Tools
##
.PHONY: watch-all switch-kube

# Watch all resources in namespace
watch-all:
	watch -n 1 kubectl get all

# Convenience function to switch back to the kubectx and ns we want
switch-kube:
	kubectx test-scaling
	kubens test-da
	helm list
