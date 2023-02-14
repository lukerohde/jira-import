#!/bin/bash

[ -z "$1" ] && echo "Usage: $0 file.xlsx" && exit 1

[ ! -f "$1" ] && echo "File not found: $1" && exit 1

cp "$1" app/import.xlsx

docker-compose build
docker-compose up --abort-on-container-exit app
