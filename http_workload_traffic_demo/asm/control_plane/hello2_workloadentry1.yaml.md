```yaml
apiVersion: networking.istio.io/v1alpha3
kind: WorkloadEntry
metadata:
  creationTimestamp: "2020-08-05T06:34:18Z"
  generation: 1
  name: mesh-expansion-hello2-svc-1
  namespace: external-hello
  resourceVersion: "19046465"
  selfLink: /apis/networking.istio.io/v1alpha3/namespaces/external-hello/workloadentries/mesh-expansion-hello2-svc-1
  uid: 5288aa26-116b-4096-bb19-452ae9b37a4e
spec:
  address: 192.168.0.170
  labels:
    app: hello-workload
```