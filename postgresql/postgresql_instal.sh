#!/bin/bash
kubectl apply -f postgres-configmap.yaml
sleep 10s

kubectl get configmap

#pv not used because we use longhorn
#kubectl apply -f psql-pv.yaml

kubectl apply -f psql-claim.yaml
sleep 10s

kubectl get pv -n wikijs
kubectl get pvc -n wikijs


kubectl apply -f ps-deployment.yaml
sleep 10s

kubectl get deployments -n wikijs
kubectl get pods -n wikijs


kubectl apply -f ps-service.yaml
kubectl get svc -n wikijs
kubectl get pods -n wikijs

kubectl get pods -l app=postgres -n wikijs
kubectl scale deployment --replicas=5 postgres
sleep 10s

kubectl get pods -l app=postgres -n wikijs

