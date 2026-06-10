#!/bin/bash

docker run --rm -it \
  -v "$PWD":/app \
  -w /app \
  -u $(id -u):$(id -g) \
  -e TF_VAR_proxmox_token_id="$PROXMOX_TOKEN_ID" \
  -e TF_VAR_proxmox_token_secret="$PROXMOX_TOKEN_SECRET" \
  hashicorp/terraform:1.14.6 "$@"
