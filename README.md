# k8s Networking Live Test

Test networking connectivity within a k8s cluster. A single test that checks various combinations of pod networking, service networking (kube-proxy) and DNS resolution.

Uses:
1. Debugging networking issues by isolating faults in the components.
2. Sanity check configuration changes in the networking components (like CoreDNS configuration or Pod networking CNI plugin changes).

## About the Tests

A test must happen between 2 nodes:
1. A source
2. A sink

Source and sink nodes can be set to the same value.

In what follows, we will refer to a resource X running on source(sink) node as source(sink) X.

Each test consists of the following cases:
1. A `ping` test from a source pod to a sink pod. Shows that pod networking is working correctly.
2. A `nslookup` from a source pod for a sink service without a clusterIP. Test kube-dns resoltion of pod ips.
3. A `nslookup` from a source pod for a sink service with a clusterIP. Test kube-dns resolution of service ips.
4. A `nping` test from a source pod to a TCP sink pod. Data transfer with (NO kube-proxy and NO kube-dns).
5. A `nping` test from a source pod to a TCP sink service without a clusterIP. Data transfer with (NO kube-proxy and YES kube-dns).
6. A `nping` test from a source pod to a TCP sink service clusterIP directly. Data transfer with (YES kube-proxy and NO kube-dns).
7. A `nping` test from a source pod to a TCP sink service with clusterIP. Data transfer with (YES kube-proxy and YES kube-dns).

## Running the Tests

Create a namespace for the tests:
```
kubectl create namespace k8s-networking-live-test
```
All test pods/services will be spawned within this namespace.

To run the tests:
```
./run.sh <source node> <sink node>
```
The source and sink nodes should be specified using the names that comes up when running `kubectl get nodes`.
