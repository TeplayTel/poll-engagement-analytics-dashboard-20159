#!/bin/bash

# Migration script for fanengage_analytics_database: creates all required tables and indexes.

set -e

DB_HOST="${POSTGRES_HOST:-localhost}"
DB_PORT="${POSTGRES_PORT:-5000}"
DB_NAME="${POSTGRES_DB:-myapp}"
DB_USER="${POSTGRES_USER:-appuser}"
DB_PASS="${POSTGRES_PASSWORD:-dbuser123}"

echo "Applying database schema migration..."
export PGPASSWORD="${DB_PASS}"
psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -f schema.sql

echo "Migration completed successfully."
