#!/usr/bin/env bash
set -euo pipefail

echo "### RUN.SH SMART ENERGY FINANCE START ###"

if [ -f /usr/lib/bashio/bashio.sh ]; then
  # shellcheck disable=SC1091
  source /usr/lib/bashio/bashio.sh
  logi(){ bashio::log.info "$1"; }
  logw(){ bashio::log.warning "$1"; }
  loge(){ bashio::log.error "$1"; }
else
  logi(){ echo "[INFO] $1"; }
  logw(){ echo "[WARN] $1"; }
  loge(){ echo "[ERROR] $1"; }
fi

logi "Smart Energy Finance: init..."

OPTS="/data/options.json"
TMP="/data/flows.tmp.json"
ADDON_DATA_DIR="/data/smart-energy-finance"
DASHBOARDS_DIR="/config/dashboards"

# Runtime npm deps
RUNTIME_NODE_DIR="$ADDON_DATA_DIR/node_runtime"
RUNTIME_NODE_MODULES="$RUNTIME_NODE_DIR/node_modules"
RUNTIME_PKG="$RUNTIME_NODE_DIR/package.json"

if [ ! -f "$OPTS" ]; then
  loge "options.json introuvable dans /data. Stop."
  exit 1
fi

trim() {
  local s="${1:-}"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

timezone_exists() {
  local tz="$1"
  [ -n "$tz" ] && [ -f "/usr/share/zoneinfo/$tz" ]
}

normalize_timezone() {
  local raw tz upper offset sign hours

  raw="$(trim "${1:-}")"
  [ -z "$raw" ] && { echo "UTC"; return; }

  tz="$raw"
  upper="$(printf '%s' "$tz" | tr '[:lower:]' '[:upper:]')"

  case "$upper" in
    UTC|ETC/UTC|GMT) echo "UTC"; return ;;
    EUROPE/FRANCE|FRANCE) echo "Europe/Paris"; return ;;
    BELGIUM) echo "Europe/Brussels"; return ;;
    GERMANY) echo "Europe/Berlin"; return ;;
    SPAIN) echo "Europe/Madrid"; return ;;
    ITALY) echo "Europe/Rome"; return ;;
    UK|ENGLAND|BRITAIN|GREAT\ BRITAIN) echo "Europe/London"; return ;;
    SOUTH\ AFRICA|AFRICA/SOUTH\ AFRICA|JOHANNESBURG) echo "Africa/Johannesburg"; return ;;
    MOROCCO) echo "Africa/Casablanca"; return ;;
    NEW\ YORK|US/EASTERN|EST) echo "America/New_York"; return ;;
    CHICAGO|US/CENTRAL|CST) echo "America/Chicago"; return ;;
    LOS\ ANGELES|US/PACIFIC|PST) echo "America/Los_Angeles"; return ;;
    MONTREAL) echo "America/Montreal"; return ;;
    DUBAI|UAE) echo "Asia/Dubai"; return ;;
    TOKYO|JAPAN) echo "Asia/Tokyo"; return ;;
    SYDNEY) echo "Australia/Sydney"; return ;;
  esac

  if printf '%s' "$upper" | grep -Eq '^(UTC|GMT)[[:space:]]*[+-][0-9]{1,2}(:00)?$'; then
    offset="$(printf '%s' "$upper" | sed -E 's/^(UTC|GMT)[[:space:]]*([+-][0-9]{1,2})(:00)?$/\2/')"
    sign="${offset:0:1}"
    hours="${offset:1}"
    hours="$(printf '%d' "$hours" 2>/dev/null || echo "")"
    if [ -n "$hours" ] && [ "$hours" -ge 0 ] && [ "$hours" -le 14 ]; then
      if [ "$sign" = "+" ]; then
        echo "Etc/GMT-$hours"
      else
        echo "Etc/GMT+$hours"
      fi
      return
    fi
  fi

  if printf '%s' "$upper" | grep -Eq '^[+-][0-9]{1,2}$'; then
    sign="${upper:0:1}"
    hours="${upper:1}"
    hours="$(printf '%d' "$hours" 2>/dev/null || echo "")"
    if [ -n "$hours" ] && [ "$hours" -ge 0 ] && [ "$hours" -le 14 ]; then
      if [ "$sign" = "+" ]; then
        echo "Etc/GMT-$hours"
      else
        echo "Etc/GMT+$hours"
      fi
      return
    fi
  fi

  echo "$tz"
}

validate_timezone_or_fallback() {
  local tz="$1"
  if timezone_exists "$tz"; then
    echo "$tz"
  else
    echo "UTC"
  fi
}

ensure_runtime_ws() {
  mkdir -p "$RUNTIME_NODE_DIR"

  if [ ! -f "$RUNTIME_PKG" ]; then
    cat > "$RUNTIME_PKG" <<'EOF'
{
  "name": "smart-energy-finance-runtime",
  "private": true,
  "version": "1.0.0"
}
EOF
  fi

  export NODE_PATH="$RUNTIME_NODE_MODULES${NODE_PATH:+:$NODE_PATH}"

  if node -e "require('ws');" >/dev/null 2>&1; then
    logi "Runtime dependency 'ws' already available"
    return
  fi

  if ! command -v npm >/dev/null 2>&1; then
    loge "npm introuvable dans le conteneur, impossible d'installer 'ws'"
    exit 1
  fi

  logi "Installing runtime dependency: ws"
  (
    cd "$RUNTIME_NODE_DIR"
    npm install --no-save --omit=dev --no-audit --no-fund ws@8.18.0
  )

  if node -e "require('ws');" >/dev/null 2>&1; then
    logi "Runtime dependency 'ws' installed successfully"
  else
    loge "Installation de 'ws' échouée"
    exit 1
  fi
}

# Read every option in a single jq pass, emit shell-safe VAR='value' lines, eval them.
#   V(json_key; env_name; default)  -> string-or-default
#   B(json_key; env_name)           -> "true" or "false"
eval "$(jq -r '
  def V(k; e; d): "\(e)=" + ((.[k] // d) | tostring | @sh);
  def B(k; e):    "\(e)=" + (((.[k] // false) | if . == true then "true" else "false" end) | @sh);

  V("currency";                         "CURRENCY";                         "EUR"),
  V("contract_type";                    "CONTRACT_TYPE";                    "fixed"),
  V("dashboard_language";               "DASHBOARD_LANGUAGE";               "en"),
  B("dashboard_custom_cards_installed"; "DASHBOARD_CUSTOM_CARDS_INSTALLED"),
  B("send_bip";                         "SEND_BIP"),

  V("monthly_subscription_price";       "MONTHLY_SUBSCRIPTION_PRICE";       0),
  V("fixed_import_price";               "FIXED_IMPORT_PRICE";               0),
  V("fixed_export_price";               "FIXED_EXPORT_PRICE";               0),

  V("tariff_1_name";  "TARIFF_1_NAME";  ""), V("tariff_1_price"; "TARIFF_1_PRICE"; 0), V("tariff_1_start"; "TARIFF_1_START"; ""), V("tariff_1_end"; "TARIFF_1_END"; ""),
  V("tariff_2_name";  "TARIFF_2_NAME";  ""), V("tariff_2_price"; "TARIFF_2_PRICE"; 0), V("tariff_2_start"; "TARIFF_2_START"; ""), V("tariff_2_end"; "TARIFF_2_END"; ""),
  V("tariff_3_name";  "TARIFF_3_NAME";  ""), V("tariff_3_price"; "TARIFF_3_PRICE"; 0), V("tariff_3_start"; "TARIFF_3_START"; ""), V("tariff_3_end"; "TARIFF_3_END"; ""),
  V("tariff_4_name";  "TARIFF_4_NAME";  ""), V("tariff_4_price"; "TARIFF_4_PRICE"; 0), V("tariff_4_start"; "TARIFF_4_START"; ""), V("tariff_4_end"; "TARIFF_4_END"; ""),

  V("tempo_color_entity";    "TEMPO_COLOR_ENTITY";    ""),
  V("tempo_blue_hc_price";   "TEMPO_BLUE_HC_PRICE";   0),
  V("tempo_blue_hp_price";   "TEMPO_BLUE_HP_PRICE";   0),
  V("tempo_white_hc_price";  "TEMPO_WHITE_HC_PRICE";  0),
  V("tempo_white_hp_price";  "TEMPO_WHITE_HP_PRICE";  0),
  V("tempo_red_hc_price";    "TEMPO_RED_HC_PRICE";    0),
  V("tempo_red_hp_price";    "TEMPO_RED_HP_PRICE";    0),
  V("tempo_hc_slot_1_start"; "TEMPO_HC_SLOT_1_START"; "22:00"),
  V("tempo_hc_slot_1_end";   "TEMPO_HC_SLOT_1_END";   "06:00"),
  V("tempo_hc_slot_2_start"; "TEMPO_HC_SLOT_2_START"; ""),
  V("tempo_hc_slot_2_end";   "TEMPO_HC_SLOT_2_END";   ""),

  B("solar_enabled";      "SOLAR_ENABLED"),
  V("solar_input_mode";   "SOLAR_INPUT_MODE";    "energy"),
  V("solar_energy_entity";"SOLAR_ENERGY_ENTITY"; ""),
  V("solar_power_entity"; "SOLAR_POWER_ENTITY";  ""),

  B("load_enabled";       "LOAD_ENABLED"),
  V("load_input_mode";    "LOAD_INPUT_MODE";     "energy"),
  V("load_energy_entity"; "LOAD_ENERGY_ENTITY";  ""),
  V("load_power_entity";  "LOAD_POWER_ENTITY";   ""),

  B("battery_enabled";                  "BATTERY_ENABLED"),
  V("battery_input_mode";               "BATTERY_INPUT_MODE";               "energy"),
  V("battery_charge_energy_entity";     "BATTERY_CHARGE_ENERGY_ENTITY";     ""),
  V("battery_discharge_energy_entity";  "BATTERY_DISCHARGE_ENERGY_ENTITY";  ""),
  V("battery_charge_power_entity";      "BATTERY_CHARGE_POWER_ENTITY";      ""),
  V("battery_discharge_power_entity";   "BATTERY_DISCHARGE_POWER_ENTITY";   ""),
  V("battery_capacity_ah";              "BATTERY_CAPACITY_AH";              0),
  V("battery_total_capacity_kwh";       "BATTERY_TOTAL_CAPACITY_KWH";       0),

  B("grid_enabled";              "GRID_ENABLED"),
  V("grid_input_mode";           "GRID_INPUT_MODE";            "energy"),
  V("grid_import_energy_entity"; "GRID_IMPORT_ENERGY_ENTITY";  ""),
  V("grid_export_energy_entity"; "GRID_EXPORT_ENERGY_ENTITY";  ""),
  V("grid_import_power_entity";  "GRID_IMPORT_POWER_ENTITY";   ""),
  V("grid_export_power_entity";  "GRID_EXPORT_POWER_ENTITY";   ""),

  V("mqtt_host"; "MQTT_HOST"; ""),
  V("mqtt_port"; "MQTT_PORT"; 1883),
  V("mqtt_user"; "MQTT_USER"; ""),
  V("mqtt_pass"; "MQTT_PASS"; ""),

  V("timezone_mode";   "TZ_MODE_RAW";   "UTC"),
  V("timezone_custom"; "TZ_CUSTOM_RAW"; "")
' "$OPTS")"

if [ -z "$MQTT_HOST" ]; then
  loge "mqtt_host vide."
  exit 1
fi

if [ -z "$MQTT_USER" ] || [ -z "$MQTT_PASS" ]; then
  loge "mqtt_user ou mqtt_pass vide."
  exit 1
fi

# TIMEZONE

if [ "$TZ_MODE_RAW" = "CUSTOM" ]; then
  TZ_REQUESTED="$TZ_CUSTOM_RAW"
else
  TZ_REQUESTED="$TZ_MODE_RAW"
fi

TZ_REQUESTED="$(trim "$TZ_REQUESTED")"
TZ_NORMALIZED="$(normalize_timezone "$TZ_REQUESTED")"
ADDON_TIMEZONE="$(validate_timezone_or_fallback "$TZ_NORMALIZED")"

TIMEZONE_VALID="true"
if [ "$ADDON_TIMEZONE" != "$TZ_NORMALIZED" ]; then
  TIMEZONE_VALID="false"
fi

export TZ="$ADDON_TIMEZONE"
export ADDON_TIMEZONE
export ADDON_TIMEZONE_REQUESTED="$TZ_REQUESTED"
export ADDON_TIMEZONE_NORMALIZED="$TZ_NORMALIZED"
export ADDON_TIMEZONE_VALID="$TIMEZONE_VALID"

# EXPORT ALL
export CURRENCY CONTRACT_TYPE MONTHLY_SUBSCRIPTION_PRICE FIXED_IMPORT_PRICE FIXED_EXPORT_PRICE
export TARIFF_1_NAME TARIFF_1_PRICE TARIFF_1_START TARIFF_1_END
export TARIFF_2_NAME TARIFF_2_PRICE TARIFF_2_START TARIFF_2_END
export TARIFF_3_NAME TARIFF_3_PRICE TARIFF_3_START TARIFF_3_END
export TARIFF_4_NAME TARIFF_4_PRICE TARIFF_4_START TARIFF_4_END
export TEMPO_COLOR_ENTITY TEMPO_BLUE_HC_PRICE TEMPO_BLUE_HP_PRICE TEMPO_WHITE_HC_PRICE TEMPO_WHITE_HP_PRICE TEMPO_RED_HC_PRICE TEMPO_RED_HP_PRICE
export TEMPO_HC_SLOT_1_START TEMPO_HC_SLOT_1_END TEMPO_HC_SLOT_2_START TEMPO_HC_SLOT_2_END
export SOLAR_ENABLED SOLAR_INPUT_MODE SOLAR_ENERGY_ENTITY SOLAR_POWER_ENTITY
export LOAD_ENABLED LOAD_INPUT_MODE LOAD_ENERGY_ENTITY LOAD_POWER_ENTITY
export BATTERY_ENABLED BATTERY_INPUT_MODE BATTERY_CHARGE_ENERGY_ENTITY BATTERY_DISCHARGE_ENERGY_ENTITY BATTERY_CHARGE_POWER_ENTITY BATTERY_DISCHARGE_POWER_ENTITY BATTERY_CAPACITY_AH BATTERY_TOTAL_CAPACITY_KWH
export GRID_ENABLED GRID_INPUT_MODE GRID_IMPORT_ENERGY_ENTITY GRID_EXPORT_ENERGY_ENTITY GRID_IMPORT_POWER_ENTITY GRID_EXPORT_POWER_ENTITY
export MQTT_HOST MQTT_PORT MQTT_USER MQTT_PASS
export NODE_PATH SEND_BIP

# BASIC VALIDATION
if [ "$SOLAR_ENABLED" = "true" ] && [ "$SOLAR_INPUT_MODE" = "energy" ] && [ -z "$SOLAR_ENERGY_ENTITY" ]; then
  loge "solar_energy_entity vide."
  exit 1
fi

if [ "$LOAD_ENABLED" = "true" ] && [ "$LOAD_INPUT_MODE" = "energy" ] && [ -z "$LOAD_ENERGY_ENTITY" ]; then
  loge "load_energy_entity vide."
  exit 1
fi

if [ "$GRID_ENABLED" = "true" ] && [ "$GRID_INPUT_MODE" = "energy" ] && [ -z "$GRID_IMPORT_ENERGY_ENTITY" ]; then
  loge "grid_import_energy_entity vide."
  exit 1
fi

if [ "$CONTRACT_TYPE" = "time_based" ]; then
  if [ -z "$TARIFF_1_NAME" ] || [ -z "$TARIFF_1_START" ] || [ -z "$TARIFF_1_END" ]; then
    loge "tariff_1 incomplet."
    exit 1
  fi
fi

if [ "$CONTRACT_TYPE" = "tempo" ] && [ -z "$TEMPO_COLOR_ENTITY" ]; then
  loge "tempo_color_entity vide."
  exit 1
fi

# STORAGE
mkdir -p "$DASHBOARDS_DIR"
mkdir -p "$ADDON_DATA_DIR"

# Install runtime deps before Node-RED starts
ensure_runtime_ws

# FLOWS
ADDON_FLOWS_VERSION="$(cat /addon/flows_version.txt 2>/dev/null || echo '0.0.0')"
INSTALLED_VERSION="$(cat /data/flows_version.txt 2>/dev/null || echo '')"

if [ ! -f /data/flows.json ] || [ "$INSTALLED_VERSION" != "$ADDON_FLOWS_VERSION" ]; then
  cp /addon/flows.json /data/flows.json
  echo "$ADDON_FLOWS_VERSION" > /data/flows_version.txt
fi

# MQTT PATCH
if ! jq -e '.[] | select(.type=="mqtt-broker" and .name=="HA MQTT Broker")' /data/flows.json >/dev/null 2>&1; then
  loge 'Aucun mqtt-broker nommé "HA MQTT Broker" trouvé dans flows.json'
  exit 1
fi

jq \
  --arg host "$MQTT_HOST" \
  --arg port "$MQTT_PORT" \
  --arg user "$MQTT_USER" \
  '
  map(
    if .type=="mqtt-broker" and .name=="HA MQTT Broker"
    then .broker=$host | .port=$port | .user=$user
    else .
    end
  )
  ' /data/flows.json > "$TMP" && mv "$TMP" /data/flows.json

rm -f /data/flows_cred.json || true

BROKER_ID="$(jq -r '.[] | select(.type=="mqtt-broker" and .name=="HA MQTT Broker") | .id' /data/flows.json)"
if [ -z "$BROKER_ID" ]; then
  loge "Impossible de récupérer l'ID du broker MQTT"
  exit 1
fi

jq -n \
  --arg id "$BROKER_ID" \
  --arg user "$MQTT_USER" \
  --arg pass "$MQTT_PASS" \
  '{($id): {"user": $user, "password": $pass}}' \
  > /data/flows_cred.json

logi "Starting Node-RED sur le port 1894..."
exec node-red --userDir /data --settings /addon/settings.js
