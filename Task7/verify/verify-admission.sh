#!/bin/bash
set -e

NS=audit-zone

echo "[*] Проверка небезопасных манифестов..."

if kubectl apply -f ./insecure-manifests/01-privileged-pod.yaml -n $NS 2>&1 | grep -q "Forbidden"; then
  echo "✅ Отклонено"
else
  echo "❌ Должно было быть отклонено!"
fi

if kubectl apply -f ./insecure-manifests/02-hostpath-pod.yaml -n $NS 2>&1 | grep -q "Forbidden"; then
  echo "✅ Отклонено"
else
  echo "❌ Должно было быть отклонено!"
fi

if kubectl apply -f ./insecure-manifests/03-root-user-pod.yaml -n $NS 2>&1 | grep -q "Forbidden"; then
  echo "✅ Отклонено"
else
  echo "❌ Должно было быть отклонено!"
fi

echo "[*] Проверка безопасных манифестов..."

if kubectl apply -f ./secure-manifests/01-secure.yaml -n $NS 2>&1 | grep -q "created"; then
  echo "✅ Принято"
else
  echo "❌ Должно было быть принято!"
fi

if kubectl apply -f ./secure-manifests/02-secure.yaml -n $NS 2>&1 | grep -q "created"; then
  echo "✅ Принято"
else
  echo "❌ Должно было быть принято!"
fi

if kubectl apply -f ./secure-manifests/03-secure.yaml -n $NS 2>&1 | grep -q "created"; then
  echo "✅ Принято"
else
  echo "❌ Должно было быть принято!"
fi
