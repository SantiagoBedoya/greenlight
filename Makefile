# DATABASE_DSN = "postgres://postgres:postgres@localhost/greenlight?sslmode=disable"
include .envrc

.PHONY: run
run:
	go run ./cmd/api -db-dsn=${GREENLIGHT_DB_DSN}

.PHONY: migration
migration:
	migrate create -seq -ext .sql -dir ./migrations ${name}

.PHONY: migrate-up
migrate-up:
	migrate -path=./migrations -database=${GREENLIGHT_DB_DSN} up

.PHONY: migrate-down
migrate-down:
	migrate -path=./migrations -database=${GREENLIGHT_DB_DSN} down

.PHONY: psql
psql:
	docker exec -ti postgres psql -U postgres

.PHONY: audit
audit:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...

.PHONY: vendor
vendor:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor

.PHONY: build
build:
	go build -ldflags='-s' -o=./bin/api ./cmd/api