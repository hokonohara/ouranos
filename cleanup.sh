cd ~/ouranos/user-authentication-system
docker compose down
docker stop authenticator-backend
docker stop data-spaces-backend
docker rm authenticator-backend
docker rm data-spaces-backend
docker ps -a

docker volume rm user-authentication-system_db-vol
docker volume list



