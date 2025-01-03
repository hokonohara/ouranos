
const AuthServer =  "http://localhost:8081";
const DTSServer = "http://localhost:8080";
const apiKey = "Sample-APIKey1";
const operatorAccountId = "oem_a@example.com";
const accountPassword = "oemA&user_01";
var accessToken;
var refreshToken;
var operatorId;


// Get Token
async function getToken() {
    var data = {
        "operatorAccountId": operatorAccountId,
        "accountPassword": accountPassword
    };
    await fetch(AuthServer + '/auth/login', {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "apiKey": apiKey
        },
        body: JSON.stringify(data)
    })
    .then((response) => response.json())
    .then((json) => {
        accessToken = json.accessToken;
        refreshToken = json.refreshToken;
        console.log(json);
    })
    .catch((error) => {
        console.log(error);
    });
}

// Refresh Token
// TBD

// Get operatorId
async function getOperatorId() {
    await fetch(AuthServer + '/api/v1/authInfo?dataTarget=operator', {
        method: "GET",
        headers: {
            "apiKey": apiKey,
            "Authorization": "Bearer " + accessToken
        },
    })
    .then((response) => response.json())
    .then((json) => {
        operatorId = json.operatorId;
        console.log(json);
    })
    .catch((error) => {
        console.log(error);
    });
}


// 

getToken()
.then (() => {
    console.log(accessToken);
    getOperatorId()
    .then (() => {
        console.log(operatorId);
    });
});

