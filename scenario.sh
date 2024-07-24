
aapikey=Sample-APIKey1
aaccountid="oem_a@example.com"
aaccountpass="oemA&user_01"

read -n 1 -p "press any key to continue"

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
atoken=`echo $result | jq -r .accessToken`
echo "atoken=$atoken"

read -n 1 -p "press any key to continue"

# CompanyA check access token, get operatorId
url="http://localhost:8081/api/v1/authInfo?dataTarget=operator"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $aapikey" \
--header "Authorization: Bearer $atoken"`
echo $result | jq
aoperatorid=`echo $result | jq -r .operatorId`
echo "aoperatorid=$aoperatorid"

read -n 1 -p "press any key to continue"

aopenplantid=1234567890123012345

read -n 1 -p "press any key to continue"

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
aplantid=`echo $result | jq -r .plantId`
echo "aplantid=$aplantid"

read -n 1 -p "press any key to continue"

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
atraceid1=`echo $result | jq -r .traceId`
echo "atraceid1=$atraceid1"

read -n 1 -p "press any key to continue"

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
atraceid2=`echo $result | jq -r .childrenPartsModel[0].traceId`
echo "atraceid2=$atraceid2"

read -n 1 -p "press any key to continue"

operatorb=1234567890124

read -n 1 -p "press any key to continue"

# CompanyA find company B operatorId
url="http://localhost:8081/api/v1/authInfo?dataTarget=operator&openOperatorId=$operatorb"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $aapikey" \
--header "Authorization: Bearer $atoken"`
echo $result | jq
boperatorid=`echo $result | jq -r .operatorId`
echo "boperatorid=$boperatorid"

read -n 1 -p "press any key to continue"

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

read -n 1 -p "press any key to continue"

bapikey=Sample-APIKey2
baccountid="supplier_b@example.com"
baccountpass="supplierB&user_01"

read -n 1 -p "press any key to continue"

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

read -n 1 -p "press any key to continue"

bopenplantid=1234567890124012345

read -n 1 -p "press any key to continue"

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

read -n 1 -p "press any key to continue"

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

read -n 1 -p "press any key to continue"

url="http://localhost:8080/api/v1/datatransport?dataTarget=tradeResponse"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $bapikey" \
--header "Authorization: Bearer $btoken"`
echo $result | jq
btradeid=`echo $result | jq -r .[0].statusModel.tradeId`
echo "btradeid=$btradeid"

read -n 1 -p "press any key to continue"

url="http://localhost:8080/api/v1/datatransport?dataTarget=tradeResponse&tradeId=$btradeid&traceId=$btraceid"
result=`curl -s --location --request PUT "$url" \
--header "apiKey: $bapikey" \
--header "Authorization: Bearer $btoken"`
echo $result | jq

read -n 1 -p "press any key to continue"

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

read -n 1 -p "press any key to continue"

url="http://localhost:8080/api/v1/datatransport?dataTarget=tradeRequest"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $aapikey" \
--header "Authorization: Bearer $atoken"`
echo $result | jq
atraceidb=`echo $result | jq -r .[0].downstreamTraceId`
echo "atraceidb=$atraceidb"

read -n 1 -p "press any key to continue"

url="http://localhost:8080/api/v1/datatransport?dataTarget=status&statusTarget=REQUEST&traceId=$atraceidb"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $aapikey" \
--header "Authorization: Bearer $atoken"`
echo $result | jq

read -n 1 -p "press any key to continue"

url="http://localhost:8080/api/v1/datatransport?dataTarget=cfp"
data="[
    {
        \"cfpId\": null,
        \"traceId\": \"$atraceidb\",
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
        \"traceId\": \"$atraceidb\",
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
        \"traceId\": \"$atraceidb\",
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
        \"traceId\": \"$atraceidb\",
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

read -n 1 -p "press any key to continue"

url="http://localhost:8080/api/v1/datatransport?dataTarget=cfp&traceIds=$atraceidb"
result=`curl -s --location --request GET "$url" \
--header "apiKey: $aapikey" \
--header "Authorization: Bearer $atoken"`
echo $result | jq

