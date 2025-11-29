#!/bin/sh

# Database Backup Script for MOBI Platform
# Runs daily automated backups of PostgreSQL database

set -e

# Configuration
BACKUP_DIR="/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=30

# Database credentials (from environment)
DB_HOST="${PGHOST:-postgres}"
DB_NAME="${PGDATABASE:-mobi_production}"
DB_USER="${PGUSER:-mobi_prod_user}"

# Backup filename
BACKUP_FILE="${BACKUP_DIR}/mobi_db_${TIMESTAMP}.sql.gz"

echo "[$(date)] Starting database backup..."

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Perform backup with pg_dump and compress
pg_dump -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" | gzip > "${BACKUP_FILE}"

if [ $? -eq 0 ]; then
    echo "[$(date)] Backup completed successfully: ${BACKUP_FILE}"

    # Get backup size
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
    echo "[$(date)] Backup size: ${BACKUP_SIZE}"

    # Verify backup file integrity
    gunzip -t "${BACKUP_FILE}"
    if [ $? -eq 0 ]; then
        echo "[$(date)] Backup file integrity verified"
    else
        echo "[$(date)] ERROR: Backup file integrity check failed!"
        exit 1
    fi
else
    echo "[$(date)] ERROR: Backup failed!"
    exit 1
fi

# Remove backups older than retention period
echo "[$(date)] Removing backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_DIR}" -name "mobi_db_*.sql.gz" -type f -mtime +${RETENTION_DAYS} -delete

# List current backups
echo "[$(date)] Current backups:"
ls -lh "${BACKUP_DIR}"

echo "[$(date)] Backup process completed"
