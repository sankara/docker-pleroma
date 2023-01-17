# Specify all repeat variables in the .env file
.EXPORT_ALL_VARIABLES:
include .env

init: setup-dirs setup-postgres-ext 

start: build run

run:
	sudo @DB_PASS=$(DB_PASSWORD) @POSTGRES_PASSWORD=$(DB_PASSWORD) docker-compose up -d

setup-dirs:
	mkdir -p uploads config
	sudo chown -R 911:911 uploads

setup-postgres-ext:
	sudo @DB_PASS=$(DB_PASSWORD) @POSTGRES_PASSWORD=$(DB_PASSWORD) docker-compose up -d db
	sleep 10
	sudo docker exec -i pleroma_db psql -U pleroma -c "CREATE EXTENSION IF NOT EXISTS citext;"
	sudo docker-compose down

pull:
	sudo docker-compose pull
build:
	sudo docker-compose build web

clean:
	sudo @DB_PASS=$(DB_PASSWORD) @POSTGRES_PASSWORD=$(DB_PASSWORD) docker-compose run --rm web mix ecto.migrate # migrate the database if needed
	
logs:
	sudo docker logs -f pleroma_web

create-admin:
	sudo docker exec -it pleroma_web sh ./bin/pleroma_ctl user new $(username) $(email) --admin

update: stop build clean run

stop:
	sudo docker-compose down

bounce: stop run
