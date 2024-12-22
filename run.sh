#!/usr/bin/with-contenv bashio

CONFIG_PATH=/data/options.json

# Set up env variables for index.py, use shared addon_data for now (same path with app originally)
export CONFIG_PATH="/config/config.yml"
export DB_PATH="/config/frigate_plate_recognizer.db"
export LOG_FILE="/config/frigate_plate_recognizer.log"
export SNAPSHOT_PATH="/config/plates"

export log_level="$(bashio::config 'log_level')"
export frigate_url="$(bashio::config 'frigate_url')"
declare -a camera
camera+=($(bashio::config 'camera'))
declare -a objects
objects+=($(bashio::config 'objects'))
export mqtt_username="$(bashio::config 'mqtt_username')"
export mqtt_password="$(bashio::config 'mqtt_password')"
export mqtt_server="$(bashio::config 'mqtt_server')"
export main_topic="$(bashio::config 'frigate.main_topic')"
export return_topic="$(bashio::config 'frigate.return_topic')"
export frigate_plus="$(bashio::config 'frigate.frigate_plus')"
export min_score="$(bashio::config 'frigate.min_score')"
export always_save_snapshot="$(bashio::config 'frigate.always_save_snapshot')"
export save_snapshots="$(bashio::config 'frigate.save_snapshots')"
export max_attempts="$(bashio::config 'frigate.max_attempts')"
export draw_box="$(bashio::config 'frigate.draw_box')"
export pr_token="$(bashio::config 'plate_recognizer_token')"
export cpai_url="$(bashio::config 'code_project_api_url')"
export fuzzy_match="$(bashio::config 'frigate.fuzzy_match')"
declare -a watched_plates
watched_plates+=($(bashio::config 'watched_plates'))
declare -a regions
regions+=($(bashio::config 'plate_recognizer_regions'))


# Put config in its place
if ! bashio::fs.file_exists "${CONFIG_PATH}"; then
    touch "${CONFIG_PATH}"
fi

# Set up the app config based on the addon options
yq --inplace e '.logger_level = env(log_level)' "${CONFIG_PATH}"
yq --inplace e '.frigate.frigate_url = env(frigate_url)' "${CONFIG_PATH}"

yq --inplace e '.frigate.camera = []' "${CONFIG_PATH}"
  for cam in "${camera[@]}"; do
    cam="${cam}" yq --inplace e \
      '.frigate.camera += [env(cam)]' "${CONFIG_PATH}" \
        || bashio::exit.nok 'Failed updating camera list'
  done

yq --inplace e '.frigate.objects = []' "${CONFIG_PATH}"
  for obj in "${objects[@]}"; do
    obj="${obj}" yq --inplace e \
      '.frigate.objects += [env(obj)]' "${CONFIG_PATH}" \
        || bashio::exit.nok 'Failed updating object list'
  done

yq --inplace e '.frigate.watched_plates = []' "${CONFIG_PATH}"
  for plate in "${watched_plates[@]}"; do
    plate="${plate}" yq --inplace e \
      '.frigate.watched_plates += [env(plate)]' "${CONFIG_PATH}" \
        || bashio::exit.nok 'Failed updating watched plates list'
  done

yq --inplace e '.frigate.mqtt_server = env(mqtt_server)' "${CONFIG_PATH}"

if $(bashio::config 'mqtt_auth'); then
    
    yq --inplace e '.frigate.mqtt_auth = true' "${CONFIG_PATH}"
    yq --inplace e '.frigate.mqtt_username = env(mqtt_username)' "${CONFIG_PATH}"
    yq --inplace e '.frigate.mqtt_password = env(mqtt_password)' "${CONFIG_PATH}"

fi

yq --inplace e '.frigate.main_topic = env(main_topic)' "${CONFIG_PATH}"
yq --inplace e '.frigate.return_topic = env(return_topic)' "${CONFIG_PATH}"

if $(bashio::config 'frigate.frigate_plus'); then
yq --inplace e '.frigate.frigate_plus = true' "${CONFIG_PATH}"
fi

yq --inplace e '.frigate.min_score = env(min_score)' "${CONFIG_PATH}"
yq --inplace e '.frigate.max_attempts = env(max_attempts)' "${CONFIG_PATH}"
yq --inplace e '.frigate.fuzzy_match = env(fuzzy_match)' "${CONFIG_PATH}"
yq --inplace e '.frigate.always_save_snapshot = env(always_save_snapshot)' "${CONFIG_PATH}"
yq --inplace e '.frigate.save_snapshots = env(save_snapshots)' "${CONFIG_PATH}"
yq --inplace e '.frigate.draw_box = env(draw_box)' "${CONFIG_PATH}"

# Plate recognizer
if $(bashio::config 'plate_recognizer_enabled'); then
yq --inplace e '.plate_recognizer.token = env(pr_token)' "${CONFIG_PATH}"
yq --inplace e '.plate_recognizer.regions = []' "${CONFIG_PATH}"
  for reg in "${regions[@]}"; do
    reg="${reg}" yq --inplace e \
      '.plate_recognizer.regions += [env(reg)]' "${CONFIG_PATH}" \
        || bashio::exit.nok 'Failed updating region list'
  done
fi

# CP.AI
if $(bashio::config 'code_project_enabled'); then
yq --inplace e '.code_project.api_url = env(cpai_url)' "${CONFIG_PATH}"
fi


# start the app
cd /usr/src/app
python ./index.py
