#!/bin/bash
set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <RDS_ENDPOINT> <DB_USER> <DB_PASSWORD> <DB_NAME>"
  exit 1
fi

RDS_ENDPOINT="$1"
DB_USER="$2"
DB_PASSWORD="$3"
DB_NAME="$4"

mysql --host="$RDS_ENDPOINT" --port=3306 --user="$DB_USER" --password="$DB_PASSWORD" \
  -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"

echo "Database '$DB_NAME' is ready on $RDS_ENDPOINT"
