# k8s-networking-live-test

Test connectivity within a k8s cluster via all networking elements

## About the Tests

A test must happen between 2 nodes:
1. A source
2. A sink

Source and sink nodes can be set to the same value.

In what follows, we will refer to a resource X running on source(sink) node as source(sink) X.

Each test consists of the following:
1. A `ping` test from a source pod to a sink pod. Shows that pod networking is working correctly.
2. A `nslookup` from a source pod for a sink service without a clusterIP. Test kube-dns resoltion of pod ips.
3. A `nslookup` from a source pod for a sink service with a clusterIP. Test kube-dns resolution of service ips.
4. A `nping` test from a source pod to a TCP sink pod. Data transfer with (NO kube-proxy and NO kube-dns).
5. A `nping` test from a source pod to a TCP sink service without a clusterIP. Data transfer with (NO kube-proxy and YES kube-dns).
6. A `nping` test from a source pod to a TCP sink service clusterIP directly. Data transfer with (YES kube-proxy and NO kube-dns).
7. A `nping` test from a source pod to a TCP sink service with clusterIP. Data transfer with (YES kube-proxy and YES kube-dns).

### Possible improvement to the tests

1. Set 2 (2,3 above) can be run 2 modes of DNS settings. Normally (with the CoreDNS service ip) and direct (using the ip of a CoreDNS pod to avoid going via kube-proxy just for the DNS layer).
2. Point 1 above maybe applicable to Set 3 (4-7) as well.

## Running the Tests

Create a namespace for the tests:
```
kubectl create namespace k8s-networking-live-test
```
All test pods/services will be spawned within this namespace.


