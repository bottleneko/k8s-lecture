%title: Базовые абстракции в Kubernetes. Лекция
%author: b.murashov
%date: 2019-09-19

-------------------------------------------------

-> # Disclaimer <-

-------------------------------------------------

-> # Agenda <-

* Pod и что он из себя представляет
  - Отличия от Docker-контейнера
  - Что дает нам Pod
  - Как создаются pod'ы?
  - Создание простейшего pod через kubectl
  - Создание простейшего pod из файла-манифеста
  - Эксплуатация
  - Проблемы подобного Podхода

                                            1/3

-------------------------------------------------

-> # Agenda <-

* ReplicaSet
  - Создание из файла-манифеста
  - Эксплуатация
  - Недостатки
* Deployment
  - Создание из файла-манифеста
  - Обновление
  - Эксплуатация
* PersistentVolumeClaim
  - Создание из файла-манифеста
  - Использование в Pod
  - Эксплуатация
  - Недостатки

                                            2/3

-------------------------------------------------

-> # Agenda <-

* Service
  - Создание из файла-манифеста
* StatefulSet
  - Создание из файла-манифеста
  - Тестирование
  - Эксплуатация
* Ingress
  - Создание из файла-манифеста
  - Тестирование
  - Эксплуатация
* Итоги
* Что почитать
                                            3/3

-------------------------------------------------

-> # Pod и что он из себя представляет <-

-------------------------------------------------

-> # Отличия от Docker-контейнера <-

-------------------------------------------------

-> # Что дает нам Pod <-

-------------------------------------------------

-> # Как создаются pod'ы? <-

-------------------------------------------------

-> # Создание простейшего pod через kubectl <-

```
$ kubectl run --generator=run-pod/v1 --image=alpine foo sleep 1h
```

```
$ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
foo    1/1     Running   0          7s
```

-------------------------------------------------

-> # Создание простейшего pod из файла-манифеста <-

```
$ cat <<EOF > 00-bar.yaml
apiVersion: v1
kind: Pod
metadata:
  name: bar
spec:
  containers:
  - name: bar
    image: alpine
    command: ["/bin/sh"]
EOF

$ kubectl apply -f 00-bar.yaml

$ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
bar    1/1     Running   0          6s
foo    1/1     Running   0          9m53s
```

-------------------------------------------------

-> # Эксплуатация <-

```
$ kubectl logs bar

$ kubectl exec -it bar sh

$ kubectl describe pod bar

$ kubectl delete pod bar
```

-------------------------------------------------

-> # Проблемы подобного Podхода <-

-------------------------------------------------

-> # ReplicaSet <-

-------------------------------------------------

-> # Создание из файла-манифеста <-

```
$ cat <<EOF > 01-bar.yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: bar
spec:
  replicas: 3
  selector:
    matchLabels:
      app: bar
  template:
    metadata:
      labels:
        app: bar
    spec:
      containers:
      - name: bar
        image: alpine
        command: ["/bin/sh"]
        args: ["-c", "trap 'exit 0' 15;while true; do exec sleep 100 & wait $!; done"]
EOF

$ kubectl apply -f 01-bar.yaml
```

                                            1/2

-------------------------------------------------

-> # Создание из файла-манифеста <-

```
$ kubectl get pods
NAME        READY   STATUS    RESTARTS   AGE
bar         1/1     Running   1          39m
bar-78mnv   1/1     Running   0          12s
bar-f675p   1/1     Running   0          12s
bar-w688v   1/1     Running   0          12s
foo         1/1     Running   1          74m
```

                                            2/2

-------------------------------------------------

-> # Эксплуатация <-

```
$ kubectl scale replicaset bar --replicas=5

$ kubectl delete replicaset bar
```

-------------------------------------------------

-> # Недостатки <-

-------------------------------------------------

-> # Deployment <-

-------------------------------------------------

-> # Создание из файла-манифеста <-

```
$ cat <<EOF > 02-bar.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bar
spec:
  replicas: 3
  selector:
    matchLabels:
      app: bar
  template:
    metadata:
      labels:
        app: bar
    spec:
      containers:
      - name: bar
        image: alpine
        command: ["/bin/sh"]
        args: ["-c", "trap 'exit 0' 15;while true; do exec sleep 100 & wait $!; done"]
EOF

$ kubectl apply -f 02-bar.yaml
```

                                            1/2

-------------------------------------------------

-> # Создание из файла-манифеста <-

```
$ kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
bar-65dbfbcf46-fjmwj   1/1     Running   0          5m18s
bar-65dbfbcf46-mcv5j   1/1     Running   0          5m18s
bar-65dbfbcf46-wb8s6   1/1     Running   0          5m18s
#+END_EXAMPLE
```

                                            2/2

-------------------------------------------------

-> # Обновление Deployment'а <-

```
$ sed -i 's/alpine/debian:stable-slim/g' 02-bar.yaml
$ kubectl apply -f 02-bar.yaml
deployment.apps/bar configured
$ kubectl get pods
NAME                   READY   STATUS              RESTARTS   AGE
bar-65dbfbcf46-fjmwj   1/1     Running             0          7m13s
bar-65dbfbcf46-mcv5j   1/1     Running             0          7m13s
bar-65dbfbcf46-wb8s6   1/1     Running             0          7m13s
bar-68c6b49ffc-mvqfk   0/1     ContainerCreating   0          4s

$ kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
bar-68c6b49ffc-5lm9l   1/1     Running   0          54s
bar-68c6b49ffc-mvqfk   1/1     Running   0          65s
bar-68c6b49ffc-nkw55   1/1     Running   0          61s
```

-------------------------------------------------

-> # Эксплуатация <-

```
$ kubectl scale deployment bar --replicas=5

$ kubectl delete deployment bar
```

-------------------------------------------------

-> # PersistentVolumeClaim <-

-------------------------------------------------

-> # Создание из файла-манифеста <-

```
$ cat <<EOF > 03-baz-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: baz
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 2Gi
EOF

$ kubectl apply -f 03-baz-pvc.yaml
```

-------------------------------------------------

-> # Использование в Pod <-

```
$ cat <<EOF > 03-baz.yaml
apiVersion: v1
kind: Pod
metadata:
  name: baz
spec:
  containers:
    - name: baz
      image: alpine
      command: ["/bin/sh"]
      args: ["-c", "trap 'exit 0' 15;while true; do exec sleep 100 & wait $!; done"]
      volumeMounts:
        - mountPath: "/pvc"
          name: baz
  volumes:
    - name: baz
      persistentVolumeClaim:
        claimName: baz
EOF

$ kubectl apply -f 03-baz.yaml
```

                                            1/3

-------------------------------------------------

-> # Использование в Pod <-

```
total 8
drwxr-xr-x    2 root     root          4096 Sep 18 04:18 .
drwxr-xr-x    1 root     root          4096 Sep 18 04:22 ..
$ kubectl exec baz touch -- /pvc/test
$ kubectl exec baz ls -- -la /pvc
total 8
drwxr-xr-x    2 root     root          4096 Sep 18 04:24 .
drwxr-xr-x    1 root     root          4096 Sep 18 04:23 ..
-rw-r--r--    1 root     root             0 Sep 18 04:24 test
$ kubectl exec baz kill -- 1
$ kubectl get pods
NAME   READY   STATUS      RESTARTS   AGE
baz    0/1     Completed   0          2m41s
```

                                            2/3

-------------------------------------------------

-> # Использование в Pod <-

```
$ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
baz    1/1     Running   1          2m46s
$ kubectl exec baz ls -- -la /pvc
total 8
drwxr-xr-x    2 root     root          4096 Sep 18 04:24 .
drwxr-xr-x    1 root     root          4096 Sep 18 04:24 ..
-rw-r--r--    1 root     root             0 Sep 18 04:24 test
```

                                            3/3

-------------------------------------------------

-> # Эксплуатация <-

```
$ kubectl get pvc
```

-------------------------------------------------

-> # Недостатки <-

-------------------------------------------------

-> # Service <-

-------------------------------------------------

-> # Создание из файла-манифеста <-

```
$ cat <<EOF > 04-bar-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: bar
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: bar

$ kubectl apply -f 04-bar-service.yaml
```

-------------------------------------------------

-> # StatefulSet <-

-------------------------------------------------

-> # Создание из файла-манифеста <-

```
$ cat <<EOF > 04-bar.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: bar
spec:
  selector:
    matchLabels:
      app: bar
  replicas: 2
  serviceName: bar
  template:
    metadata:
      labels:
        app: bar
```

                                           1/2

-------------------------------------------------

-> # Создание из файла-манифеста <-

```
    spec:
      containers:
      - name: nginx
        image: nginxdemos/hello:plain-text
        volumeMounts:
        - name: bar
          mountPath: /pvc
  volumeClaimTemplates:
  - metadata:
      name: bar
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 2Gi
EOF

$ kubectl apply -f 03-baz.yaml
```

                                           2/2

-------------------------------------------------

-> # Тестирование <-

```
$ kubectl run --generator=run-pod/v1 --image=alpine test sleep 1h
pod/test created
$ kubectl exec -it test sh
/ # apk add --no-cache curl
/ # curl bar
Server address: 192.168.234.114:80
Server name: bar-1
Date: 18/Sep/2019:05:55:16 +0000
URI: /
Request ID: e31f3fb14ff1cf8264d684bedc2c0200
/ # curl bar
Server address: 192.168.234.113:80
Server name: bar-0
Date: 18/Sep/2019:05:55:17 +0000
URI: /
Request ID: 97fc549c450ef1360a966eb92af1f8f3
#+END_EXAMPLE
```

-------------------------------------------------

-> # Эксплуатация <-

```
$ kubectl scale statefulset bar --replicas=5

$ kubectl delete statefulset bar
```

-------------------------------------------------

-> # Ingress <-

-------------------------------------------------

-> # Создание из файла-манифеста <-

```
$ cat <<EOF > 05-bar.yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: bar
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: bar.kubernetes-cluster.ru
    http:
      paths:
      - path: /
        backend:
          serviceName: bar
          servicePort: 80
EOF

$ kubectl apply -f 05-bar.yaml
```

-------------------------------------------------

-> # Тестирование <-

```
$ curl bar.kubernetes-cluster.ru
Server address: 192.168.234.114:80
Server name: bar-1
Date: 18/Sep/2019:16:36:49 +0000
URI: /
Request ID: 730fad0ffc846fdb46c41dfaa6a9cd47
$ curl bar.kubernetes-cluster.ru
Server address: 192.168.234.113:80
Server name: bar-0
Date: 18/Sep/2019:16:36:53 +0000
URI: /
Request ID: 13ca2d835ef9f3f38091a1e5aa8e059b
```

-------------------------------------------------

-> # Эксплуатация <-

```
$ kubectl delete ingress bar
```

-------------------------------------------------

-> # Итоги <-

-------------------------------------------------

-> # Что почитать <-

* Kubernetes in Action (книга, есть перевод на русский)
* [Официальная документация по Kubernetes](https://kubernetes.io/docs/home/)
* [Официальная документация по Helm](https://helm.sh/docs/)
