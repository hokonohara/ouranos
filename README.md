
---
---
---

# Ouranosモック環境インストール、セットアップと実行

Ouranos サンプル関連手順

参考：https://github.com/ouranos-ecosystem-idi

### 確認環境

仮想マシン：Ubuntu 24.04、8GBメモリ、127GB仮想ディスク

ホストマシン：Windows 11、Hyper-V

作業フォルダー: ~/workspace

メモ: 

1. Ubuntu 24.04で確認、その他のディストロでも恐らく動くが、インストールするリナックス・パッケージが異なる可能性があります。
2. Ouranosリポジトリは、workspaceとsoftwareフォルダー使っているが、ここで全部workspaceで行う。
3. Ouranosリポジトリは、LinuxとWindowsで作業や使用バイナリになるが、ここで全部Ubuntuで行う。
4. 実行例(curl)を一つ一つ前の結果をコピペ―しないように、環境変数を使う。


コンテント：

- [基本環境セットアップ](#基本環境セットアップ)
- [コマンドライン(curl)でシナリオ実](#コマンドライン実行)

ウェブ版はここをご参考。

---
---
---

## 基本環境セットアップ


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

#### tools (スクリプトで使用する psql 必須、DB内容を見るため dbeaver オプショナル)
```
sudo apt install postgresql
```
```
sudo add-apt-repository ppa:serge-rider/dbeaver-ce
```
```
sudo apt update
```
```
sudo apt install dbeaver-ce
```

メモ: DB接続ためのユーザ/パスはデフォールトで、dhuser/passw0rd (注意:dbuserではない)

#### ouranos repository

```
cd
```
```
mkdir workspace
```
```
cd workspace
```
```
git clone https://github.com/ouranos-ecosystem-idi/data-transaction-system
```
```
git clone https://github.com/ouranos-ecosystem-idi/user-authentication-system
```

### pull docker images

```
cd data-transaction-system
```
```
docker compose pull
```
```
cd ../user-authentication-system
```
```
docker compose pull
```

### ビルドとdocker実行

```
docker compose up -d
```

```
export POSTGRESQL_URL='postgres://dhuser:passw0rd@localhost:5432/dhlocal?sslmode=disable'
```
```
migrate -path setup/migrations -database ${POSTGRESQL_URL} up
```

```
./setup/setup_seeds.sh
```
```
make idp-add-local
```

```
cd ../data-transaction-system
```
```
go build main.go
```
```
nano Dockerfile
# change 'as' to 'AS' in line 1
```

```
docker build -t data-space-backend .
```
```
docker run -v $(pwd)/config/:/app/config/ -td -i --network docker.internal --env-file config/local.env -p 8080:8080 --name data-spaces-backend data-spaces-backend
```

```
cd ../user-authentication-system
```
```
go build main.go
```
```
nano Dockerfile
# change 'as' to 'AS' in line 1
```
```
docker build -t authenticator-backend .
```
```
docker run -v $(pwd)/config/:/app/config/ -td -i --network docker.internal --env-file config/local.env -p 8081:8081 --name authenticator-backend authenticator-backend
```

メモ

1. 最終的にdockerプロセスは４つ：
   1. authenticator-backend
   2. data-space-backend
   3. postgres:14
   4. user-authentication-system-firebase

2. 停止して、再起動する場合、postgresデータが復元されるが、firebaseは初期化されるため、make idp-add-localで復元する。

---
---
---
##  コマンドライン実行

### 事業者認証

```
apikey1=Sample-APIKey1
apikey2=Sample-APIKey2
operatorid1=b39e6248-c888-56ca-d9d0-89de1b1adc8e
operatorid2=15572d1c-ec13-0d78-7f92-dd4278871373
```

```
result=`curl --location --request POST 'http://localhost:8081/auth/login' \
--header 'Content-Type: application/json' \
--header "apiKey: $apikey1" \
--data-raw '{
  "operatorAccountId": "oem_a@example.com",
  "accountPassword": "oemA&user_01"
}'` & echo $result | jq
```

```
token1=`echo $result | jq -r .accessToken`
```

```
echo $token1
```

```
curl --location --request GET 'http://localhost:8081/api/v1/authInfo?dataTarget=operator' \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token1" | jq
```

### 部品登録およびA社からB社へのCFP結果提出の依頼をする(基本フロー2 #4)

```
result=`curl --location --request PUT 'http://localhost:8081/api/v1/authInfo?dataTarget=plant' \
--header "apiKey: $apikey1" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token1" \
--data '{
  "openPlantId": "1234567890123012345",
  "operatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
  "plantAddress": "xx県xx市xxxx町1-1-1234",
  "plantId": null,
  "plantName": "A工場",
  "plantAttribute": {}
}'` & echo $result | jq
```

```
result=`curl --location --request PUT 'http://localhost:8080/api/v1/datatransport?dataTarget=parts' \
--header "apiKey: $apikey1" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token1" \
--data '{
  "amountRequired": null,
  "amountRequiredUnit": "kilogram",
  "operatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
  "partsName": "部品A",
  "plantId": "0cc8b4be-c727-4411-b478-2c874fbc6c25",
  "supportPartsName": "modelA",
  "terminatedFlag": false,
  "traceId": null
}'` & echo $result | jq
```

```
result=`curl --location --request PUT 'http://localhost:8080/api/v1/datatransport?dataTarget=partsStructure' \
--header "apiKey: $apikey1" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token1" \
--data '{
  "parentPartsModel": {
    "amountRequired": null,
    "amountRequiredUnit": "kilogram",
    "operatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
    "partsName": "部品A",
    "plantId": "0cc8b4be-c727-4411-b478-2c874fbc6c25",
    "supportPartsName": "modelA",
    "terminatedFlag": false,
    "traceId": "8fc6aa29-5f4f-476e-85e3-2d1b54715891"
  },
  "childrenPartsModel": [
    {
      "amountRequired": 5,
      "amountRequiredUnit": "kilogram",
      "operatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
      "partsName": "部品A1",
      "plantId": "0cc8b4be-c727-4411-b478-2c874fbc6c25",
      "supportPartsName": "modelA-1",
      "terminatedFlag": false,
      "traceId": null
    }
  ]
}'` & echo $result | jq

```
curl --location --request GET 'http://localhost:8081/api/v1/authInfo?dataTarget=operator&openOperatorId=1234567890124' \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token1"
```

```

```
```



### B社からA社へ部品登録紐付けをする(基本フロー2 #31)
```
result=`curl --location --request POST 'http://localhost:8081/auth/login' \
--header 'Content-Type: application/json' \
--header "apiKey: $apikey1" \
--data-raw '{
  "operatorAccountId": "supplier_b@example.com",
  "accountPassword": "supplierB&user_01"
}'` & echo $result | jq
```

```
result=`curl --location --request PUT 'http://localhost:8081/api/v1/authInfo?dataTarget=plant' \
--header "apiKey: $apikey1" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token" \
--data '{
  "openPlantId": "1234567890124012345",
  "operatorId": "15572d1c-ec13-0d78-7f92-dd4278871373",
  "plantAddress": "xx県xx市xxxx町2-1-1234",
  "plantId": null,
  "plantName": "B工場",
  "plantAttribute": {}
}'` & echo $result | jq
```

```
result=`curl --location --request PUT 'http://localhost:8080/api/v1/datatransport?dataTarget=parts' \
--header "apiKey: $apikey1" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token" \
--data '{
  "amountRequired": null,
  "amountRequiredUnit": "kilogram",
  "operatorId": "15572d1c-ec13-0d78-7f92-dd4278871373",
  "partsName": "部品B",
  "plantId": "544a5a35-dab3-469f-8ff5-116a4fe483e8",
  "supportPartsName": "modelB",
  "terminatedFlag": true,
  "traceId": null
}'` & echo $result | jq
```

```
result=`curl --location --request GET 'http://localhost:8080/api/v1/datatransport?dataTarget=tradeResponse' \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token"
```

```
result=`curl --location --request PUT 'http://localhost:8080/api/v1/datatransport?dataTarget=tradeResponse&tradeId=f475cb75-b3b8-4427-9e8d-376377f1c795&traceId=2fb97052-250b-44de-acbb-1ba63e28af71' \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token"` & echo $result | jq
```


### B社からA社へCFP情報の伝達をする(基本フロー3 #5)
```
result=`curl --location --request PUT 'http://localhost:8080/api/v1/datatransport?dataTarget=cfp' \
--header "apiKey: $apikey1" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token" \
--data '[
  {
    "cfpId": null,
    "traceId": "2fb97052-250b-44de-acbb-1ba63e28af71",
    "ghgEmission": 1.5,
    "ghgDeclaredUnit": "kgCO2e/kilogram",
    "cfpType": "preProduction",
    "dqrType": "preProcessing",
    "dqrValue": {
      "TeR": 1,
      "GeR": 2,
      "TiR": 3
    }
  },
  {
    "cfpId": null,
    "traceId": "2fb97052-250b-44de-acbb-1ba63e28af71",
    "ghgEmission": 10.0,
    "ghgDeclaredUnit": "kgCO2e/kilogram",
    "cfpType": "mainProduction",
    "dqrType": "mainProcessing",
    "dqrValue": {
      "TeR": 2,
      "GeR": 3,
      "TiR": 4
    }
  },
  {
    "cfpId": null,
    "traceId": "2fb97052-250b-44de-acbb-1ba63e28af71",
    "ghgEmission": 0,
    "ghgDeclaredUnit": "kgCO2e/kilogram",
    "cfpType": "preComponent",
    "dqrType": "preProcessing",
    "dqrValue": {
      "TeR": 1,
      "GeR": 2,
      "TiR": 3
    }
  },
  {
    "cfpId": null,
    "traceId": "2fb97052-250b-44de-acbb-1ba63e28af71",
    "ghgEmission": 0,
    "ghgDeclaredUnit": "kgCO2e/kilogram",
    "cfpType": "mainComponent",
    "dqrType": "mainProcessing",
    "dqrValue": {
      "TeR": 2,
      "GeR": 3,
      "TiR": 4
    }
  }
]'` & echo $result | jq
```

```
```

```
```

```
```

```
```


### B社の回答情報の取得およびA社の完成品のCFPを算出(基本フロー3 #6, #2)
```
result=`curl --location --request GET 'http://localhost:8080/api/v1/datatransport?dataTarget=tradeRequest' \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token"` & echo $result | jq
```

```
result=`curl --location --request GET 'http://localhost:8080/api/v1/datatransport?dataTarget=status&statusTarget=REQUEST&traceId=40b77952-2c89-49be-8ce9-7c64a15e0ae7' \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token"` & echo $result | jq
```

```
result=`curl --location --request PUT 'http://localhost:8080/api/v1/datatransport?dataTarget=cfp' \
--header "apiKey: $apikey1" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token" \
--data '[
    {
        "cfpId": null,
        "traceId": "40b77952-2c89-49be-8ce9-7c64a15e0ae7",
        "ghgEmission": 3.0,
        "ghgDeclaredUnit": "kgCO2e/kilogram",
        "cfpType": "preProduction",
        "dqrType": "preProcessing",
        "dqrValue": {
            "TeR": 1,
            "GeR": 2,
            "TiR": 3
        }
    },
    {
        "cfpId": null,
        "traceId": "40b77952-2c89-49be-8ce9-7c64a15e0ae7",
        "ghgEmission": 20.0,
        "ghgDeclaredUnit": "kgCO2e/kilogram",
        "cfpType": "mainProduction",
        "dqrType": "mainProcessing",
        "dqrValue": {
            "TeR": 2,
            "GeR": 3,
            "TiR": 4
        }
    },
    {
        "cfpId": null,
        "traceId": "40b77952-2c89-49be-8ce9-7c64a15e0ae7",
        "ghgEmission": 0,
        "ghgDeclaredUnit": "kgCO2e/kilogram",
        "cfpType": "preComponent",
        "dqrType": "preProcessing",
        "dqrValue": {
            "TeR": 1,
            "GeR": 2,
            "TiR": 3
        }
    },
    {
        "cfpId": null,
        "traceId": "40b77952-2c89-49be-8ce9-7c64a15e0ae7",
        "ghgEmission": 0,
        "ghgDeclaredUnit": "kgCO2e/kilogram",
        "cfpType": "mainComponent",
        "dqrType": "mainProcessing",
        "dqrValue": {
            "TeR": 2,
            "GeR": 3,
            "TiR": 4
        }
    }
]'` & echo $result | jq
```

```
result=`curl --location --request GET 'http://localhost:8080/api/v1/datatransport?dataTarget=cfp&traceIds=40b77952-2c89-49be-8ce9-7c64a15e0ae7' \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token"` & echo $result | jq
```

```
```





