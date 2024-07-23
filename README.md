
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
go install github.com/vektra/mockery/v2@v2.27.1
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
sudo apt install postgresql-client
```
以下はオプショナルです、dbを見るためのGUI
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
fix compability issues with newer docker.
```
nano Dockerfile
# change 'as' to 'AS' in line 1
```

```
docker build -t data-spaces-backend .
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
```

```
# CompanyA get access token
url="http://localhost:8081/auth/login"
data="{
  \"operatorAccountId\": \"oem_a@example.com\",
  \"accountPassword\": \"oemA&user_01\"
}"
result=`curl -s --location --request POST "$url" \
--header "Content-Type: application/json" \
--header "apiKey: $apikey1" \
--data-raw "$data"`
echo $result | jq
token1=`echo $result | jq -r .accessToken`
echo "token1=$token1"
```

```
# CompanyA check access token, get operatorId
url="http://localhost:8081/api/v1/authInfo?dataTarget=operator"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token1"`
echo $result | jq
operatorid1=`echo $result | jq -r .operatorId`
echo "operatorid1=$operatorid1"
```

### 部品登録およびA社からB社へのCFP結果提出の依頼をする(基本フロー2 #4)

```
# CompanyA create plant
url="http://localhost:8081/api/v1/authInfo?dataTarget=plant"
data="{
  \"openPlantId\": \"1234567890123012345\",
  \"operatorId\": \"$operatorid1\",
  \"plantAddress\": \"xx県xx市xxxx町1-1-1234\",
  \"plantId\": null,
  \"plantName\": \"A工場\",
  \"plantAttribute\": {}
}"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $apikey1" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer $token1" \
--data "$data"`
echo $result | jq
plantid1=`echo $result | jq -r .plantId`
echo "plantid1=$plantid1"
```

```
# CompanyA create part
url="http://localhost:8080/api/v1/datatransport?dataTarget=parts"
data="{
  \"amountRequired\": null,
  \"amountRequiredUnit\": \"kilogram\",
  \"operatorId\": \"$operatorid1\",
  \"partsName\": \"部品A\",
  \"plantId\": \"$plantid1\",
  \"supportPartsName\": \"modelA\",
  \"terminatedFlag\": false,
  \"traceId\": null
}"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $apikey1" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer $token1" \
--data "$data"`
echo $result | jq
traceid1=`echo $result | jq -r .traceId`
echo "traceid1=$traceid1"
```

```
# CompanyA create part structure
url="http://localhost:8080/api/v1/datatransport?dataTarget=partsStructure"
data="{
  \"parentPartsModel\": {
    \"amountRequireddv": null,
    \"amountRequiredUnit\": \"kilogram\",
    \"operatorId\": \"$operatorid1\",
    \"partsName\": \"部品A\",
    \"plantId\": \"$plantid1\",
    \"supportPartsName\": \"modelA\",
    \"terminatedFlag\": false,
    \"traceId\": \"traceid1\"
  },
  \"childrenPartsModel\": [
    {
      \"amountRequired\": 5,
      \"amountRequiredUnit\": \"kilogram\",
      \"operatorId\": \"$operatorid1\",
      \"partsName\": \"部品A1\",
      \"plantId\": \"$plantid1\",
      \"supportPartsNamedv": \"modelA-1\",
      \"terminatedFlag\": false,
      \"traceId\": null
    }
  ]
}"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $apikey1" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer $token1" \
--data "$data"`
echo $result | jq
traceid2=`echo $result | jq -r .childrenPartsModel[0].traceId`
echo "traceid2=$traceid2"
```

```
# CompanyA find company B operatorId
operatorb=1234567890124
url="http://localhost:8081/api/v1/authInfo?dataTarget=operator&openOperatorId=$operatorb"
curl -s --location --request GET "$url" \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token1"
operatorid2=`echo $result | jq -r .operatorId`
echo "operatorid2=$operatorid2"
```


### B社からA社へ部品登録紐付けをする(基本フロー2 #31)

```
apikey2=Sample-APIKey2
```

```
# CompanyB get access token
url="http://localhost:8081/auth/login"
data="{
  \"operatorAccountId\": \"supplier_b@example.com\",
  \"accountPassword\": \"supplierB&user_01\"
}"
result=`curl -s --location --request POST "$url" \
--header 'Content-Type: application/json' \
--header "apiKey: $apikey1" \
--data-raw "$data"`
echo $result | jq
token2=`echo $result | jq -r .accessToken`
echo "token2=$token2"
```

CompanyB can use api to get his operatorid, but we already have it as operatorid2

```
# CompanyB create plant
url="http://localhost:8081/api/v1/authInfo?dataTarget=plant"
data="{
  \"openPlantId\": \"1234567890124012345\",
  \"operatorId\": \"operatorid2\",
  \"plantAddress\": \"xx県xx市xxxx町2-1-1234\",
  \"plantId\": null,
  \"plantName\": \"B工場\",
  \"plantAttribute\": {}
}"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $apikey1" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token" \
--data "$data"`
echo $result | jq
```

```
url="http://localhost:8080/api/v1/datatransport?dataTarget=parts"
data="{
  \"amountRequired\": null,
  \"amountRequiredUnit\": \"kilogram\",
  \"operatorId\": \"15572d1c-ec13-0d78-7f92-dd4278871373\",
  \"partsName\": \"部品B\",
  \"plantId\": \"544a5a35-dab3-469f-8ff5-116a4fe483e8\",
  \"supportPartsName\": \"modelB\",
  \"terminatedFlag\": true,
  \"traceId\": null
}"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $apikey1" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token" \
--data "$data"`
echo $result | jq
```

```
url="http://localhost:8080/api/v1/datatransport?dataTarget=tradeResponse"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token"`
```

```
url="http://localhost:8080/api/v1/datatransport?dataTarget=tradeResponse&tradeId=f475cb75-b3b8-4427-9e8d-376377f1c795&traceId=2fb97052-250b-44de-acbb-1ba63e28af71"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token"`
echo $result | jq
```


### B社からA社へCFP情報の伝達をする(基本フロー3 #5)

```
url="http://localhost:8080/api/v1/datatransport?dataTarget=cfp"
data="[
  {
    \"cfpId\": null,
    \"traceId\": \"2fb97052-250b-44de-acbb-1ba63e28af71\",
    \"ghgEmission\": 1.5,
    \"ghgDeclaredUnit\": \"kgCO2e/kilogram\",
    \"cfpType\": \"preProduction\",
    \"dqrType\": \"preProcessing\",
    \"dqrValue\": {
      \"TeR\": 1,
      \"GeR\": 2,
      \"TiR\": 3
    }
  },
  {
    \"cfpId\": null,
    \"traceId\": \"2fb97052-250b-44de-acbb-1ba63e28af71\",
    \"ghgEmission\": 10.0,
    \"ghgDeclaredUnit\": "kgCO2e/kilogram\",
    \"cfpType\": \"mainProduction\",
    \"dqrType\": \"mainProcessing\",
    \"dqrValue\": {
      \"TeR": 2,
      \"GeR": 3,
      \"TiR": 4
    }
  },
  {
    \"cfpId\": null,
    \"traceId\": \"2fb97052-250b-44de-acbb-1ba63e28af71\",
    \"ghgEmission\": 0,
    \"ghgDeclaredUnit\": \"kgCO2e/kilogram\",
    \"cfpType\": \"preComponent\",
    \"dqrType\": \"preProcessing\",
    \"dqrValue\": {
      \"TeR\": 1,
      \"GeR\": 2,
      \"TiR\": 3
    }
  },
  {
    \"cfpId": null,
    \"traceId\": \"2fb97052-250b-44de-acbb-1ba63e28af71\",
    \"ghgEmission\": 0,
    \"ghgDeclaredUnit\": \"kgCO2e/kilogram\",
    \"cfpType\": \"mainComponent\",
    \"dqrType\": \"mainProcessing\",
    \"dqrValue\": {
      \"TeR\": 2,
      \"GeR\": 3,
      \"TiR\": 4
    }
  }
]"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $apikey1" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token" \
--data "$data"`
echo $result | jq
```





### B社の回答情報の取得およびA社の完成品のCFPを算出(基本フロー3 #6, #2)

```
url="http://localhost:8080/api/v1/datatransport?dataTarget=tradeRequest"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token"`
echo $result | jq
```

```
url="http://localhost:8080/api/v1/datatransport?dataTarget=status&statusTarget=REQUEST&traceId=40b77952-2c89-49be-8ce9-7c64a15e0ae7"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token"`
echo $result | jq
```

```
url="http://localhost:8080/api/v1/datatransport?dataTarget=cfp"
data="[
    {
        \"cfpId\": null,
        \"traceId\": \"40b77952-2c89-49be-8ce9-7c64a15e0ae7\",
        \"ghgEmission\": 3.0,
        \"ghgDeclaredUnit\": \"kgCO2e/kilogram\",
        \"cfpType\": \"preProduction\",
        \"dqrType\": \"preProcessing\",
        \"dqrValue\": {
            \"TeR\": 1,
            \"GeR\": 2,
            \"TiR\": 3
        }
    },
    {
        \"cfpId\": null,
        \"traceId\": \"40b77952-2c89-49be-8ce9-7c64a15e0ae7\",
        \"ghgEmission\": 20.0,
        \"ghgDeclaredUnit\": \"kgCO2e/kilogram\",
        \"cfpType\": \"mainProduction\",
        \"dqrType\": \"mainProcessing\",
        \"dqrValue\": {
            \"TeR\": 2,
            \"GeR\": 3,
            \"TiR\": 4
        }
    },
    {
        \"cfpId\": null,
        \"traceId\": \"40b77952-2c89-49be-8ce9-7c64a15e0ae7\",
        \"ghgEmission\": 0,
        \"ghgDeclaredUnit\": \"kgCO2e/kilogram\",
        \"cfpType\": \"preComponent\",
        \"dqrType\": \"preProcessing\",
        \"dqrValue\": {
            \"TeR\": 1,
            \"GeR\": 2,
            \"TiR\": 3
        }
    },
    {
        \"cfpId\": null,
        \"traceId": \"40b77952-2c89-49be-8ce9-7c64a15e0ae7\",
        \"ghgEmission\": 0,
        \"ghgDeclaredUnit\": \"kgCO2e/kilogram\",
        \"cfpType\": \"mainComponent\",
        \"dqrType\": \"mainProcessing\",
        \"dqrValue\": {
            \"TeR\": 2,
            \"GeR\": 3,
            \"TiR\": 4
        }
    }
]"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $apikey1" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token" \
--data "$data"`
echo $result | jq
```

```
url="http://localhost:8080/api/v1/datatransport?dataTarget=cfp&traceIds=40b77952-2c89-49be-8ce9-7c64a15e0ae7"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $apikey1" \
--header "Authorization: Bearer $token"`
echo $result | jq
```





