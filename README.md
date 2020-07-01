# Versioning POC



## Install a deployment

```
kubectl apply -f ./deployment_v1.0.yaml
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

# rolling upgrade to v1.1
kubectl apply -f ./deployment_v1.1.yaml

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