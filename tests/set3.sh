#!/bin/bash

source="$1"
sink="$2"

# other variables
ns="k8s-networking-live-test"
# source_image="nicolaka/netshoot:latest" # alpine based
source_image="amouat/network-utils:latest" # debian based

echo "1. Cleaning out workdir..."
mkdir -p workdir
rm workdir/set3.yaml

echo "2. Parameterize resource definitions..."
cp resources/set3.yaml workdir/
sed -i "s/SOURCE_NODE/$source/" workdir/set3.yaml
sed -i "s/SINK_NODE/$sink/" workdir/set3.yaml
sed -i "s|SOURCE_IMAGE|$source_image|" workdir/set3.yaml

echo "3. Deploy source and sink resources..."
kubectl -n $ns apply -f ./workdir/set3.yaml

echo "   Wait for them to come up..."
kubectl -n $ns wait --for=condition=Ready pod/set3-source
kubectl -n $ns wait --for=condition=Ready pod/set3-sink1

echo "4. Lookup IPs..."
sink1_ip=$(kubectl -n $ns describe pod/set3-sink1 | grep "^IP: " | awk '{print $2}')
sink3_svc_ip=$(kubectl -n $ns describe service/set3-sink3-svc | grep "^IP: " | awk '{print $2}')

echo "sink-1 Pod IP: $sink1_ip"

echo -e "\nCases:"

echo "C4. Nping test. TCP. To pod. (no kube-proxy, no kube-dns)"
kubectl -n $ns exec -it set3-source -- nping --tcp -p 5201 $sink1_ip | tail -n2 | head -n1

echo "C5. Nping test. TCP. To service without cluster ip. (no kube-proxy, kube-dns)"
kubectl -n $ns exec -it set3-source -- nping --tcp -p 5201 set3-sink2-svc | tail -n2 | head -n1

echo "C6. Nping test. TCP. To service IP. (kube-proxy, no kube-dns)"
kubectl -n $ns exec -it set3-source -- nping --tcp -p 5201 $sink3_svc_ip | tail -n2 | head -n1

echo "C7. Nping test. TCP. To service. (kube-proxy, kube-dns)"
kubectl -n $ns exec -it set3-source -- nping --tcp -p 5201 set3-sink3-svc | tail -n2 | head -n1
