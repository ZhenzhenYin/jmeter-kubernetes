# Jmeter Cluster Support for Kubernetes and OpenShift

## Prerequisits

Kubernetes > 1.8

OpenShift version > 3.5

N.B.: this implementation was tested on Kubernetes 1.9, 1.10, and 1.11 and OpenShift 3.5 and 3.10 (minishift)

make sure kubectl version > 1.8
tested 1.8.5 has a bug of kubectl cp file renaming

## TL;DR

```bash
./dockerimages.sh
./jmeter_cluster_create.sh
./dashboard.sh
./start_test.sh
```
or use
```
./start_test_csv.sh foldername testsuffix 
```

Please follow the guide "Load Testing Jmeter On Kubernetes" on our medium blog post:

https://goo.gl/mkoX9E
