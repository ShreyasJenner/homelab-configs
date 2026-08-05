#!/bin/bash

SRC_DIR="$HOME/docker/"
DEST_DIR="$HOME/repos/homelab-configs/"
FILENAME="docker-compose.yml"

cd "$SRC_DIR" || exit 1

find . -type f -name "$FILENAME" -exec cp --parents {} "$DEST_DIR" \;
