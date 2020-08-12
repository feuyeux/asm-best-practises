```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: "2020-08-05T06:34:18Z"
  labels:
    app: hello-workload
  name: hello2-svc
  namespace: migrant-hello
  resourceVersion: "42870249"
  selfLink: /api/v1/namespaces/migrant-hello/services/hello2-svc
  uid: 44216dcb-4f84-4ac8-8a09-78f4460cca0c
spec:
  clusterIP: 172.19.12.109
  ports:
  - name: http-8001
    port: 8001
    protocol: TCP
    targetPort: 8001
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
```