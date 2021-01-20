### 实验步骤
- `deploy-version-based.sh`
- `test-version-based.sh`

### 结论
单纯使用vs以header方式实现按版本路由目前无法实现。

原因是业务无感知，header在传递到下一个服务时丢失，没有办法在下一个服务的vs中match到。