#!/usr/bin/env bash

sudo mkdir -p /etc/thunderbird/policies

sudo curl -sS -o /etc/thunderbird/policies/policies.json \
    https://raw.githubusercontent.com/ayu2805/policies/main/thunderbird/thunderbird_policies.json

printf '\033[32m%s\033[0m\n' "Thunderbird policies have been applied successfully."
printf '\033[33m%s\033[0m\n' "Restart Thunderbird, then check about:policies."