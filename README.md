
## 系统初始化
```
salt -L 'hw-bj-test-cicd-01' state.sls base.install-sys.init-all
```

##  全新安装

 > 部署前准备：确保states/files目录存在`node_exporter-1.4.0.linux-amd64.tar.gz`与`web_setuppack_init.zip`文件

```
salt -L 'hw-bj-test-cicd-01' state.sls states.app.all-in-one
```

## 选择安装

安装单个服务
```
sudo salt -L 'hw-bj-test-cicd-01' state.sls states.app.select-install pillar='{"install_services": "apache"}' 
```
安装多个服务，目前仅支持apache与mysql，apache与mysql和taserverd
```
sudo salt -L 'hw-bj-test-cicd-01' state.sls states.app.select-install pillar='{"install_services": ["apache", "mysql"]}'
```

## 清理资源

```
salt -L 'hw-bj-test-cicd-01' state.sls states.app.clean.all
```
