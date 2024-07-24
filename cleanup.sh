cd -/workspace
docker compose down
docker stop authenticator-backend
docker stop data-spaces-backend
docker rm authenticator-backend
docker rm data-spaces-backend

docker volume rm user-authentication-system_db-vol


