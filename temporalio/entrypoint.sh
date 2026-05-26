#!/bin/sh
## #ddev-generated
set -e

echo "[init] Running MySQL schema setup..."
max_attempts=20
attempt=0
until /scripts/setup-mysql.sh; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge "$max_attempts" ]; then
    echo "[init] ERROR: setup-mysql.sh failed after $max_attempts attempts. Aborting."
    exit 1
  fi
  echo "[init] setup-mysql.sh failed (attempt $attempt/$max_attempts), retrying in 5s..."
  sleep 5
done
echo "[init] MySQL schema setup complete."

echo "[init] Starting Temporal server in background..."
/etc/temporal/entrypoint.sh &
TEMPORAL_PID=$!

echo "[init] Waiting for Temporal server to be ready on :7233..."
max_attempts=60
attempt=0
until nc -z localhost 7233 2>/dev/null; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge "$max_attempts" ]; then
    echo "[init] ERROR: Temporal server did not start in time. Aborting."
    kill "$TEMPORAL_PID" 2>/dev/null || true
    exit 1
  fi
  sleep 2
done
echo "[init] Temporal server is up."

echo "[init] Creating namespace..."
/scripts/create-namespace.sh || echo "[init] Namespace already exists or creation failed — continuing."

echo "[init] Init complete. Handing off to Temporal server (PID $TEMPORAL_PID)."
wait "$TEMPORAL_PID"
