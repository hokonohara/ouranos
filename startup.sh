cd -/workspace/user-authentication-system
docker compose up -d
sleep 5

read -n 1

export POSTGRESQL_URL='postgres://dhuser:passw0rd@localhost:5432/dhlocal?sslmode=disable'
migrate -path setup/migrations -database ${POSTGRESQL_URL} up

read -n 1

./setup/setup_seeds.sh

read -n 1

make idp-add-local

read -n 1

docker run \
 -v $(pwd)/config/:/app/config/ \
 -td -i --network docker.internal \
 --env-file config/local.env \
 -p 8080:8080 \
 --name data-spaces-backend data-spaces-backend

read -n 1

docker run \
 -v $(pwd)/config/:/app/config/ \
 -td -i --network docker.internal \
 --env-file config/local.env \
 -p 8081:8081 \
 --name authenticator-backend authenticator-backend

 read -n 1
 
 docker ps -a --format "{{.Name}}\t{{.State}}"
