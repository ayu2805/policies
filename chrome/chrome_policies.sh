#!/usr/bin/env bash

sudo mkdir -p /etc/opt/chrome/policies/managed

sudo curl -sS https://raw.githubusercontent.com/ayu2805/policies/main/chrome/chrome_policies.json \
-o /etc/opt/chrome/policies/managed/policies.json


printf '\033[32m%s\033[0m\n' "Chrome policies have been applied successfully."
printf '\033[33m%s\033[0m\n' "Restart Chrome, then check chrome://policy."