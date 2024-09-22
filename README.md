# Ouranosモック環境 インストール、セットアップと実行 

Ouranosサンプル関連手順

参考：https://github.com/ouranos-ecosystem-idi

## 確認環境 

仮想マシン：Ubuntu 24.04、8GBメモリ、127GB仮想ディスク  
ホストマシン：Windows 11、Hyper-V  
作業フォルダー: ~/ouranos

メモ: 

1. Ubuntu 24.04で確認、その他のディストロでも恐らく動くが、インストールするリナックス・パッケージが異なる可能性があります。
2. Ouranosリポジトリ手順は、workspaceとsoftwareの２つフォルダー使っているが、ここで全部~/ouranosで行う。
3. Ouranosリポジトリは、LinuxとWindowsで作業や使用バイナリになるが、ここで全部Ubuntuで行う。
4. 実行例(curl)を前の結果をコピペーストしないように、環境変数を使う。


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
sudo apt install -y build-essential
sudo apt install -y curl
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
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
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
rm go.tar.gz 
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

メモ: DB接続ためのDB名、ユーザ/パスはデフォールトで、dhlocal/huser/passw0rd (注意:db*ではない)

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


<!--
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
-->


### ビルド

```
cd ../data-transaction-system
```
```
go build main.go
```

fix compability issues with newer docker.
```
sed -i 's/as/AS/' Dockerfile
```

```
docker build -t data-spaces-backend .
```

```
cd ../user-authentication-system
```
```
go build main.go
```

```
sed -i 's/as/AS/' Dockerfile
```

```
docker build -t authenticator-backend .
```

### Check docker images
```
docker images
```
<details closez>
<summary>サンプル出力</summary>

```
REPOSITORY                            TAG       IMAGE ID       CREATED          SIZE
user-authentication-system-firebase   latest    38ec8e7aa89d   9 minutes ago    292MB
authenticator-backend                 latest    144633d215fc   18 minutes ago   45.6MB
data-spaces-backend                   latest    2d38ec9936af   20 minutes ago   33.8MB
postgres                              14        480f26a07aa1   6 weeks ago      422MB
```

</details>


### docker実行

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
docker run \
 -v ~/ouranos/data-transaction-system/config/:/app/config/ \
 -td -i --network docker.internal \
 --env-file ~/ouranos/data-transaction-system/config/local.env \
 -p 8080:8080 \
 --name data-spaces-backend \
 data-spaces-backend
```

```
docker run \
 -v ~/ouranos/user-authentication-system/config/:/app/config/ \
 -td -i --network docker.internal \
 --env-file ~/ouranos/user-authentication-system/config/local.env \
 -p 8081:8081 \
 --name authenticator-backend \
 authenticator-backend
```

```
docker ps -a
```
<details closez>
<summary>サンプル出力</summary>

```
CONTAINER ID   IMAGE                                 COMMAND                  CREATED         STATUS         PORTS                                                                                  NAMES
d709dac190f7   postgres:14                           "docker-entrypoint.s…"   5 minutes ago   Up 5 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp                                              postgres
1d481c4ead1e   user-authentication-system-firebase   "docker-entrypoint.s…"   5 minutes ago   Up 5 minutes   0.0.0.0:4000->4000/tcp, :::4000->4000/tcp, 0.0.0.0:9099->9099/tcp, :::9099->9099/tcp   user-authentication-system-firebase-1
10334cce99b8   authenticator-backend                 "/app/server"            6 minutes ago   Up 6 minutes   0.0.0.0:8081->8081/tcp, :::8081->8081/tcp                                              authenticator-backend
e903cb5701dc   data-spaces-backend                   "/app/server"            6 minutes ago   Up 6 minutes   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                                              data-spaces-backend
```

</details>

```
docker volume ls
```
<details closez>
<summary>サンプル出力</summary>

```
DRIVER    VOLUME NAME
local     user-authentication-system_db-vol
```

</details>


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

メモ
- 時間置いて実行した場合、アクセストークンが切れるときに再度取得してくだい。

### 事業者認証

1. 事業者認証の実行
   
   実行者：A社

```
# CompanyA authentication data, previous set in DB and firebase
aapikey=Sample-APIKey1
aaccountid="oem_a@example.com"
aaccountpass="oemA&user_01"
```

```
# CompanyA get access token
url="http://localhost:8081/auth/login"
data="{
  \"operatorAccountId\": \"$aaccountid\",
  \"accountPassword\": \"$aaccountpass\"
}"
result=`curl -s --location --request POST "$url" \
--header "Content-Type: application/json" \
--header "apiKey: $aapikey" \
--data-raw "$data"`
echo $result | jq
# CompanyA access token
atoken=`echo $result | jq -r .accessToken`
echo "atoken=$atoken"
```

<details closez>
<summary>サンプル出力</summary>
```
{
  "accessToken": "eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJvcGVyYXRvcl9pZCI6ImIzOWU2MjQ4LWM4ODgtNTZjYS1kOWQwLTg5ZGUxYjFhZGM4ZSIsImVtYWlsIjoib2VtX2FAZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImF1dGhfdGltZSI6MTcyNzAxOTU3OSwidXNlcl9pZCI6IjdiY2Q5ZWQxLWVmMzktNDNkNy1hZTY4LWJiNzE1NGY0MTIyNyIsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsib2VtX2FAZXhhbXBsZS5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJwYXNzd29yZCJ9LCJpYXQiOjE3MjcwMTk1NzksImV4cCI6MTcyNzAyMzE3OSwiYXVkIjoibG9jYWwiLCJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbG9jYWwiLCJzdWIiOiI3YmNkOWVkMS1lZjM5LTQzZDctYWU2OC1iYjcxNTRmNDEyMjcifQ.",
  "refreshToken": "eyJfQXV0aEVtdWxhdG9yUmVmcmVzaFRva2VuIjoiRE8gTk9UIE1PRElGWSIsImxvY2FsSWQiOiI3YmNkOWVkMS1lZjM5LTQzZDctYWU2OC1iYjcxNTRmNDEyMjciLCJwcm92aWRlciI6InBhc3N3b3JkIiwiZXh0cmFDbGFpbXMiOnt9LCJwcm9qZWN0SWQiOiJsb2NhbCJ9"
}
atoken=eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJvcGVyYXRvcl9pZCI6ImIzOWU2MjQ4LWM4ODgtNTZjYS1kOWQwLTg5ZGUxYjFhZGM4ZSIsImVtYWlsIjoib2VtX2FAZXhhbXBsZS5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImF1dGhfdGltZSI6MTcyNzAxOTU3OSwidXNlcl9pZCI6IjdiY2Q5ZWQxLWVmMzktNDNkNy1hZTY4LWJiNzE1NGY0MTIyNyIsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsib2VtX2FAZXhhbXBsZS5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJwYXNzd29yZCJ9LCJpYXQiOjE3MjcwMTk1NzksImV4cCI6MTcyNzAyMzE3OSwiYXVkIjoibG9jYWwiLCJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbG9jYWwiLCJzdWIiOiI3YmNkOWVkMS1lZjM5LTQzZDctYWU2OC1iYjcxNTRmNDEyMjcifQ.
```
</details>

2. 事業者情報の取得
   
    実行者：A社

```
# CompanyA check access token, get operatorId
url="http://localhost:8081/api/v1/authInfo?dataTarget=operator"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $aapikey" \
--header "Authorization: Bearer $atoken"`
echo $result | jq
# CompanyA operatodId
aoperatorid=`echo $result | jq -r .operatorId`
echo "aoperatorid=$aoperatorid"
```

<details closez>
<summary>サンプル出力</summary>

```
{
  "operatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
  "operatorName": "A社",
  "operatorAddress": "東京都渋谷区xx",
  "openOperatorId": "1234567890123",
  "operatorAttribute": {
    "globalOperatorId": "1234ABCD5678EFGH0123"
  }
}
aoperatorid=b39e6248-c888-56ca-d9d0-89de1b1adc8e
```

</details>


### 部品登録およびA社からB社へのCFP結果提出の依頼をする(基本フロー2 #4)

1. 事業所の登録

    実行者：A社

```
# CompanyA plant id
aopenplantid=1234567890123012345
```

```
# CompanyA create plant
url="http://localhost:8081/api/v1/authInfo?dataTarget=plant"
data="{
  \"openPlantId\": \"$aopenplantid\",
  \"operatorId\": \"$aoperatorid\",
  \"plantAddress\": \"xx県xx市xxxx町1-1-1234\",
  \"plantId\": null,
  \"plantName\": \"A工場\",
  \"plantAttribute\": {}
}"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $aapikey" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer $atoken" \
--data "$data"`
echo $result | jq
# CompanyA plantId
aplantid=`echo $result | jq -r .plantId`
echo "aplantid=$aplantid"
```

<details closez>
<summary>サンプル出力</summary>

```
{
  "plantId": "170c0850-6aae-4269-8e08-f71e4fab9b52",
  "operatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
  "plantName": "A工場",
  "plantAddress": "xx県xx市xxxx町1-1-1234",
  "openPlantId": "1234567890123012345",
  "plantAttribute": {
    "globalPlantId": null
  }
}
aplantid=170c0850-6aae-4269-8e08-f71e4fab9b52
```

</details>


2. 親部品情報の作成

    実行者：A社
   
```
# CompanyA create part
url="http://localhost:8080/api/v1/datatransport?dataTarget=parts"
data="{
  \"amountRequired\": null,
  \"amountRequiredUnit\": \"kilogram\",
  \"operatorId\": \"$aoperatorid\",
  \"partsName\": \"部品A\",
  \"plantId\": \"$aplantid\",
  \"supportPartsName\": \"modelA\",
  \"terminatedFlag\": false,
  \"traceId\": null
}"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $aapikey" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer $atoken" \
--data "$data"`
echo $result | jq
# CompanyA part's traceId
atraceid1=`echo $result | jq -r .traceId`
echo "atraceid1=$atraceid1"
```

<details closez>
<summary>サンプル出力</summary>

```
{
  "traceId": "4fe20864-8669-4977-a6a6-24c66bf10294",
  "operatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
  "plantId": "170c0850-6aae-4269-8e08-f71e4fab9b52",
  "partsName": "部品A",
  "supportPartsName": "modelA",
  "terminatedFlag": false,
  "amountRequired": null,
  "amountRequiredUnit": "kilogram"
}
atraceid1=4fe20864-8669-4977-a6a6-24c66bf10294
```

</details>


3. 部品構成情報の登録
   
   実行者：A社

```
# CompanyA create part structure
url="http://localhost:8080/api/v1/datatransport?dataTarget=partsStructure"
data="{
  \"parentPartsModel\": {
    \"amountRequired\": null,
    \"amountRequiredUnit\": \"kilogram\",
    \"operatorId\": \"$aoperatorid\",
    \"partsName\": \"部品A\",
    \"plantId\": \"$aplantid\",
    \"supportPartsName\": \"modelA\",
    \"terminatedFlag\": false,
    \"traceId\": \"$atraceid1\"
  },
  \"childrenPartsModel\": [
    {
      \"amountRequired\": 5,
      \"amountRequiredUnit\": \"kilogram\",
      \"operatorId\": \"$aoperatorid\",
      \"partsName\": \"部品A1\",
      \"plantId\": \"$aplantid\",
      \"supportPartsName\": \"modelA-1\",
      \"terminatedFlag\": false,
      \"traceId\": null
    }
  ]
}"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $aapikey" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer $atoken" \
--data "$data"`
echo $result | jq
# CompanyA sub part's traceId
atraceid2=`echo $result | jq -r .childrenPartsModel[0].traceId`
echo "atraceid2=$atraceid2"
```

<details closez>
<summary>サンプル出力</summary>

```
{
  "parentPartsModel": {
    "traceId": "4fe20864-8669-4977-a6a6-24c66bf10294",
    "operatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
    "plantId": "170c0850-6aae-4269-8e08-f71e4fab9b52",
    "partsName": "部品A",
    "supportPartsName": "modelA",
    "terminatedFlag": false,
    "amountRequired": null,
    "amountRequiredUnit": "kilogram"
  },
  "childrenPartsModel": [
    {
      "traceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
      "operatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
      "plantId": "170c0850-6aae-4269-8e08-f71e4fab9b52",
      "partsName": "部品A1",
      "supportPartsName": "modelA-1",
      "terminatedFlag": false,
      "amountRequired": 5,
      "amountRequiredUnit": "kilogram"
    }
  ]
}
atraceid2=8ebd21b5-9620-4fb7-b786-de8884ffd3d1
```

</details>


### CFP結果提出の依頼

 公開されたB社情報(他社検索用)

```
# CompanyB known id, previously registerd on DB
operatorb=1234567890124
```

1. B社の事業者識別子（内部）の検索

    実行者：A社
   
```
# CompanyA find company B operatorId
url="http://localhost:8081/api/v1/authInfo?dataTarget=operator&openOperatorId=$operatorb"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $aapikey" \
--header "Authorization: Bearer $atoken"`
echo $result | jq
boperatorid=`echo $result | jq -r .operatorId`
echo "boperatorid=$boperatorid"
```

<details closez>
<summary>サンプル出力</summary>

```
{
  "operatorId": "15572d1c-ec13-0d78-7f92-dd4278871373",
  "operatorName": "B社",
  "operatorAddress": "東京都渋谷区xx",
  "openOperatorId": "1234567890124",
  "operatorAttribute": {
    "globalOperatorId": "1234ABCD5678EFGH0124"
  }
}
boperatorid=15572d1c-ec13-0d78-7f92-dd4278871373
```

</details>


2. A社からB社への取引関係の作成

    実行者：A社

```
# CompanyA request trading with CompanyB
url="http://localhost:8080/api/v1/datatransport?dataTarget=tradeRequest"
data="{
  \"statusModel\": {
    \"message\": \"来月中にご回答をお願いします。\",
    \"replyMessage\": null,
    \"requestStatus\": {},
    \"requestType\": \"CFP\",
    \"statusId\": null,
    \"tradeId\": null
  },
  \"tradeModel\": {
    \"downstreamOperatorId\": \"$aoperatorid\",
    \"downstreamTraceId\": \"$atraceid2\",
    \"tradeId\": null,
    \"upstreamOperatorId\": \"$boperatorid\",
    \"upstreamTraceId\": null
  }
}"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $aapikey" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer $atoken" \
--data "$data"`
echo $result | jq
atradeid=`echo $result | jq -r .tradeModel.tradeId`
echo "atradeid=$atradeid"
astatusid=`echo $result | jq -r .statusModel.statusId`
echo "astatusid=$astatusid"
```

<details closez>
<summary>サンプル出力</summary>

```
{
  "tradeModel": {
    "tradeId": "e45c0bb8-ff5b-4f62-b392-411c5eb7d2b0",
    "downstreamOperatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
    "upstreamOperatorId": "15572d1c-ec13-0d78-7f92-dd4278871373",
    "downstreamTraceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
    "upstreamTraceId": null
  },
  "statusModel": {
    "statusId": "dc3746af-9104-41b5-8a64-438167570de3",
    "tradeId": "e45c0bb8-ff5b-4f62-b392-411c5eb7d2b0",
    "requestStatus": {
      "cfpResponseStatus": "NOT_COMPLETED",
      "tradeTreeStatus": "UNTERMINATED"
    },
    "message": "来月中にご回答をお願いします。",
    "replyMessage": null,
    "requestType": "CFP"
  }
}
atradeid=e45c0bb8-ff5b-4f62-b392-411c5eb7d2b0
astatusid=dc3746af-9104-41b5-8a64-438167570de3
```

</details>



### B社からA社へ部品登録紐付けをする(基本フロー2 #31)

1. 事業者認証の実行

    実行者：B社

```
# CompanyB authentication data, previous set in DB and firebase
bapikey=Sample-APIKey2
baccountid="supplier_b@example.com"
baccountpass="supplierB&user_01"
```

```
# CompanyB get access token
url="http://localhost:8081/auth/login"
data="{
  \"operatorAccountId\": \"$baccountid\",
  \"accountPassword\": \"$baccountpass\"
}"
result=`curl -s --location --request POST "$url" \
--header 'Content-Type: application/json' \
--header "apiKey: $bapikey" \
--data-raw "$data"`
echo $result | jq
btoken=`echo $result | jq -r .accessToken`
echo "btoken=$btoken"
```

<details closez>
<summary>サンプル出力</summary>

```
{
  "accessToken": "eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJvcGVyYXRvcl9pZCI6IjE1NTcyZDFjLWVjMTMtMGQ3OC03ZjkyLWRkNDI3ODg3MTM3MyIsImVtYWlsIjoic3VwcGxpZXJfYkBleGFtcGxlLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiYXV0aF90aW1lIjoxNzI3MDE5ODk1LCJ1c2VyX2lkIjoiZGExMGI3ZjUtM2RiMC00NmI5LTgwMjUtZDNiNDRhMTBjZmJhIiwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJlbWFpbCI6WyJzdXBwbGllcl9iQGV4YW1wbGUuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifSwiaWF0IjoxNzI3MDE5ODk1LCJleHAiOjE3MjcwMjM0OTUsImF1ZCI6ImxvY2FsIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL2xvY2FsIiwic3ViIjoiZGExMGI3ZjUtM2RiMC00NmI5LTgwMjUtZDNiNDRhMTBjZmJhIn0.",
  "refreshToken": "eyJfQXV0aEVtdWxhdG9yUmVmcmVzaFRva2VuIjoiRE8gTk9UIE1PRElGWSIsImxvY2FsSWQiOiJkYTEwYjdmNS0zZGIwLTQ2YjktODAyNS1kM2I0NGExMGNmYmEiLCJwcm92aWRlciI6InBhc3N3b3JkIiwiZXh0cmFDbGFpbXMiOnt9LCJwcm9qZWN0SWQiOiJsb2NhbCJ9"
}
btoken=eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJvcGVyYXRvcl9pZCI6IjE1NTcyZDFjLWVjMTMtMGQ3OC03ZjkyLWRkNDI3ODg3MTM3MyIsImVtYWlsIjoic3VwcGxpZXJfYkBleGFtcGxlLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiYXV0aF90aW1lIjoxNzI3MDE5ODk1LCJ1c2VyX2lkIjoiZGExMGI3ZjUtM2RiMC00NmI5LTgwMjUtZDNiNDRhMTBjZmJhIiwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJlbWFpbCI6WyJzdXBwbGllcl9iQGV4YW1wbGUuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifSwiaWF0IjoxNzI3MDE5ODk1LCJleHAiOjE3MjcwMjM0OTUsImF1ZCI6ImxvY2FsIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL2xvY2FsIiwic3ViIjoiZGExMGI3ZjUtM2RiMC00NmI5LTgwMjUtZDNiNDRhMTBjZmJhIn0.
```

</details>


CompanyB can use api to get his operatorid, but we already have it as boperatorid

2. 事業所の登録

    実行者：B社

```
# CompanyB plant id
bopenplantid=1234567890124012345
```

```
# CompanyB create plant
url="http://localhost:8081/api/v1/authInfo?dataTarget=plant"
data="{
  \"openPlantId\": \"$bopenplantid\",
  \"operatorId\": \"$boperatorid\",
  \"plantAddress\": \"xx県xx市xxxx町2-1-1234\",
  \"plantId\": null,
  \"plantName\": \"B工場\",
  \"plantAttribute\": {}
}"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $bapikey" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $btoken" \
--data "$data"`
echo $result | jq
bplantid=`echo $result | jq -r .plantId`
echo "bplantid=$bplantid"
```

<details closez>
<summary>サンプル出力</summary>

```
{
  "plantId": "37b2d740-e200-4a79-9181-27bedf2873d9",
  "operatorId": "15572d1c-ec13-0d78-7f92-dd4278871373",
  "plantName": "B工場",
  "plantAddress": "xx県xx市xxxx町2-1-1234",
  "openPlantId": "1234567890124012345",
  "plantAttribute": {
    "globalPlantId": null
  }
}
bplantid=37b2d740-e200-4a79-9181-27bedf2873d9
```

</details>


3. 親部品情報の作成
   
    実行者：B社

```
# CompanyB create part
url="http://localhost:8080/api/v1/datatransport?dataTarget=parts"
data="{
  \"amountRequired\": null,
  \"amountRequiredUnit\": \"kilogram\",
  \"operatorId\": \"$boperatorid\",
  \"partsName\": \"部品B\",
  \"plantId\": \"$bplantid\",
  \"supportPartsName\": \"modelB\",
  \"terminatedFlag\": true,
  \"traceId\": null
}"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $bapikey" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $btoken" \
--data "$data"`
echo $result | jq
btraceid=`echo $result | jq -r .traceId`
echo "btraceid=$btraceid"
```

<details closez>
<summary>サンプル出力</summary>

```
{
  "traceId": "5bee5dbe-f70a-4f6c-835b-a129f794a6aa",
  "operatorId": "15572d1c-ec13-0d78-7f92-dd4278871373",
  "plantId": "37b2d740-e200-4a79-9181-27bedf2873d9",
  "partsName": "部品B",
  "supportPartsName": "modelB",
  "terminatedFlag": true,
  "amountRequired": null,
  "amountRequiredUnit": "kilogram"
}
btraceid=5bee5dbe-f70a-4f6c-835b-a129f794a6aa
```

</details>


4. 部品登録紐付けの依頼確認
   
    実行者：B社

```
# CompanyB check trade response
url="http://localhost:8080/api/v1/datatransport?dataTarget=tradeResponse"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $bapikey" \
--header "Authorization: Bearer $btoken"`
echo $result | jq
btradeid=`echo $result | jq -r .[0].statusModel.tradeId`
echo "btradeid=$btradeid"
```

<details closez>
<summary>サンプル出力</summary>

```
[
  {
    "statusModel": {
      "statusId": "dc3746af-9104-41b5-8a64-438167570de3",
      "tradeId": "e45c0bb8-ff5b-4f62-b392-411c5eb7d2b0",
      "requestStatus": {
        "cfpResponseStatus": "NOT_COMPLETED",
        "tradeTreeStatus": "UNTERMINATED"
      },
      "message": "来月中にご回答をお願いします。",
      "replyMessage": null,
      "requestType": "CFP"
    },
    "tradeModel": {
      "tradeId": "e45c0bb8-ff5b-4f62-b392-411c5eb7d2b0",
      "downstreamOperatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
      "upstreamOperatorId": "15572d1c-ec13-0d78-7f92-dd4278871373",
      "downstreamTraceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
      "upstreamTraceId": null
    },
    "partsModel": {
      "traceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
      "operatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
      "plantId": "170c0850-6aae-4269-8e08-f71e4fab9b52",
      "partsName": "部品A1",
      "supportPartsName": "modelA-1",
      "terminatedFlag": false,
      "amountRequired": null,
      "amountRequiredUnit": "kilogram"
    }
  }
]
btradeid=e45c0bb8-ff5b-4f62-b392-411c5eb7d2b0
```

</details>


5. 部品登録紐付けの登録
  
   実行者：B社

```
# CompanyB link part
url="http://localhost:8080/api/v1/datatransport?dataTarget=tradeResponse&tradeId=$btradeid&traceId=$btraceid"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $bapikey" \
--header "Authorization: Bearer $btoken"`
echo $result | jq
```

<details closez>
<summary>サンプル出力</summary>

```
{
  "tradeId": "e45c0bb8-ff5b-4f62-b392-411c5eb7d2b0",
  "downstreamOperatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
  "upstreamOperatorId": "15572d1c-ec13-0d78-7f92-dd4278871373",
  "downstreamTraceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
  "upstreamTraceId": "5bee5dbe-f70a-4f6c-835b-a129f794a6aa"
}
```

</details>


### B社からA社へCFP情報の伝達をする(基本フロー3 #5)

  1. 製品にCFP情報を登録
   
      実行者：B社

```
# CompanyB register CFP data
url="http://localhost:8080/api/v1/datatransport?dataTarget=cfp"
data="[
  {
    \"cfpId\": null,
    \"traceId\": \"$btraceid\",
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
    \"traceId\": \"$btraceid\",
    \"ghgEmission\": 10.0,
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
    \"traceId\": \"$btraceid\",
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
    \"traceId\": \"$btraceid\",
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
--header "apiKey: $bapikey" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $btoken" \
--data "$data"`
echo $result | jq
```

<details closez>
<summary>サンプル出力</summary>

```
[
  {
    "cfpId": "98dd124f-be2c-4657-8169-c9b15cd758c7",
    "traceId": "5bee5dbe-f70a-4f6c-835b-a129f794a6aa",
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
    "cfpId": "98dd124f-be2c-4657-8169-c9b15cd758c7",
    "traceId": "5bee5dbe-f70a-4f6c-835b-a129f794a6aa",
    "ghgEmission": 10,
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
    "cfpId": "98dd124f-be2c-4657-8169-c9b15cd758c7",
    "traceId": "5bee5dbe-f70a-4f6c-835b-a129f794a6aa",
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
    "cfpId": "98dd124f-be2c-4657-8169-c9b15cd758c7",
    "traceId": "5bee5dbe-f70a-4f6c-835b-a129f794a6aa",
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
]
```

</details>



### B社の回答情報の取得およびA社の完成品のCFPを算出(基本フロー3 #6, #2)

1. 回答依頼情報の取得

    実行者：A社

```
# CompanyA get trade response
url="http://localhost:8080/api/v1/datatransport?dataTarget=tradeRequest"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $aapikey" \
--header "Authorization: Bearer $atoken"`
echo $result | jq
atraceidb=`echo $result | jq -r .[0].downstreamTraceId`
echo "atraceidb=$atraceidb"
```

<details closez>
<summary>サンプル出力</summary>

```
[
  {
    "tradeId": "e45c0bb8-ff5b-4f62-b392-411c5eb7d2b0",
    "downstreamOperatorId": "b39e6248-c888-56ca-d9d0-89de1b1adc8e",
    "upstreamOperatorId": "15572d1c-ec13-0d78-7f92-dd4278871373",
    "downstreamTraceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
    "upstreamTraceId": "5bee5dbe-f70a-4f6c-835b-a129f794a6aa"
  }
]
atraceidb=8ebd21b5-9620-4fb7-b786-de8884ffd3d1
```

</details>


2. 依頼情報のステータスを確認
  
     実行者：A社

```
# CompanyA get response status
url="http://localhost:8080/api/v1/datatransport?dataTarget=status&statusTarget=REQUEST&traceId=$atraceidb"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $aapikey" \
--header "Authorization: Bearer $atoken"`
echo $result | jq
```

<details closez>
<summary>サンプル出力</summary>

```
[
  {
    "statusId": "dc3746af-9104-41b5-8a64-438167570de3",
    "tradeId": "e45c0bb8-ff5b-4f62-b392-411c5eb7d2b0",
    "requestStatus": {
      "cfpResponseStatus": "COMPLETED",
      "tradeTreeStatus": "TERMINATED"
    },
    "message": "来月中にご回答をお願いします。",
    "replyMessage": null,
    "requestType": "CFP"
  }
]
```

</details>


### 完成品のCFP情報を算出する

1. 製品にCFP情報を登録
   
    実行者：A社

```
# CompanyA get complete CFP data
url="http://localhost:8080/api/v1/datatransport?dataTarget=cfp"
data="[
    {
        \"cfpId\": null,
        \"traceId\": \"$btraceid\",
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
        \"traceId\": \"$btraceid\",
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
        \"traceId\": \"$btraceid\",
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
        \"traceId\": \"$btraceid\",
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
--header "apiKey: $aapikey" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $atoken" \
--data "$data"`
echo $result | jq
```

<details closez>
<summary>サンプル出力</summary>

```
[
  {
    "cfpId": "97c7072a-f70a-4711-9b67-e71efb92ab8c",
    "traceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
    "ghgEmission": 3,
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
    "cfpId": "97c7072a-f70a-4711-9b67-e71efb92ab8c",
    "traceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
    "ghgEmission": 20,
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
    "cfpId": "97c7072a-f70a-4711-9b67-e71efb92ab8c",
    "traceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
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
    "cfpId": "97c7072a-f70a-4711-9b67-e71efb92ab8c",
    "traceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
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
]
```

</details>


### 完成品のCFP情報を算出する

2. 登録したCFPの値を取得

    実行者：A社

```
# CompanyA get complete CFP calculation
url="http://localhost:8080/api/v1/datatransport?dataTarget=cfp&traceIds=$atraceidb"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $aapikey" \
--header "Authorization: Bearer $atoken"`
echo $result | jq
```

<details closez>
<summary>サンプル出力</summary>

```
[
  {
    "cfpId": null,
    "traceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
    "ghgEmission": 1.5,
    "ghgDeclaredUnit": "kgCO2e/kilogram",
    "cfpType": "preProductionResponse",
    "dqrType": "preProcessingResponse",
    "dqrValue": {
      "TeR": 2.1,
      "GeR": 0,
      "TiR": null
    }
  },
  {
    "cfpId": null,
    "traceId": "8ebd21b5-9620-4fb7-b786-de8884ffd3d1",
    "ghgEmission": 10,
    "ghgDeclaredUnit": "kgCO2e/kilogram",
    "cfpType": "mainProductionResponse",
    "dqrType": "mainProcessingResponse",
    "dqrValue": {
      "TeR": 2.1,
      "GeR": 0,
      "TiR": null
    }
  }
]
```

</details>


### Reset

```
docker compose down
docker stop authenticator-backend
docker stop data-spaces-backend
docker rm authenticator-backend
docker rm data-spaces-backend
docker ps -a
docker volume ls
docker volume rm user-authentication-system_db-vol
docker volume ls
```


