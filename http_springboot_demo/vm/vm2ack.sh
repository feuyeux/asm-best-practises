export HTTP_HELLO_BACKEND=hello3-svc.hello.svc.cluster.local
nohup java -jar /var/lib/http-hello-fr.jar >/dev/null 2>&1 &
curl localhost:8001/hello/abc
echo

export HTTP_HELLO_BACKEND=hello3-svc.hello.svc.cluster.local
nohup java -jar /var/lib/http-hello-es.jar >/dev/null 2>&1 &
curl localhost:8001/hello/abc
echo