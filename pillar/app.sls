# 设置文件备份目录
BAKDIR: "/bak/"

# 设置文件解压目录
UNZIPDIR: "/"

# slat minion内部地址
SALT_MINION_IP: {{ grains['fqdn_ip4'][0] }}

# 服务安装目录
SERVICE_INSTALL_DIR: "/mnt/hdisk"

# apache目录
HTTPD_DIRS:
  WORKER: "/mnt/hdisk/opt/httpd_worker"
  HTTP_LOGS: "/mnt/hdisk/http_logs"
  LOGS: "/opt/httpd/logs/"
  UPLOAD: "/opt/httpd/htdocs/upload"
  HTTP_UPLOAD: "/mnt/hdisk/httpupload/"
  HTTP_INITD: "/etc/init.d/httpd"
  HTTP_WEB_DIR: "/opt/httpd"

# 测试环境apache配置参数
HTTPD_SETTINGS:
  VHOST_OPTIONS:
    SERVER_NAME: "seetong.com:6810"
    SERVER_ALIAS: "seetong.com www.seetong.com seetong.net dl.seetong.com www.seetong.net m1.seetong.com m2.seetong.com m3.seetong.com s1.bla.seetong.com s2.bla.seetong.com s3.bla.seetong.com app.seetong.com appbak.seetong.com push.seetong.com dev.seetong.com test.seetong.com dev-test.seetong.com
"
    ERROR_LOG: "logs/test.seetong.com-error_log"
    CUSTOM_LOG: ""

# 测试环境PHP配置
DB_HOST: "172.16.0.213"
DB_PORT: "13530"
DB_USER: "root"
DB_PASS: "FAwNRg8BWQ=="
HTTP_SERVER_ID: "3080104"
HTTP_SERVER_TYPE: "APP"
HTTP_SERVER_AREA: "CN"