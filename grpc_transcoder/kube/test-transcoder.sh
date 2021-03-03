#!/usr/bin/env bash
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1 || exit
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit
. config.env
alias k="kubectl --kubeconfig $ACK_KUBECONFIG"

# client_java_pod=$(k get pod -l app=grpc-client-java -n grpc-best -o jsonpath={.items..metadata.name})
# echo "[test talk] from $client_java_pod"
# k exec "$client_java_pod" -c grpc-client-java -n grpc-best -- java -jar /grpc-client.jar

INGRESS_IP=$(k -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "INGRESS_IP=$INGRESS_IP"
echo "[test talk] curl http://$INGRESS_IP:9996/v1/talk/0/java"
curl -H 'x:aaa' -H 'y:bbb' -H 'a:xxx' -H 'b:yyy' http://$INGRESS_IP:9996/v1/talk/0/java
# echo
# echo "2 [test talk1n] http://$INGRESS_IP:9996/v1/talk1n/0,1,2/java"
# curl -H 'x:abc' -H 'y:cba' http://$INGRESS_IP:9996/v1/talk1n/0,1,2/java
# echo
# echo "3 [test talkn1] curl -XPOST http://$INGRESS_IP:9996/v1/talkn1"
# curl -XPOST http://$INGRESS_IP:9996/v1/talkn1 \
#   -H 'x:abc' \
#   -H 'y:cba' \
#   -d '[
#     {
#         "data":"0",
#         "meta":"java"
#     },
#     {
#         "data":"1",
#         "meta":"java"
#     }
# ]'
# echo
# echo "4 [test talknn] curl -XPOST http://$INGRESS_IP:9996/v1/talknn"
# curl -XPOST http://$INGRESS_IP:9996/v1/talknn \
#   -H 'x:abc' \
#   -H 'y:cba' \
#   -d '[
#     {
#         "data":"2",
#         "meta":"java"
#     },
#     {
#         "data":"3",
#         "meta":"java"
#     }
# ]'