#!/usr/bin/env bash
# https://istio.io/latest/docs/tasks/security/authorization/authz-jwt/

SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)/"
cd "$SCRIPT_PATH" || exit

USER_CONFIG=~/shop_config/bj_config
MESH_CONFIG=~/shop_config/bj_164_config
ISTIO_HOME=~/shop/istio-1.6.4

POD_TIME_OUT=20s
RA_TIMEOUT=10s

jwt_experiment() {
  echo "0. Initialize"
  kubectl \
    --kubeconfig "$USER_CONFIG" \
    create ns foo >/dev/null 2>&1

  kubectl \
    --kubeconfig "$USER_CONFIG" \
    label ns foo istio-injection=enabled >/dev/null 2>&1

  echo "1. Deploy two workloads: httpbin and sleep"

  kubectl \
    --kubeconfig "$USER_CONFIG" \
    -n foo \
    apply -f "$ISTIO_HOME"/samples/httpbin/httpbin.yaml

  kubectl \
    --kubeconfig "$USER_CONFIG" \
    -n foo \
    apply -f "$ISTIO_HOME"/samples/sleep/sleep.yaml

  echo "wait $POD_TIME_OUT for pod creating ..."
  sleep $POD_TIME_OUT

  kubectl \
    --kubeconfig "$USER_CONFIG" \
    -n foo \
    get po

  echo "2. Verify that sleep successfully communicates with httpbin"

  sleep_pod=$(kubectl --kubeconfig "$USER_CONFIG" get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name})

  RESULT=$(kubectl \
    --kubeconfig "$USER_CONFIG" \
    exec "$sleep_pod" -c sleep -n foo -- curl http://httpbin.foo:8000/ip -s -o /dev/null -w "%{http_code}")

  if [[ $RESULT != "200" ]]; then
    echo "http_code($RESULT) should be 200"
    exit
  fi
  echo "Passed"

  echo "3. Creates the jwt-example request authentication policy"

  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    create ns foo

  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    apply -f jwt-example.yaml

  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    -n foo \
    get requestauthentication

  echo "wait $RA_TIMEOUT seconds for request authentication available ..."
  sleep $RA_TIMEOUT

  echo "4. Verify that a request with an invalid JWT is denied(401)"
  for ((i = 1; i <= 10; i++)); do
    kubectl \
      --kubeconfig "$USER_CONFIG" \
      exec "$sleep_pod" \
      -c sleep \
      -n foo \
      -- curl "http://httpbin.foo:8000/headers" \
      -s \
      -o /dev/null \
      -H "Authorization: Bearer invalidToken" \
      -w "%{http_code}" >/dev/null 2>&1
  done

  for ((i = 1; i <= 5; i++)); do
    RESULT=$(kubectl \
      --kubeconfig "$USER_CONFIG" \
      exec "$sleep_pod" \
      -c sleep \
      -n foo \
      -- curl "http://httpbin.foo:8000/headers" \
      -s \
      -o /dev/null \
      -H "Authorization: Bearer invalidToken" \
      -w "%{http_code}")
    if [[ $RESULT != "401" ]]; then
      echo "http_code($RESULT) should be 401"
      exit
    fi
  done
  echo "Passed"

  echo "5.Verify that a request without a JWT is allowed because there is no authorization policy(200)"

  for ((i = 1; i <= 10; i++)); do
    RESULT=$(kubectl \
      --kubeconfig "$USER_CONFIG" \
      exec "$sleep_pod" \
      -c sleep \
      -n foo \
      -- curl "http://httpbin.foo:8000/headers" \
      -s \
      -o /dev/null \
      -w "%{http_code}")
    if [[ $RESULT != "200" ]]; then
      echo "http_code($RESULT) should be 200"
      exit
    fi
  done
  echo "Passed"

  echo "6. Creates the require-jwt authorization policy"

  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    apply -f require-jwt.yaml

  echo "7. Verify that a request with a valid JWT is allowed(200)"
  TOKEN='eyJhbGciOiJSUzI1NiIsImtpZCI6IkRIRmJwb0lVcXJZOHQyenBBMnFYZkNtcjVWTzVaRXI0UnpIVV8tZW52dlEiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjQ2ODU5ODk3MDAsImZvbyI6ImJhciIsImlhdCI6MTUzMjM4OTcwMCwiaXNzIjoidGVzdGluZ0BzZWN1cmUuaXN0aW8uaW8iLCJzdWIiOiJ0ZXN0aW5nQHNlY3VyZS5pc3Rpby5pbyJ9.CfNnxWP2tcnR9q0vxyxweaF3ovQYHYZl82hAUsn21bwQd9zP7c-LS9qd_vpdLG4Tn1A15NxfCjp5f7QNBUo-KC9PJqYpgGbaXhaGx7bEdFWjcwv3nZzvc7M__ZpaCERdwU7igUmJqYGBYQ51vr2njU9ZimyKkfDe3axcyiBZde7G6dabliUosJvvKOPcKIWPccCgefSj_GNfwIip3-SsFdlR7BtbVUcqR-yv-XOxJ3Uc1MI0tz3uMiiZcyPV7sNCU4KRnemRIMHVOfuvHsU60_GhGbiSFzgPTAa9WTltbnarTbxudb_YEOx12JiwYToeX0DCPb43W1tzIBxgm8NxUg'
  echo $TOKEN | cut -d '.' -f2 - | base64 --decode -
  echo
  for ((i = 1; i <= 10; i++)); do
    RESULT=$(kubectl \
      --kubeconfig "$USER_CONFIG" \
      exec "$sleep_pod" \
      -c sleep \
      -n foo \
      -- curl "http://httpbin.foo:8000/headers" \
      -s \
      -o /dev/null \
      -H "Authorization: Bearer $TOKEN" \
      -w "%{http_code}")
    if [[ $RESULT != "200" ]]; then
      echo "http_code($RESULT) should be 200"
      exit
    fi
  done
  echo "Passed"

  echo "8. Verify that a request without a JWT is denied(403)"

  for ((i = 1; i <= 10; i++)); do
    RESULT=$(kubectl \
      --kubeconfig "$USER_CONFIG" \
      exec "$sleep_pod" \
      -c sleep \
      -n foo \
      -- curl "http://httpbin.foo:8000/headers" \
      -s \
      -o /dev/null \
      -w "%{http_code}")
    if [[ $RESULT != "403" ]]; then
      echo "http_code($RESULT) should be 403"
      exit
    fi
  done
  echo "Passed"

  echo "9. Updates the require-jwt authorization policy to add a claim named groups containing the value group1"

  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    apply -f require-jwt-group.yaml

  echo "10. Verify that a request with the JWT that includes group1 in the groups claim is allowed(200)"
  TOKEN_GROUP='eyJhbGciOiJSUzI1NiIsImtpZCI6IkRIRmJwb0lVcXJZOHQyenBBMnFYZkNtcjVWTzVaRXI0UnpIVV8tZW52dlEiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjM1MzczOTExMDQsImdyb3VwcyI6WyJncm91cDEiLCJncm91cDIiXSwiaWF0IjoxNTM3MzkxMTA0LCJpc3MiOiJ0ZXN0aW5nQHNlY3VyZS5pc3Rpby5pbyIsInNjb3BlIjpbInNjb3BlMSIsInNjb3BlMiJdLCJzdWIiOiJ0ZXN0aW5nQHNlY3VyZS5pc3Rpby5pbyJ9.EdJnEZSH6X8hcyEii7c8H5lnhgjB5dwo07M5oheC8Xz8mOllyg--AHCFWHybM48reunF--oGaG6IXVngCEpVF0_P5DwsUoBgpPmK1JOaKN6_pe9sh0ZwTtdgK_RP01PuI7kUdbOTlkuUi2AO-qUyOm7Art2POzo36DLQlUXv8Ad7NBOqfQaKjE9ndaPWT7aexUsBHxmgiGbz1SyLH879f7uHYPbPKlpHU6P9S-DaKnGLaEchnoKnov7ajhrEhGXAQRukhDPKUHO9L30oPIr5IJllEQfHYtt6IZvlNUGeLUcif3wpry1R5tBXRicx2sXMQ7LyuDremDbcNy_iE76Upg'
  echo "$TOKEN_GROUP" | cut -d '.' -f2 - | base64 --decode -
  echo
  for ((i = 1; i <= 10; i++)); do
    RESULT=$(kubectl \
      --kubeconfig "$USER_CONFIG" \
      exec "$sleep_pod" \
      -c sleep \
      -n foo \
      -- curl "http://httpbin.foo:8000/headers" \
      -s \
      -o /dev/null \
      -H "Authorization: Bearer $TOKEN_GROUP" \
      -w "%{http_code}")
    if [[ $RESULT != "200" ]]; then
      echo "http_code($RESULT) should be 200"
      exit
    fi
  done
  echo "Passed"

  echo "11. Verify that a request with a JWT, which doesn’t have the groups claim is rejected(403)"
  for ((i = 1; i <= 10; i++)); do
    RESULT=$(kubectl \
      --kubeconfig "$USER_CONFIG" \
      exec "$sleep_pod" \
      -c sleep \
      -n foo \
      -- curl "http://httpbin.foo:8000/headers" \
      -s \
      -o /dev/null \
      -H "Authorization: Bearer $TOKEN" \
      -w "%{http_code}")
    if [[ $RESULT != "403" ]]; then
      echo "http_code($RESULT) should be 200"
      exit
    fi
  done
  echo "Passed"
}

clean_up() {
  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    delete -f jwt-example.yaml >/dev/null 2>&1

  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    delete -f require-jwt.yaml >/dev/null 2>&1

  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    delete -f require-jwt-group.yaml >/dev/null 2>&1

  kubectl \
    --kubeconfig "$USER_CONFIG" \
    -n foo \
    delete -f "$ISTIO_HOME"/samples/httpbin/httpbin.yaml

  kubectl \
    --kubeconfig "$USER_CONFIG" \
    -n foo \
    delete -f "$ISTIO_HOME"/samples/sleep/sleep.yaml
}

clean_up_all() {
  kubectl \
    --kubeconfig "$USER_CONFIG" \
    delete namespace foo >/dev/null 2>&1

  kubectl \
    --kubeconfig "$MESH_CONFIG" \
    delete namespace foo >/dev/null 2>&1
}

clean_up_all
jwt_experiment
clean_up_all
echo "DONE"
