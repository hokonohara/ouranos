cd ~/ouranos/user-authentication-system

docker stop authenticator-backend
docker stop data-spaces-backend
docker rm authenticator-backend
docker rm data-spaces-backend
docker compose down
docker ps -a

docker volume rm user-authentication-system_db-vol
docker volume list



