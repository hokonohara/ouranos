cd ~/ouranos/user-authentication-system
docker compose up -d
sleep 5

read -n 1 -p "press any key to continue"

export POSTGRESQL_URL='postgres://dhuser:passw0rd@localhost:5432/dhlocal?sslmode=disable'
migrate -path setup/migrations -database ${POSTGRESQL_URL} up

read -n 1 -p "press any key to continue"

./setup/setup_seeds.sh

read -n 1 -p "press any key to continue"

make idp-add-local

read -n 1 -p "press any key to continue"

docker run \
 -v ~/ouranos/data-transaction-system/config/:/app/config/ \
 -td -i --network docker.internal \
 --env-file ~/ouranos/data-transaction-system/config/local.env \
 -p 8080:8080 \
 --name data-spaces-backend data-spaces-backend

read -n 1 -p "press any key to continue"

docker run \
 -v ~/ouranos/user-authentication-system/config/:/app/config/ \
 -td -i --network docker.internal \
 --env-file ~/ouranos/user-authentication-system/config/local.env \
 -p 8081:8081 \
 --name authenticator-backend authenticator-backend

 read -n 1 -p "press any key to continue"

 docker ps -a --format "{{.Names}}\t{{.State}}"
