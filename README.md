# Versioning POC

ingress:
```bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install my-release ingress-nginx/ingress-nginx
```

## Package and Install

```bash
# in separate window, start a local server
make run-helm-server

# package all helm versions
make package

# TODO: - add these as chart dependencies!
# prerequisites: not going to be touched by us
helm repo add public http://storage.googleapis.com/kubernetes-charts-incubator

# install mysql, PVC for kafka, etc
kubectl apply -f ./deployment_setup.yaml
helm install kafka public/kafka --values ./kafka_values.yaml

# add the local repo
helm repo add local http://localhost:8000

# search for our chart
helm search repo local

# install v1.0.0
helm install versioning-poc local/versioning-poc --version 1.0.0 --namespace 
```

## Using Make

```bash
# in separate window, start a local helm server
# This is so we get the nice helm `install` and `upgrade` commands
make run-helm-server

# Install v1.0.0
# make will also install any other dependencies if required
make install

# Upgrade to v1.1.0
# apply the db schema changes: optional `quoteId` column
make upgrade-v1.1.0

# add support for v2.0 API
make upgrade-v1.2.0

# drop support for v1.X API
# TODO: need to drain v1.X connections before this point
# add support for v2.0 API
make upgrade-v2.0.0

# migrate existing null quoteId column
# make quoteId non-nullable
make upgrade-v2.1.0


# Clean up everything
make uninstall-all
```

## Install a deployment

```bash
# kubectl apply -f ./deployment_v1.0.yaml
helm install versioning-poc ./helm
```

## MVP - mininal helm

```bash
# prerequisites: not going to be touched by us
helm repo add public http://storage.googleapis.com/kubernetes-charts-incubator

# install mysql, PVC for kafka, etc
kubectl apply -f ./deployment_setup.yaml
helm install kafka public/kafka --values ./kafka_values.yaml

# todo look at the transfers table


# install v1.0 of our application
kubectl apply -f ./deployment_v1.0.yaml

# check our schema
kubectl exec -it pod/mysql-0 -- mysql -u root -ppassword central_ledger -e "describe settlementModel"

# rolling upgrade to v1.1
kubectl apply -f ./deployment_v1.1.yaml

# observe the schema has changed!
kubectl exec -it pod/mysql-0 -- mysql -u root -ppassword central_ledger -e "describe settlementModel"

# TODO: 

```

## PVC

```bash
kubectl delete deployment,svc mysql
kubectl delete pvc mysql-pv-claim
kubectl delete pv mysql-pv-volume

```


## Handy Snippets:

### Kubectl

```bash
# watch important things
watch -n 1 "kubectl get po; echo "---"; kubectl get service; echo "---"; kubectl get deployments"
```

### Kafka

```bash
# Once you have the testclient pod above running, you can list all kafka topics with:
kubectl -n default exec testclient -- kafka-topics --zookeeper kafka-zookeeper:2181 --list

# To create a new topic:
kubectl -n default exec testclient -- kafka-topics --zookeeper kafka-zookeeper:2181 --topic test1 --create --partitions 1 --replication-factor 1

# To listen for messages on a topic:
kubectl -n default exec -ti testclient -- kafka-console-consumer --bootstrap-server kafka:9092 --topic test1 --from-beginning

# To stop the listener session above press: Ctrl+C

# To start an interactive message producer session:
kubectl -n default exec -ti testclient -- kafka-console-producer --broker-list kafka-headless:9092 --topic test1

# To create a message in the above session, simply type the message and press "enter"
# To end the producer session try: Ctrl+C
```

### Simulators

```bash
# curl -s -H "Host: simapi.local"  a2c25768ab0194fe187d21c903b78bf1-475140305.eu-west-2.elb.amazonaws.com/health
# curl -s -H "Host: reportapi.local"  a2c25768ab0194fe187d21c903b78bf1-475140305.eu-west-2.elb.amazonaws.com/health
# curl -s -H "Host: testapi.local"  a2c25768ab0194fe187d21c903b78bf1-475140305.eu-west-2.elb.amazonaws.com/health
curl -s \
    -H "Host: simulator.local" \
    a2c25768ab0194fe187d21c903b78bf1-475140305.eu-west-2.elb.amazonaws.com/sim/dfspa/inbound
```

/sim/dfspa/outbound/
/sim/dfspa/inbound/
/sim/dfspa/sdktest/
/sim/dfspa/test/




## Learnings:


- Rollbacks are hard when "automigrate" is on, since Knex will look for a migration file (that was run on say, version `1.1`) that doesn't exist in version `1.0` of the application and fail.
    >`(node:38) UnhandledPromiseRejectionWarning: Error: The migration directory is corrupt, the following files are missing: 96105000_add_optional_quoteId.js`

    - workarounds? TBD 
        - We need a way to tell Knex: "I know what I'm doing here"




