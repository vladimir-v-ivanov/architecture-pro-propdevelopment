#!/bin/bash

echo "[INFO] Привязка ролей"

NAMESPACE=propdevelopment

# ClusterAdmin
kubectl create clusterrolebinding clusteradmin-binding --clusterrole=cluster-admin-role --user=clusteradmin --dry-run=client -o yaml | kubectl apply -f -

# ClusterReader
kubectl create clusterrolebinding clusterreader-binding --clusterrole=cluster-reader-role --user=clusterreader --dry-run=client -o yaml | kubectl apply -f -

# DevOps
kubectl create rolebinding devops-binding --namespace=$NAMESPACE --role=devops-role --user=devops --dry-run=client -o yaml | kubectl apply -f -

# Developer
kubectl create rolebinding developer-binding --namespace=$NAMESPACE --role=developer-role --user=developer --dry-run=client -o yaml | kubectl apply -f -

# Viewer
kubectl create rolebinding viewer-binding --namespace=$NAMESPACE --role=viewer-role --user=viewer --dry-run=client -o yaml | kubectl apply -f -

echo "[INFO] Роли привязаны"
