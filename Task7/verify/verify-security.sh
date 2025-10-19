#!/bin/bash
set -e

echo "[*] Проверка подов в audit-zone на нарушения..."
kubectl get pods -n audit-zone -o json | jq '
  .items[] |
  {
    name: .metadata.name,
    privileged: (.spec.containers[]?.securityContext.privileged),
    runAsNonRoot: (.spec.containers[]?.securityContext.runAsNonRoot),
    readOnlyRootFilesystem: (.spec.containers[]?.securityContext.readOnlyRootFilesystem),
    hostPath: ([.spec.volumes[]? | select(.hostPath)] | length > 0)
  }'
