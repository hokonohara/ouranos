# ouranos
Ouranos サンプル関連手順

参考：https://github.com/ouranos-ecosystem-idi

## 環境
仮想マシン：Ubuntu 24.04、8GBメモリ

ホストマシン：Windows 11、Hyper-V

#### build essential
```
sudo apt update
sudo apt upgrade -y
sudo apt install build-essential
sudo apt install curl
```
#### docker

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
```
sudo usermod -aG docker $USER
```
```
newgrp docker
```
```
docker --version
```


#### golang 1.19

```
wget https://go.dev/dl/go1.19.linux-amd64.tar.gz -O go.tar.gz
```
```
sudo tar -xzvf go.tar.gz -C /usr/local
```
```
echo export PATH=$HOME/go/bin:/usr/local/go/bin:$PATH >> ~/.profile
```
```
source ~/.profile
```
```
go version
```

#### golangci-lint 1.50.1

```
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.50.1
```
```
golangci-lint --version
```

#### mockery v2.27.1

```
golang install github.com/vektra/mockery/v2@2.27.1
```
```
mockery --version
```

#### goreturns

```
go install github.com/sqs/goreturns@latest
```

#### migrate
```
curl -L https://github.com/golang-migrate/migrate/releases/download/v4.17.1/migrate.linux-amd64.tar.gz | tar xvz
```
```
mv migrate ~/go/bin
```
```
migrate --version
```

#### ouranos repository

```
cd
```
```
mkdir ouranos
```
```
cd ouranos
```
```
git clone https://github.com/ouranos-ecosystem-idi/data-transaction-system
```
```
git clone https://github.com/ouranos-ecosystem-idi/user-authentication-system
```




```
git clone https://github.com/ouranos-ecosystem-idi/sample-application-cfp-backend
```
```
git clone https://github.com/ouranos-ecosystem-idi/sample-application-cfp-frontend
```
```
git clone https://github.com/ouranos-ecosystem-idi/sample-application-cfp-proxy
```
