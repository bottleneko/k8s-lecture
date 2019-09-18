%title: Базовые абстракции в Kubernetes. Лекция
%author: b.murashov
%date: 2019-09-19

-------------------------------------------------

-> # Agenda <-

* Disclaimer
* Pod и что он из себя представляет
  - Отличия от Docker-контейнера
  - Что дает нам Pod
  - Как создаются pod'ы?
  - Создание простейшего pod через kubectl
  - Создание простейшего pod из файла-манифеста
  - Эксплуатация
  - Проблемы подобного Podхода

                                            1/4

-------------------------------------------------

-> # Agenda <-

* ReplicaSet
  - Создание из файла-манифеста
  - Эксплуатация
  - Недостатки
* Deployment
  - Создание из файла-манифеста
  - Эксплуатация
* PersistentVolumeClaim
  - Создание из файла-манифеста
  - Использование в Pod
  - Эксплуатация
  - Недостатки

                                            2/4

-------------------------------------------------

-> # Agenda <-

* Service
  - Создание из файла-манифеста
* StatefulSet
  - Создание из файла-манифеста
  - Тестирование
  - Эксплуатация

                                            3/4

-------------------------------------------------

-> # Disclaimer <-

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

-------------------------------------------------

-> # Эксплуатация <-

```
$ kubectl get pvc
```

-------------------------------------------------

-> # Недостатки <-

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
