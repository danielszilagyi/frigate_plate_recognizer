#!/usr/bin/with-contenv bashio

CONFIG_PATH=/data/options.json

export OWN_CONFIG_PATH="$(bashio::config 'configpath')"
export DB_PATH="$(bashio::config 'dbpath')"
export LOG_FILE="$(bashio::config 'logfile')"
export SNAPSHOT_PATH="$(bashio::config 'snapshotpath')"

cd /usr/src/app
python ./index.py
