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

> https://hub.docker.com/_/mysql
> practice/00-pod-mysql.yaml

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

-> # Создание Service для MySQL <-

> 01-service-mysql.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  selector:
    app: mysql
  clusterIP: None
  ports:
  - name: mysql
    port: 3306
    targetPort: 3306
```

-------------------------------------------------

-> # Создание пода roundcube <-

> https://hub.docker.com/r/roundcube/roundcubemail/
> 02-pod-roundcube.yaml

```
apiVersion: v1
kind: Pod
metadata:
  name: roundcube
  labels:
    app: roundcube
spec:
  containers:
  - name: roundcube
    image: roundcube/roundcubemail
...
```

                                            1/2

-------------------------------------------------

-> # Создание пода roundcube <-

```
...
    env:
    - name: ROUNDCUBEMAIL_DB_TYPE
      value: mysql
    - name: ROUNDCUBEMAIL_DB_HOST
      value: mysql
    - name: ROUNDCUBEMAIL_DB_PORT
      value: "3306"
    - name: ROUNDCUBEMAIL_DB_USER
      value: roundcube
    - name: ROUNDCUBEMAIL_DB_PASSWORD
      value: "123456789"
    - name: ROUNDCUBEMAIL_DEFAULT_HOST
      value: imap.timeweb.ru
    - name: ROUNDCUBEMAIL_SMTP_SERVER
      value: smtp.timeweb.ru
```

                                            2/2

-------------------------------------------------

-> # Создание Service для roundcube <-

> 03-service-roundcube.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: roundcube
spec:
  selector:
    app: roundcube
  clusterIP: None
  ports:
  - name: web
    port: 80
    targetPort: 80
```

-------------------------------------------------

-> # Создание Ingress для roundcube <-

> 04-ingress-roundcube

```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: roundcube
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: roundcube.kubernetes-cluster.ru
    http:
      paths:
      - path: /
        backend:
          serviceName: roundcube
          servicePort: 80
```

-------------------------------------------------

-> # Создание Certificate для roundcube <-

> 05-certificate-roundcube.yaml

```
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: roundcube
spec:
  secretName: roundcube
  commonName: roundcube.kubernetes-cluster.ru
  issuerRef:
    name: letsencrypt
    kind: ClusterIssuer
```

-------------------------------------------------

-> # Создание TLS Ingress для roundcube <-

> 06-ingress-tls-roundcube.yaml

```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: roundcube
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
...
```

                                            1/2

-------------------------------------------------

-> # Создание TLS Ingress для roundcube <-

> 06-ingress-tls-roundcube.yaml

```
...
  tls:
  - hosts:
    - roundcube.kubernetes-cluster.ru
    secretName: roundcube
  rules:
  - host: roundcube.kubernetes-cluster.ru
    http:
      paths:
      - path: /
        backend:
          serviceName: roundcube
          servicePort: 80

```

                                            2/2

-------------------------------------------------

-> # Масштабируем roundcube <-

-------------------------------------------------

-> # ReplicaSet <-

> 07-replicaset-roundcube.yaml

```
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: roundcube
spec:
  replicas: 3
  selector:
    matchLabels:
      app: roundcube
  template:
    metadata:
      labels:
        app: roundcube
    spec:
...
```

                                            1/2

-------------------------------------------------

-> # ReplicaSet <-

```
...
      containers:
      - name: roundcube
        image: roundcube/roundcubemail
        env:
        - name: ROUNDCUBEMAIL_DB_TYPE
          value: mysql
        - name: ROUNDCUBEMAIL_DB_HOST
          value: mysql
        - name: ROUNDCUBEMAIL_DB_PORT
          value: "3306"
        - name: ROUNDCUBEMAIL_DB_USER
          value: roundcube
        - name: ROUNDCUBEMAIL_DB_PASSWORD
          value: "123456789"
        - name: ROUNDCUBEMAIL_DEFAULT_HOST
          value: imap.timeweb.ru
        - name: ROUNDCUBEMAIL_SMTP_SERVER
          value: smtp.timeweb.ru
```

                                            2/2

-------------------------------------------------

-> # Чиним roundcube <-

> 08-ingress-roundcube-session-affinity.yaml

```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: roundcube
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/affinity: cookie
spec:
  tls:
  - hosts:
    - roundcube.kubernetes-cluster.ru
    secretName: roundcube
  rules:
  - host: roundcube.kubernetes-cluster.ru
    http:
      paths:
      - path: /
        backend:
          serviceName: roundcube
          servicePort: 80
```

-------------------------------------------------

-> # Продолжая улучшать roundcube <-

-------------------------------------------------

-> # Deployment <-

> 09-deployment-roundcube.yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: roundcube
spec:
  replicas: 3
  selector:
    matchLabels:
      app: roundcube
  template:
    metadata:
      labels:
        app: roundcube
    spec:
...
```

                                            1/2

-------------------------------------------------

-> # Deployment <-

```
...
      containers:
      - name: roundcube
        image: roundcube/roundcubemail
        env:
        - name: ROUNDCUBEMAIL_DB_TYPE
          value: mysql
        - name: ROUNDCUBEMAIL_DB_HOST
          value: mysql
        - name: ROUNDCUBEMAIL_DB_PORT
          value: "3306"
        - name: ROUNDCUBEMAIL_DB_USER
          value: roundcube
        - name: ROUNDCUBEMAIL_DB_PASSWORD
          value: "123456789"
        - name: ROUNDCUBEMAIL_DEFAULT_HOST
          value: imap.timeweb.ru
        - name: ROUNDCUBEMAIL_SMTP_SERVER
          value: smtp.timeweb.ru
```

                                            2/2

-------------------------------------------------

-> # Не забываем о важном <-

> 10-pvc-mysql.yaml

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 2Gi
```

                                            1/3

-------------------------------------------------

-> # Не забываем о важном <-

> 11-pod-mysql-with-pvc.yaml

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
    ports:
    - containerPort: 3306
...
```

                                            2/3

-------------------------------------------------

-> # Не забываем о важном <-

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
    volumeMounts:
    - name: mysql
      mountPath: "/var/lib/mysql"
  volumes:
  - name: mysql
    persistentVolumeClaim:
      claimName: mysql
```

                                            3/3
