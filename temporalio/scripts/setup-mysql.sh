#!/bin/sh

#ddev-generated

# @@@SNIPSTART compose-mysql-setup
set -eu

# Validate required environment variables
: "${MYSQL_SEEDS:?ERROR: MYSQL_SEEDS environment variable is required}"
: "${MYSQL_USER:?ERROR: MYSQL_USER environment variable is required}"

echo 'Starting MySQL schema setup...'
echo 'Waiting for MySQL port to be available...'
nc -z -w 10 ${MYSQL_SEEDS} ${DB_PORT:-3306}
echo 'MySQL port is available'

mariadb -h ${MYSQL_SEEDS} --skip-ssl -u root -proot -e "
  CREATE DATABASE IF NOT EXISTS ${MYSQL_DB:-temporal};
  CREATE DATABASE IF NOT EXISTS ${MYSQL_VISIBILITY_DB:-temporal_visibility};
  GRANT ALL ON \`${MYSQL_DB:-temporal}\`.* TO '${MYSQL_USER}'@'%';
  GRANT ALL ON \`${MYSQL_VISIBILITY_DB:-temporal_visibility}\`.* TO '${MYSQL_USER}'@'%';
  FLUSH PRIVILEGES;
"

# Create and setup temporal database
temporal-sql-tool --plugin mysql8 --ep ${MYSQL_SEEDS} -u ${MYSQL_USER} -p ${DB_PORT:-3306} --pw ${MYSQL_PWD} --db temporal create
temporal-sql-tool --plugin mysql8 --ep ${MYSQL_SEEDS} -u ${MYSQL_USER} -p ${DB_PORT:-3306} --pw ${MYSQL_PWD} --db temporal setup-schema -v 0.0
temporal-sql-tool --plugin mysql8 --ep ${MYSQL_SEEDS} -u ${MYSQL_USER} -p ${DB_PORT:-3306} --pw ${MYSQL_PWD} --db temporal update-schema -d /etc/temporal/schema/mysql/v8/temporal/versioned

# Create and setup visibility database
temporal-sql-tool --plugin mysql8 --ep ${MYSQL_SEEDS} -u ${MYSQL_USER} -p ${DB_PORT:-3306} --pw ${MYSQL_PWD} --db temporal_visibility create
temporal-sql-tool --plugin mysql8 --ep ${MYSQL_SEEDS} -u ${MYSQL_USER} -p ${DB_PORT:-3306} --pw ${MYSQL_PWD} --db temporal_visibility setup-schema -v 0.0
temporal-sql-tool --plugin mysql8 --ep ${MYSQL_SEEDS} -u ${MYSQL_USER} -p ${DB_PORT:-3306} --pw ${MYSQL_PWD} --db temporal_visibility update-schema -d /etc/temporal/schema/mysql/v8/visibility/versioned

echo 'MySQL schema setup complete'
# @@@SNIPEND
