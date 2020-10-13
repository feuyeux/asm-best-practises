echo "Test 8001->9001"
curl -s "localhost:6666/hello/eric"
echo
echo "Test 9001"
curl -s "localhost:6667/hello/eric"
echo
echo "Test v1 container"
docker exec -it "$(docker container ls | grep rsocket_ws_springboot_v1 | awk '{print $1}')" \
  /var/bin/rsocket-cli \
  --request \
  --route=hello \
  -i '{"value":"eric"}' \
  ws://localhost:9001
echo "Test v3 container"
docker exec -it "$(docker container ls | grep rsocket_ws_springboot_v3 | awk '{print $1}')" \
  /var/bin/rsocket-cli \
  --request \
  --route=hello \
  -i '{"value":"eric"}' \
  ws://localhost:9001
