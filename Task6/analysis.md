# Отчёт по результатам анализа Kubernetes Audit Log

## Примечание

Симуляция выполнялась на чистом minikube, запущенном с нуля.

## Вывод скрипта симуляции
```shell
namespace/secure-ops created
Context "minikube" modified.
serviceaccount/monitoring created
pod/attacker-pod created
no
Error from server (Forbidden): secrets is forbidden: User "system:serviceaccount:secure-ops:monitoring" cannot list resource "secrets" in API group "" in the namespace "kube-system"
pod/privileged-pod created
OCI runtime exec failed: exec failed: unable to start container process: exec: "cat": executable file not found in $PATH: unknown
command terminated with exit code 127
error: the path "/etc/ssl/certs/audit-policy.yaml" does not exist
rolebinding.rbac.authorization.k8s.io/escalate-binding created
```

## Подозрительные события

1. Доступ к секретам:
   - Кто: `system:serviceaccount:secure-ops:monitoring`
   - Где: В namespace `kube-system`, попытка чтения `default-token-*`
   - Почему подозрительно: Сервисный аккаунт `monitoring` пытался получить доступ к секретам в `kube-system`. RBAC запретил операцию (`Forbidden`). Сам факт попытки доступа к секретам чужого namespace фиксируется как потенциальная попытка эскалации.

2. Привилегированные поды:
   - Кто: `minikube-user` (группа `system:masters`, IP `192.168.49.1`)
   - Где: В namespace `secure-ops`, под `privileged-pod`
   - Что сделал: Создал под с контейнером `pwn` (образ `alpine`, команда `sleep 3600`), у которого в `securityContext` установлено `privileged: true`.
   - Комментарий: Ручное создание привилегированного пода пользователем с правами администратора является серьёзным риском. Такой контейнер получает доступ к хостовым ресурсам и может использоваться для эскалации привилегий или обхода политик безопасности.

3. Использование kubectl exec в чужом поде:
   - Кто: `minikube-user`
   - Где: В namespace `kube-system`, под `coredns-*`
   - Что делал: Выполнял команду `cat /etc/resolv.conf` внутри системного пода.
   - Результат: Команда завершилась ошибкой (в контейнере отсутствует `cat`), но сам факт попытки интерактивного доступа в чужой под зафиксирован.
   - Комментарий: Такие действия могут использоваться для разведки или кражи данных.

4. Создание RoleBinding с правами cluster-admin:
   - Кто: `minikube-user`
   - Где: В namespace `secure-ops`
   - Что сделал: Создал `RoleBinding escalate-binding`, назначив сервисному аккаунту `monitoring` права `cluster-admin`.
   - К чему привело: Сервисный аккаунт получил полный административный доступ к кластеру, что является критической эскалацией привилегий.

5. Удаление audit-policy.yaml:
   - Кто: `minikube-user` (пытался выполнить `kubectl delete -f /etc/ssl/certs/audit-policy.yaml --as=admin`)
   - Результат: Операция не удалась (`error: the path ... does not exist`), так как `kubectl delete -f` работает только с объектами в кластере, а не с файлами на диске.
   - Возможные последствия: Успешное удаление или модификация политики аудита привело бы к отключению логирования действий пользователей и скрытию следов атак. В данном случае попытка не удалась, но сам факт её наличия зафиксирован.

## Вывод

- Зафиксированы попытки доступа к секретам сервисным аккаунтом `monitoring`, что указывает на попытку эскалации.
- Пользователь `minikube-user` создал привилегированный под, что является прямым нарушением принципов безопасности.
- Зафиксирована попытка использования `kubectl exec` в системном поде `coredns`, что может быть использовано для разведки.
- Создан `RoleBinding`, дающий сервисному аккаунту `monitoring` права `cluster-admin` — это критическая уязвимость и успешная эскалация привилегий.
- Попытка удалить `audit-policy.yaml` не удалась, но её наличие указывает на намерение скрыть следы.

**Рекомендации:**
- Ограничить права сервисных аккаунтов, особенно в namespace `secure-ops`.
- Запретить создание привилегированных контейнеров политиками безопасности (PodSecurityPolicy/OPA Gatekeeper/Pod Security Admission).
- Настроить мониторинг и алерты на использование `kubectl exec` в системных подах.
- Запретить выдачу `cluster-admin` прав через RoleBinding без строгого контроля.
- Защитить и мониторить `audit-policy.yaml`, чтобы исключить попытки его удаления или изменения.
