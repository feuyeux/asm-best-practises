### log
#### a1
```bash
alias k="kubectl --kubeconfig $HOME/shop_config/kubeconfig/ack_production"
a1=$(k -n http-hello get po -l app=hello-a-deploy,version=v1 -o jsonpath={.items..metadata.name})
k -n http-hello logs -f $a1 hello-a-deploy
```

#### b1
```bash
alias k="kubectl --kubeconfig $HOME/shop_config/kubeconfig/ack_production"
b1=$(k -n http-hello get po -l app=hello-b-deploy,version=v1 -o jsonpath={.items..metadata.name})
k -n http-hello logs -f $b1 hello-b-deploy
```

#### b2
```bash
alias k="kubectl --kubeconfig $HOME/shop_config/kubeconfig/ack_production"
b2=$(k -n http-hello get po -l app=hello-b-deploy,version=v2 -o jsonpath={.items..metadata.name})
k -n http-hello logs -f $b2 hello-b-deploy
```

#### b3
```bash
alias k="kubectl --kubeconfig $HOME/shop_config/kubeconfig/ack_production"
b3=$(k -n http-hello get po -l app=hello-b-deploy,version=v3 -o jsonpath={.items..metadata.name})
k -n http-hello logs -f $b3 hello-b-deploy
```

### dump
#### a1
```bash
alias k="kubectl --kubeconfig $HOME/shop_config/kubeconfig/ack_production"
a1=$(k -n http-hello get po -l app=hello-a-deploy,version=v1 -o jsonpath={.items..metadata.name})
k -n http-hello exec $a1 hello-a-deploy -c istio-proxy -- curl -s localhost:15000/config_dump > /tmp/config_dump.json
code /tmp/config_dump.json
```