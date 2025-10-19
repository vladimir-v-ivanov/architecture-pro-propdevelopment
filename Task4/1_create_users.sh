#!/bin/bash

# Данный скрипт создает по одному пользователю на каждую группу:
# - ClusterAdmin
# - ClusterReader
# - DevOps
# - Developer
# - Viewer

echo "[INFO] Создание пользователей"

CERT_DIR=~/k8s-users
mkdir -p $CERT_DIR
cd $CERT_DIR

openssl genrsa -out clusteradmin.key 2048
openssl genrsa -out clusterreader.key 2048
openssl genrsa -out devops.key 2048
openssl genrsa -out developer.key 2048
openssl genrsa -out viewer.key 2048

openssl req -new -key clusteradmin.key -out clusteradmin.csr -subj "/CN=clusteradmin/O=clusteradmin"
openssl req -new -key clusterreader.key -out clusterreader.csr -subj "/CN=clusterreader/O=clusterreader"
openssl req -new -key devops.key -out devops.csr -subj "/CN=devops/O=devops"
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer/O=developers"
openssl req -new -key viewer.key -out viewer.csr -subj "/CN=viewer/O=viewer"

sudo openssl x509 -req -in clusteradmin.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out clusteradmin.crt -days 365
sudo openssl x509 -req -in clusterreader.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out clusterreader.crt -days 365
sudo openssl x509 -req -in devops.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out devops.crt -days 365
sudo openssl x509 -req -in developer.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out developer.crt -days 365
sudo openssl x509 -req -in viewer.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out viewer.crt -days 365

kubectl config set-credentials clusteradmin --client-certificate=$CERT_DIR/clusteradmin.crt --client-key=$CERT_DIR/clusteradmin.key
kubectl config set-credentials clusterreader --client-certificate=$CERT_DIR/clusterreader.crt --client-key=$CERT_DIR/clusterreader.key
kubectl config set-credentials devops --client-certificate=$CERT_DIR/devops.crt --client-key=$CERT_DIR/devops.key
kubectl config set-credentials developer --client-certificate=$CERT_DIR/developer.crt --client-key=$CERT_DIR/developer.key
kubectl config set-credentials viewer --client-certificate=$CERT_DIR/viewer.crt --client-key=$CERT_DIR/viewer.key

echo "[INFO] Пользователи созданы"
