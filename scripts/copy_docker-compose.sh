#!/bin/bash

SRC_DIR="$HOME/docker/"
DEST_DIR="$HOME/repos/homelab-configs/"
FILENAME="docker-compose.yml"
FILENAME2="service-list.txt"

cd "$SRC_DIR" || exit 1

find . -type f -name "$FILENAME" -exec cp --parents {} "$DEST_DIR" \;

cp -- "${SRC_DIR%/}/${FILENAME2}" "$DEST_DIR"
