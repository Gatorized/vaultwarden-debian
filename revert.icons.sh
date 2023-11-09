#!/bin/bash
set -o errexit

# Pull new web-vault from Dockerfile
sha=$(sed -n 's/FROM --platform=linux\/amd64 docker.io\/vaultwarden\/web-vault@\([^[:space:]]*\).*/\1/p' Dockerfile)
docker pull docker.io/vaultwarden/web-vault@$sha
instance=$(docker create docker.io/vaultwarden/web-vault@$sha)

# Pull old vault with sexy bitwarden icons
docker pull docker.io/vaultwarden/web-vault:v2022.10.1
old_vault_instance=$(docker create docker.io/vaultwarden/web-vault:v2022.10.1)

# dump old icons into local directory
docker cp $old_vault_instance:/web-vault web-vault.v2022.10.1

# replace new web-vault icons with old icons. icon-dark/icon-white don't seem to exist in previous image, so just replace with favicon
docker cp web-vault.v2022.10.1/favicon.ico $instance:/web-vault/favicon.ico
docker cp web-vault.v2022.10.1/images/apple-touch-icon.png $instance:/web-vault/images/apple-touch-icon.png
docker cp web-vault.v2022.10.1/images/favicon-16x16.png $instance:/web-vault/images/favicon-16x16.png
docker cp web-vault.v2022.10.1/images/favicon-32x32.png $instance:/web-vault/images/favicon-32x32.png
docker cp web-vault.v2022.10.1/images/favicon-32x32.png $instance:/web-vault/images/icon-dark.png
docker cp web-vault.v2022.10.1/images/favicon-32x32.png $instance:/web-vault/images/icon-white.png
docker cp web-vault.v2022.10.1/images/logo-dark@2x.png $instance:/web-vault/images/logo-dark@2x.png
docker cp web-vault.v2022.10.1/images/logo-white@2x.png $instance:/web-vault/images/logo-white@2x.png
docker cp web-vault.v2022.10.1/images/icons/android-chrome-192x192.png $instance:/web-vault/images/icons/android-chrome-192x192.png
docker cp web-vault.v2022.10.1/images/icons/android-chrome-512x512.png $instance:/web-vault/images/icons/android-chrome-512x512.png
docker cp web-vault.v2022.10.1/images/icons/apple-touch-icon.png $instance:/web-vault/images/icons/apple-touch-icon.png
docker cp web-vault.v2022.10.1/images/icons/favicon-16x16.png $instance:/web-vault/images/icons/favicon-16x16.png
docker cp web-vault.v2022.10.1/images/icons/favicon-32x32.png $instance:/web-vault/images/icons/favicon-32x32.png
docker cp web-vault.v2022.10.1/images/icons/mstile-150x150.png $instance:/web-vault/images/icons/mstile-150x150.png
docker cp web-vault.v2022.10.1/images/icons/safari-pinned-tab.svg $instance:/web-vault/images/icons/safari-pinned-tab.svg

# commit patched web-vault as docker.io/vaultwarden/web-vault
ref=$(docker commit $instance)
docker tag $ref docker.io/vaultwarden/web-vault:local

# Replace web-vault reference in Dockerfile with docker.io/vaultwarden/web-vault:local
sed -i.bak 's/FROM --platform=linux\/amd64 docker.io\/vaultwarden\/web-vault@sha256:[^[:space:]]* as vault/FROM --platform=linux\/amd64 docker.io\/vaultwarden\/web-vault:local as vault/' Dockerfile

# Cleanup
docker rm $instance
docker rm $old_vault_instance

echo "Replaced old icons in new web-vault ($sha)"
