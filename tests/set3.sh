#!/bin/bash

source="$1"
sink="$2"

# other variables
ns="k8s-networking-live-test"
# source_image="nicolaka/netshoot:latest" # alpine based
source_image="amouat/network-utils:latest" # debian based

echo "1. Cleaning out workdir..."
rm -rf workdir/
mkdir workdir

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

echo "5. nping sink-1 from source..."
kubectl -n $ns exec -it set3-source -- nping --tcp -p 5201 $sink1_ip | tail -n2 | head -n1

echo "6. nping sink-2 from source..."
kubectl -n $ns exec -it set3-source -- nping --tcp -p 5201 set3-sink2-svc | tail -n2 | head -n1

echo "7. nping sink-3 IP from source..."
kubectl -n $ns exec -it set3-source -- nping --tcp -p 5201 $sink3_svc_ip | tail -n2 | head -n1

echo "8. nping sink-3 svc name from source..."
kubectl -n $ns exec -it set3-source -- nping --tcp -p 5201 set3-sink3-svc | tail -n2 | head -n1
