%title: Базовые абстракции в Kubernetes. Лекция
%author: b.murashov
%date: 2019-09-19

-------------------------------------------------

-> # Agenda <-

* Вступление
* Первая итерация
  - Создание Pod для MySQL
  - Создание Service для MySQL
  - Создание пода roundcube
  - Создание Service для roundcube
  - Создание Ingress для roundcube
  - Создание Certificate для roundcube
  - Создание TLS Ingress для roundcube

                                            1/2

-------------------------------------------------

-> # Agenda <-

* Масштабируем roundcube
  - ReplicaSet
  - Чиним roundcube
* Продолжая улучшать roundcube
  - Deployment
  - Не забываем о важном
  - Последние штрихи в MySQL
* Подводим итоги

                                            2/2

-------------------------------------------------

-> # Вступление <-

-------------------------------------------------

-> # Первая итерация <-

-------------------------------------------------

-> # Создание Pod для MySQL <-

```
apiVersion: v1
kind: Pod
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  containers:
  - name: mysql
    image: mysql:8.0
    command:
    - "docker-entrypoint.sh"
    - "mysqld"
    - "--default-authentication-plugin=mysql_native_password"
...
```

                                            1/2

-------------------------------------------------

-> # Создание Pod для MySQL <-

```
...
    env:
    - name: MYSQL_DATABASE
      value: roundcubemail
    - name: MYSQL_USER
      value: roundcube
    - name: MYSQL_PASSWORD
      value: "123456789"

    - name: MYSQL_ROOT_PASSWORD
      value: "123456789"
```

                                            2/2

-------------------------------------------------