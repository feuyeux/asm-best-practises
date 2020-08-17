curl -s "localhost:6666/hello/eric"
echo
curl -s "localhost:6667/hello/eric"
echo

rsocket-cli --request --route=hello -i '{"value":"eric"}' tcp://localhost:9001
rsocket-cli --request --route=hello -i '{"value":"eric"}' tcp://localhost:8001