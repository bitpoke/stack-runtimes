#!/bin/sh
set -e
apt-get clean
apt-get autoremove --purge -y

rm -rf /var/lib/apt/lists/*

# No need for the cache
rm -rf /var/cache/apt

# Remove pecl temp_dir
rm -rf "$(pecl config-get temp_dir)"
