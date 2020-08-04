curl -s "localhost:7777/hello/eric?host=localhost&port=6001"
echo
curl -s "localhost:7777/hello/eric?host=localhost&port=7001"
echo
curl -s "localhost:7777/bye?host=localhost&port=6001"
echo
curl -s "localhost:7777/bye?host=localhost&port=7001"

for ((i = 1; i <= 100; i++)); do
  time curl -s "localhost:7777/hello/eric?host=localhost&port=6001"
done