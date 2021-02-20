echo "==== Configure the virtual machine ===="

echo "1 Install the root certificate at /etc/certs"
test -d /etc/certs || mkdir -p /etc/certs
cp "${HOME}"/root-cert.pem /etc/certs/root-cert.pem

echo "2 Install the token at /var/run/secrets/tokens:"
test -d /var/run/secrets/tokens || mkdir -p /var/run/secrets/tokens
cp "${HOME}"/istio-token /var/run/secrets/tokens/istio-token

echo "3 Install the package containing the Istio virtual machine integration runtime"
curl -LO https://storage.googleapis.com/istio-release/releases/1.8.3/deb/istio-sidecar.deb
dpkg -i istio-sidecar.deb

echo "4 Install cluster.env within the directory /var/lib/istio/envoy/:"
cp "${HOME}"/cluster.env /var/lib/istio/envoy/cluster.env

echo "5 Install the Mesh Config to /etc/istio/config/mesh:"
cp "${HOME}"/mesh.yaml /etc/istio/config/mesh

echo "6 Add the istiod host to /etc/hosts:"
sh -c 'cat ${HOME}/hosts >> /etc/hosts'

echo "7 Transfer ownership of the files in /etc/certs/ and /var/lib/istio/envoy/ to the Istio proxy:"
mkdir -p /etc/istio/proxy
chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy /etc/istio/config /var/run/secrets /etc/certs/root-cert.pem
