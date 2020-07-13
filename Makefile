##
# Versioning POC
##
SHELL := /bin/bash
PROJECT = "Versioning POC"
DIR = $(shell pwd)
REPO_DIR := $(DIR)/repo
SCRIPTS_DIR := $(DIR)/scripts

##
# Runners
##

install: package .add-repos .install-base
	helm search repo local
	helm install versioning-poc local/versioning-poc --version 1.0.0

upgrade-v1.1.0:
	helm upgrade versioning-poc local/versioning-poc --version 1.1.0

uninstall-poc:
	helm del versioning-poc

uninstall-all: uninstall-poc clean-install-base clean-add-repos


##
# Stateful make commands
#
# These create respective `.commandname` files to stop make from
# running the same command multiple times
## 
.add-repos:
	helm repo add public http://storage.googleapis.com/kubernetes-charts-incubator
	helm repo add local http://localhost:8000
	@touch .add-repos

.install-base:
	kubectl apply -f ./deployment_setup.yaml
	helm install kafka public/kafka --values ./kafka_values.yaml
	@touch .install-base

clean-add-repos:
	@rm -rf .add-repos

clean-install-base:
	helm del kafka
	kubectl delete -f ./deployment_setup.yaml
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
	python3 -m http.server --directory ./repo/

##
# Kafka Tools
##

kafka-list:
	kubectl exec testclient -- kafka-topics --zookeeper kafka-zookeeper:2181 --list

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
