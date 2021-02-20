### istio proxy test
> https://istio.io/v1.8/docs/setup/install/virtual-machine

1. [install](install.sh): install istio 
1. [prepare](prepare.sh): generate files
1. [init ssh](init.ssh.sh): init ssh to ecs instance
1. [run istio proxy on vm](run_on_vm.sh)
1. [deploy sample](sample.sh)
1. [test sample on vm](test_sample_on_vm.sh): istio proxy to sample (service discovery and route)