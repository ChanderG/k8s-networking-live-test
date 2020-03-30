#!/bin/bash

source="$1"
sink="$2"

# other variables
ns="k8s-networking-live-test"
# needs to have nslookup and bash installed out of the box, will not work otherwise
# source_image="busybox:latest" # does not work
# source_image="nicolaka/netshoot:latest" # works - alpine based
source_image="amouat/network-utils:latest" # works - debian based

echo "1. Cleaning out workdir..."
rm -rf workdir/
mkdir workdir

echo "2. Parameterize resource definitions..."
cp resources/set2.yaml workdir/
sed -i "s/SOURCE_NODE/$source/" workdir/set2.yaml
sed -i "s/SINK_NODE/$sink/" workdir/set2.yaml
sed -i "s|SOURCE_IMAGE|$source_image|" workdir/set2.yaml

echo "3. Deploy source and sink resources..."
kubectl -n $ns apply -f ./workdir/set2.yaml

echo "   Wait for them to come up..."
kubectl -n $ns wait --for=condition=Ready pod/set2-source
kubectl -n $ns wait --for=condition=Available deployment/set2-sink-depl1
kubectl -n $ns wait --for=condition=Available deployment/set2-sink-depl2

echo "4. Lookup CoreDNS paramters - service IP and pod IP..."
dns_svc_ip=$(kubectl -n kube-system describe service/kube-dns | grep "^IP: " | awk '{print $2}')
dns_pod_ip=$(kubectl -n kube-system describe pod $(kubectl -n kube-system get pods -l k8s-app=kube-dns | tail -n1 | awk '{print $1}') | grep "^IP: " | awk '{print $2}')

echo "Service IP: $dns_svc_ip"
echo "Pod IP: $dns_pod_ip"

echo "5. Copy the looper script into the source pod..."
kubectl -n $ns cp ./helpers/looper.sh set2-source:/bin/looper.sh

echo "6. Lookup sink-1 from source..."
printf "Lookup with default DNS: "
kubectl -n $ns exec -it set2-source -- /bin/looper.sh "nslookup set2-sink-svc1"
printf "Lookup with DNS service IP: "
kubectl -n $ns exec -it set2-source -- /bin/looper.sh "nslookup set2-sink-svc1 $dns_svc_ip"
printf "Lookup with DNS pod IP: "
kubectl -n $ns exec -it set2-source -- /bin/looper.sh "nslookup set2-sink-svc1 $dns_pod_ip"

echo "7. Lookup sink-2 from source..."

printf "Lookup with default DNS: "
kubectl -n $ns exec -it set2-source -- /bin/looper.sh "nslookup set2-sink-svc2"
printf "Lookup with DNS service IP: "
kubectl -n $ns exec -it set2-source -- /bin/looper.sh "nslookup set2-sink-svc2 $dns_svc_ip"
printf "Lookup with DNS pod IP: "
kubectl -n $ns exec -it set2-source -- /bin/looper.sh "nslookup set2-sink-svc2 $dns_pod_ip"
