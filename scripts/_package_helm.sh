#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="${DIR}/../repo"
HELM_DIR="${DIR}/../helm"
LOCAL_HELM_REPO_URI="${LOCAL_HELM_REPO_URI:-localhost:8000}"

set -u
set -e

mkdir -p "${REPO_DIR}"

for dir in ${HELM_DIR}/*; do
  helm package -u -d ${REPO_DIR} $dir
done

helm repo index "${REPO_DIR}" --url "${LOCAL_HELM_REPO_URI}"
echo "${LOCAL_HELM_REPO_URI}"