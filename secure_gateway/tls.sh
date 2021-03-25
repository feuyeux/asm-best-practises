#!/usr/bin/env bash
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit
#
USER_CONFIG=$HOME/shop_config/kubeconfig/ack_production
MESH_CONFIG=$HOME/shop_config/kubeconfig/asm_production
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"
version=1.8.4
export ISTIO_HOME=${HOME}/shop/istio-${version}
timestamp=$(date "+%Y%m%d-%H%M%S")

#
clean() {
    m delete virtualservice httpbin
    m delete gateway httpbin-gateway
    m delete virtualservice httpbin-tls-vs
    m delete gateway httpbin-tls-gateway
    k delete --ignore-not-found=true -n istio-system secret httpbin-credential helloworld-credential
    m delete --ignore-not-found=true virtualservice helloworld-v1
    rm -rf example.com.crt example.com.key httpbin.example.com.crt httpbin.example.com.key httpbin.example.com.csr \
        helloworld-v1.example.com.crt helloworld-v1.example.com.key helloworld-v1.example.com.csr client.example.com.crt \
        client.example.com.csr client.example.com.key ./new_certificates
    k delete deployment --ignore-not-found=true httpbin helloworld-v1
    k delete service --ignore-not-found=true httpbin helloworld-v1
    sleep 3
}

before_begin() {
    ## Before you begin(https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/#before-you-begin)
    echo "==== 1 httpbin http(80) ===="
    k apply -f ${ISTIO_HOME}/samples/httpbin/httpbin.yaml
    m apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: httpbin-gateway
spec:
  selector:
    istio: ingressgateway # use Istio default gateway implementation
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "httpbin.example.com"
EOF
    m apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
  - "httpbin.example.com"
  gateways:
  - httpbin-gateway
  http:
  - match:
    - uri:
        prefix: /status
    - uri:
        prefix: /delay
    route:
    - destination:
        port:
          number: 8000
        host: httpbin
EOF
    sleep 5
    export INGRESS_HOST=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    export INGRESS_PORT=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
    export SECURE_INGRESS_PORT=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
    export TCP_INGRESS_PORT=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')
    echo "INGRESS_HOST=$INGRESS_HOST"
    echo "INGRESS_PORT=$INGRESS_PORT"
    echo "SECURE_INGRESS_PORT=$SECURE_INGRESS_PORT"
    curl -s -I -HHost:httpbin.example.com "http://$INGRESS_HOST:$INGRESS_PORT/status/200"
}
create_secret() {
    # docker-registry 创建一个给 Docker registry 使用的 secret
    # generic         从本地 file, directory 或者 literal value 创建一个 secret
    # tls             创建一个 TLS secret
    secret_flag=tls
    k -n istio-system create secret $secret_flag \
        httpbin-credential-$timestamp \
        --key=httpbin.example.com.key \
        --cert=httpbin.example.com.crt
}
create_secret_2() {
    k create -n istio-system secret tls \
        httpbin-credential-$timestamp \
        --key=new_certificates/httpbin.example.com.key \
        --cert=new_certificates/httpbin.example.com.crt
}
setup_tls() {
    echo
    echo "==== 2 httpbin tls(443) ===="
    # Generate client and server certificates and keys
    # https://istio.io/latest/docs/tasks/traffic-management/ingress/secure-ingress/#generate-client-and-server-certificates-and-keys
    echo "Create a root certificate and private key to sign the certificates for your services:"
    openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' \
        -keyout example.com.key \
        -out example.com.crt
    echo "Create a certificate and a private key for httpbin.example.com:"
    openssl req -newkey rsa:2048 -nodes -subj "/CN=httpbin.example.com/O=httpbin organization" \
        -keyout httpbin.example.com.key \
        -out httpbin.example.com.csr

    openssl x509 -req -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 \
        -in httpbin.example.com.csr \
        -out httpbin.example.com.crt

    ls -hlt
    # -rw-r--r--  1 han  staff   1.0K  3 24 14:31 httpbin.example.com.crt
    # -rw-r--r--  1 han  staff   948B  3 24 14:31 httpbin.example.com.csr
    # -rw-r--r--  1 han  staff   1.7K  3 24 14:31 httpbin.example.com.key
    # -rw-r--r--  1 han  staff   1.0K  3 24 14:30 example.com.crt
    # -rw-r--r--  1 han  staff   1.7K  3 24 14:30 example.com.key

    # Configure a TLS ingress gateway for a single host
    # https://istio.io/latest/docs/tasks/traffic-management/ingress/secure-ingress/#configure-a-tls-ingress-gateway-for-a-single-host

    echo "Create a secret for the ingress gateway:"
    create_secret
    sleep 10
}

setup_tls_mesh() {
    echo "Define a gateway for ingressgateway:"
    m apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: httpbin-tls-gateway
spec:
  selector:
    istio: ingressgateway # use istio default ingress gateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: httpbin-credential-$timestamp # must be the same as secret
    hosts:
    - httpbin.example.com
EOF
    m apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin-tls-vs
spec:
  hosts:
  - "httpbin.example.com"
  gateways:
  - httpbin-tls-gateway
  http:
  - match:
    - uri:
        prefix: /status
    - uri:
        prefix: /delay
    route:
    - destination:
        port:
          number: 8000
        host: httpbin
EOF
    sleep 10
}

test_tls() {
    echo "\n==== curl httpbin.example.com:$SECURE_INGRESS_PORT => $INGRESS_HOST ===="
    curl -v -HHost:httpbin.example.com \
        --resolve "httpbin.example.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" \
        --cacert example.com.crt \
        "https://httpbin.example.com:$SECURE_INGRESS_PORT/status/418"
}

test_new_cert() {
    echo "\n==== 3 change certs/keys ===="
    echo "Delete the gateway’s secret and create a new one to change the ingress gateway’s credentials"
    k -n istio-system delete secret httpbin-credential-$timestamp
    mkdir new_certificates
    openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' \
        -keyout new_certificates/example.com.key \
        -out new_certificates/example.com.crt
    openssl req -newkey rsa:2048 -nodes -subj "/CN=httpbin.example.com/O=httpbin organization" \
        -keyout new_certificates/httpbin.example.com.key \
        -out new_certificates/httpbin.example.com.csr
    openssl x509 -req -days 365 -CA new_certificates/example.com.crt -CAkey new_certificates/example.com.key -set_serial 0 \
        -in new_certificates/httpbin.example.com.csr \
        -out new_certificates/httpbin.example.com.crt
    #
    create_secret_2

    export INGRESS_HOST=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}') \
    export SECURE_INGRESS_PORT=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

    for ((n = 1; n <= 10; n++)); do
        sleep 6
        echo "\n ==== [$n] curl httpbin.example.com:$SECURE_INGRESS_PORT => $INGRESS_HOST ===="
        curl -v -HHost:httpbin.example.com --resolve "httpbin.example.com:$SECURE_INGRESS_PORT:$INGRESS_HOST" \
            --cacert new_certificates/example.com.crt \
            "https://httpbin.example.com:$SECURE_INGRESS_PORT/status/418"
    done
}

clean
before_begin
setup_tls
setup_tls_mesh
test_tls
test_new_cert

echo "kubectl --kubeconfig $USER_CONFIG -n istio-system delete secret httpbin-credential-$timestamp" >clean
