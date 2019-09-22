#!/usr/bin/env bash

if [[ -z "$1" ]] ;then
  echo "usage: $0 <username>"
  exit 1
fi

username="$1"

groupadd "$username"
useradd -g "$username" -m -s /bin/bash "$username"
password=$(pwgen | awk '{print $1}' )
echo -e "$password\n$password" | passwd "$username"

su -c "kubectl completion bash > ~/kubectl.bashrc; echo \"source kubectl.bashrc\" >> ~/.bashrc" "$username"

echo "$username:$password" >> workshop.db

kubectl create namespace "$username"
kubectl --namespace "$username" create sa "$username"

secret=$(kubectl --namespace "$username" get sa "$username" -o json | jq -r .secrets[].name)
user_token=$(kubectl --namespace "$username" get secret "$secret" -o json | jq -r '.data["token"]' | base64 --decode)

certificate_authority_data=$(base64 -w 0 /etc/kubernetes/pki/ca.crt)

mkdir "/home/$username/.kube"

cat <<EOF > "/home/$username/.kube/config"
apiVersion: v1
kind: Config
preferences: {}
clusters:
- cluster:
    certificate-authority-data: $certificate_authority_data
    server: https://api.kubernetes-cluster.ru:6443
  name: kubernetes
current-context: $username@$username
users:
- name: $username
  user:
    token: $user_token
contexts:
- context:
    cluster: kubernetes
    namespace: $username
    user: $username
  name: $username@$username
EOF

chown -R "$username":"$username" "/home/$username/.kube"
chmod 755 "/home/$username/.kube"
chmod 600 "/home/$username/.kube/config"

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: $username
  name: $username
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $username
  namespace: $username
subjects:
- kind: ServiceAccount
  name: $username
  namespace: $username
roleRef:
  kind: Role
  name: $username
  apiGroup: rbac.authorization.k8s.io
EOF
