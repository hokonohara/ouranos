cd -/workspace/user-authentication-system
docker compose up -d
sleep 5


export POSTGRESQL_URL='postgres://dhuser:passw0rd@localhost:5432/dhlocal?sslmode=disable'
migrate -path setup/migrations -database ${POSTGRESQL_URL} up

./setup/setup_seeds.sh

make idp-add-local

docker run \
 -v $(pwd)/config/:/app/config/ \
 -td -i --network docker.internal \
 --env-file config/local.env \
 -p 8080:8080 \
 --name data-spaces-backend data-spaces-backend

docker run \
 -v $(pwd)/config/:/app/config/ \
 -td -i --network docker.internal \
 --env-file config/local.env \
 -p 8081:8081 \
 --name authenticator-backend authenticator-backend

 docker ps -a --format "{{.Name}}\t{{.State}}"
 