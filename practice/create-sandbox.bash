#!/usr/bin/env bash

if [[ -z "$1" ]] ;then
  echo "usage: $0 <username>"
  exit 1
fi

username="$1"

#kubectl create namespace "$username"
#kubectl --namespace "$username" create sa "$username"

secret=$(kubectl --namespace "$username" get sa "$username" -o json | jq -r .secrets[].name)
ca=$(kubectl --namespace "$username" get secret "$secret" -o json | jq -r '.data["ca.crt"]' | base64 -D)
user_token=$(kubectl get secret ${secret} -o json | jq -r '.data["token"]' | base64 -D)

cat <<EOF
apiVersion: v1
kind: Config
preferences: {}
clusters:
- cluster:
    certificate-authority-data: $certificate_authority_data
    server: https://api.kubernetes-cluster.ru:6443
  name: kubernetes
current-context: "$username@$username"
users:
- name: "$username"
  user:
    client-certificate-data: "$ca"
    client-key-data: "$user_token"
contexts:
- context:
    cluster: kubernetes
    namespace: "$username"
    user: "$username"
  name: "$username@$username"
EOF

certificate_authority_data() {
    echo "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNU1EZ3pNREEwTlRBeU4xb1hEVEk1TURneU56QTBOVEF5TjFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTE5PCld2MnlIK2w0SGhvNk5Jd3V5UWdNS1pHWWM2Z2lSK1RYaEZkRG9zRGhUeUhBa1NrcXYwOWFWaEhYdWxsN09yakYKTVFuOGQybXg1Wi80Ymg4WWR5Vy9KMjMwZm5mbmh0OFFOZG80TlNjdVBaU2VoYmViSDZJazlDTSthaUtiNFNqWQpIMHVid3R6dlU1WmVDcTB0VGpjVGNKMmFRaE9ZU1BHNENiNzVVOTdSOUQrd1dlVm9KdHBBR24xWXhSK0Q4ZGZHClZZcmlBai9EcXMyejJ4OXJnSy84blN6NGpEUTk0NVg3aXVRblRUaDA4UUJiTTVlem52SnRrdkRCd2ZHdkozaGUKYi84aHlicjJaQ0gwQU5OeXJHUmFDam5oVk9KVlBHYWZxQkxBOUZwSis2cHc1Ti9IUUw4dGcvUUpnOEpIZ1RVdgpMSHVvSGFMdlVQcUpwQVhLMnNzQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFLKzUxcnpLYTVZM0FrRk9nWVFJZm56M0JET00KWGc3NWs3S2c4czRkZGtJY1RpM2V3STRGa01lNVBHYXlnc21HTkxSa1FjZUZib24rMXlLVmtlUGZyalV5RFY5VwoxTTAzUmhlZG9oQ2FIeUd3b2drVjhOS2VqWTN1UmFwWUJkOFFydjRtRVMxQXRJZzV1amJkUEpRZ1NwWWwrTlVtCmtpL0FvWWZyQXNEelU3ellETWkwZXIxNVBib29xb3FITC8yT2diQURZVzZpakYwSlZqUE9ZUG4wNmhNbGI3SnQKRzMvNjJ1R1lpOTVzc0NsNllBT0pJM0lQTDlZSmxEeFVKdWMweEZ5ZE5Tb1lBM1lLcEwwcEtJQWNQa2dpNTBmcQpndEdKRlF2OXRBR1NYaDFKM2t0bHRyWWg1bjJtZ3d2RmtPczZFS2p0eW9KYy9WVzkrRHJIZ0sva0Fibz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
}
