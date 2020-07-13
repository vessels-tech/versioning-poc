#
# Versioning POC
#

# PATH := node_modules/.bin:$(PATH)
SHELL := /bin/bash

PROJECT = "Versioning POC"
DIR = $(shell pwd)
REPO_DIR := $(DIR)/repo
SCRIPTS_DIR := $(DIR)/scripts

# $(shell touch env/.compiled; touch .vb_config)
# include ./config/version
# include .vb_config
# include $(dir)/env/.compiled

# admin_dir := $(dir)/src/admin
# admin_dir_compiled := $(dir)/dist/admin
# env_dir := $(dir)/env

# number ?= ${VB_test_mobile}

.PHONY: package clean

package: 
	$(SCRIPTS_DIR)/_package_helm.sh

clean:
	rm -rf $(REPO_DIR)

run-helm-server:
	python3 -m http.server --directory ./repo/
