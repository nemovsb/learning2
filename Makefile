OS=$(shell uname -o)
PROJECTNAME=$(shell basename "$(PWD)")

# COLORED OUTPUT
GREEN=
LGREEN=
YELLOW=
ORANGE=
NC=# No Color

ifeq (${OS}, GNU/Linux)
GREEN=\033[1;32m
LGREEN=\033[0;32m
YELLOW=\033[1;33m
ORANGE=\033[0;33m
NC=\033[0m # No Color
endif


.PHONY: all help build test start migration-down wire-gen mockgen-gen

all: help
help:
	@echo
	@echo " For correct :to work correctly, do not forget to create a config folder with files. You can take it from the /example folder and reconfigure it"
	@echo
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | column -t -s ':' | sed -e 's/\\$$//' | sed -e 's/##//'
	@echo

## build: build project
build:
	@echo
	go build
	@echo ">${GREEN} complete${NC}"
	@echo

## test: run unit tests
test:
	@echo ">${YELLOW} Running unit tests...${NC}"
	go test -v ./...
	@echo ">${GREEN} All tests passed${NC}"

## start: start project
start:
	@echo ">${GREEN} start service${NC}"
	./app1
	@echo

## build for docker-compose
GOOS=linux
GOARCH=amd64
CGO_ENABLED=0

ifeq ($(OS), Msys)
GOOS=windows
endif

BUILD_DIR=build/package
BUILDVARS=GOOS=${GOOS} GOARCH=${GOARCH} CGO_ENABLED=${CGO_ENABLED}
DOCKER_BUILDVARS=GOOS=linux GOARCH=${GOARCH} CGO_ENABLED=${CGO_ENABLED}

build-for-compose:
	@echo
	${DOCKER_BUILDVARS} go build -o serverTCP -ldflags "-s -w"
	@echo ">${GREEN} complete${NC}"
	@echo

## go-mod-verify: clean and verify go modules
go-mod-verify:
	@echo ">${YELLOW} Fixing modules...${NC}"
	@echo "  >${ORANGE} Adding missing and removing unused modules...${NC}"
	go mod tidy
	@echo "  >${ORANGE} Verifying dependencies have expected content...${NC}"
	go mod verify
	@echo ">${GREEN} Modules fixed${NC}"

## lint: perform static code analysis with golangci-lint tool (more than 30 linters inside)
lint:
	@echo ">${YELLOW} Linting source files with auto-fix...${NC}"
	go run github.com/golangci/golangci-lint/cmd/golangci-lint run
	@echo ">${GREEN} Source files fine${NC}"

## fmt: format all source files
fmt:
	@echo ">${YELLOW} Formating source files...${NC}"
	go fmt ./...
	@echo ">${GREEN} Source files formatted${NC}"

## pre-commit: make sure the commit is safe
pre-commit: go-mod-verify fmt build test lint
	@echo ">${GREEN} Commit can be made${NC}"

