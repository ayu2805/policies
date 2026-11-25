#!/usr/bin/env bash

sudo mkdir -p /etc/firefox/policies

sudo curl -o /etc/firefox/policies/policies.json \
    https://raw.githubusercontent.com/ayu2805/policies/main/firefox/firefox_policies.json

sudo curl -o /usr/lib/firefox/defaults/pref/autoconfig.js \
    https://raw.githubusercontent.com/ayu2805/policies/main/firefox/firefox_autoconfig.js

sudo curl -o /usr/lib/firefox/firefox_pref.cfg \
    https://raw.githubusercontent.com/ayu2805/policies/main/firefox/firefox_preferences.cfg

printf '\033[32m%s\033[0m\n' "Firefox policies have been applied successfully."
printf '\033[33m%s\033[0m\n' "Restart Firefox, then check about:policies."