# Задача 7. Политика безопасности контейнеров

## Как проверить

Скрипты проверки нацелены на тестирование Gatekeeper.

- Запустить minikube
- Поднять Gatekeeper
- Применить манифесты `gatekeeper/constraint-templates` и `gatekeeper/constraints`
- Запустить verify/verify-admission.sh из-под директории Task7. Этот скрипт применит манифесты в нужном порядке и выведет отчет.
- Запустить verify/verify-security из под директории Task7. Этот скрипт выведет параметры securityContext для созданных подов.
