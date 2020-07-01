# Versioning POC



## Install a deployment

```
kubectl apply -f ./deployment_v1.0.yaml
```

## PVC

```bash
kubectl delete deployment,svc mysql
kubectl delete pvc mysql-pv-claim
kubectl delete pv mysql-pv-volume

```