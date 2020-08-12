```yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  creationTimestamp: "2020-08-05T06:34:18Z"
  generation: 1
  name: mesh-expansion-hello2-svc
  namespace: migrant-hello
  resourceVersion: "19046461"
  selfLink: /apis/networking.istio.io/v1alpha3/namespaces/migrant-hello/serviceentries/mesh-expansion-hello2-svc
  uid: bccecf6f-2408-4af0-8b67-ff368dd2e689
spec:
  hosts:
  - hello2-svc.migrant-hello.svc.cluster.local
  location: MESH_INTERNAL
  ports:
  - name: http-8001
    number: 8001
    port: 0
    protocol: HTTP
  resolution: STATIC
  workloadSelector:
    labels:
      app: hello-workload
```