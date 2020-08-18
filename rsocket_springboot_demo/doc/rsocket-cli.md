```sh
git clone https://github.com/rsocket/rsocket-cli.git
cd rsocket-cli
gradle --console plain installDist
cd ./build/install/rsocket-cli/
tar -czvf rsocket-cli.tar.gz .
```