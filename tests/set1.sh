#!/bin/bash

source="$1"
sink="$2"
ns="k8s-networking-live-test"

echo "1. Cleaning out workdir..."
rm -rf workdir/
mkdir workdir

echo "2. Parameterize resource definitions..."
cp resources/set1.yaml workdir/
sed -i "s/SOURCE_NODE/$source/" workdir/set1.yaml
sed -i "s/SINK_NODE/$sink/" workdir/set1.yaml

echo "3. Deploy source and sink pods..."
kubectl -n $ns apply -f ./workdir/set1.yaml

echo "   Wait for them to come up..."
kubectl -n $ns wait --for=condition=Ready -f ./workdir/set1.yaml

echo "4. Obtain sink pod ip..."
sink_ip=$(kubectl -n $ns describe pod/set1-sink | grep "^IP:" | awk '{print $2}')

echo "5. Ping sink from source..."
kubectl -n $ns exec -it set1-source -- ping -c 10 $sink_ip | tail -n2
