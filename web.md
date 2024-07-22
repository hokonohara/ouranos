- [ウェブ版追加セットアップ](#ウェブ版追加セットアップ)
  - [java](#java)
  - [node.js](#nodejs)
  - [nginx](#nginx)
- [java, maven, tomcat](#java-maven-tomcat)
- [backend](#backend)
- [frontend](#frontend)
- [proxy](#proxy)
- [ウェブ版実行](#ウェブ版実行)



---
---
---

##  ウェブ版追加セットアップ


```
git clone https://github.com/ouranos-ecosystem-idi/sample-application-cfp-backend
```
```
git clone https://github.com/ouranos-ecosystem-idi/sample-application-cfp-frontend
```
```
git clone https://github.com/ouranos-ecosystem-idi/sample-application-cfp-proxy
```

### java
```
cd
```

```
mkdir -p ~/software
```
```
cd ~/software
```

```
```

```
```

```
```

```
```

```
```

```
```

```
```


### node.js

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

```
source ~/.bashrc
```

```
nvm --version
```

```
nvm install 20.11.0
```

```
node --version
```

```
npm --version
```

### nginx

```
sudo apt-get update
sudo apt-get install net-tools
```

```
wget https://nginx.org/download/nginx-1.25.0.tar.gz
```

```
tar -zxvf nginx-1.25.0.tar.gz
cd nginx-1.25.0
```

```
sudo apt install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev
```

```
./configure --sbin-path=/usr/bin/nginx \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --with-pcre \
            --pid-path=/var/run/nginx.pid \
            --with-http_ssl_module
```

```
sudo make install
```

```
nginx -V
```

## java, maven, tomcat

```
cd ~/software
```

```
curl -O https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz
```

```
tar -xzvf openjdk-17.0.2_linux-x64_bin.tar.gz
```

```
echo 'export JAVA_HOME=~/software/jdk-17.0.2' >> ~/.bashrc
```

```
echo 'export JRE_HOME=~/software/jdk-17.0.2' >> ~/.bashrc
```

```
 curl -O https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz

```

```
tar -xzvf apache-maven-3.9.6-bin.tar.gz
```


```
echo 'export PATH="~/software/apache-maven-3.9.6/bin:$PATH"' >> ~/.bashrc
```

```
source ~/.bashrc
```

```
curl -O https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.7/bin/apache-tomcat-10.1.7.tar.gz
```

```
tar -xzvf apache-tomcat-10.1.7.tar.gz
```




## backend

```
cd ~/ouranos/sample-application-cfp-backend
```

```
mvn clean package
```

```
ls target
```

```
cp target/common-backend.war ~/software/apache-tomcat-10.1.7/webapps/
```

```
cd ~/software/apache-tomcat-10.1.7/bin
```

```
./startup.sh
```

```
curl http://localhost:8080/common-backend/health
```


```
tail -f ~/software/apache-tomcat-10.1.7/logs/catalina.out
```

```
./shutdown.sh
```

## frontend

```
cd ~/ouranos/sample-application-cfp-frontend
```

```
npm ci
```

```
npm run dev
```

```
echo 'NEXT_PUBLIC_DATA_TRANSPORT_API_BASE_URL=http://localhost' >> .env.local
```

```
npm run build
```

```

```


## proxy

```
cd ~/ouranos/sample-application-cfp-proxy
```

```
```



---
## ウェブ版実行