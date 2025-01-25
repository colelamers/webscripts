#!/bin/bash

TEMP_DIR="/tmp"
FRONTEND_DIR="/var/www/html"
BACKEND_DIR="/var/opt/api"

FRONTEND_TAR="$TEMP_DIR/frontend.tar.gz"
BACKEND_TAR="$TEMP_DIR/backend.tar.gz"

NGINX_SERVICE="nginx"
POSTGRES_SERVICE="postgresql"
SERVICE_NAME="colelamersdotcom"  # Use this as the service name

# Step 1: Move and extract the frontend.tar.gz to /var/www/html
echo "Ensuring $FRONTEND_DIR exists..."
sudo mkdir -p "$FRONTEND_DIR"  # This will create the directory if it doesn't exist
echo "Cleaning up existing files in $FRONTEND_DIR..."
sudo rm -rf "$FRONTEND_DIR"/*  # Clean up files in the frontend directory

echo "Moving frontend.tar.gz to $FRONTEND_DIR..."
sudo cp "$FRONTEND_TAR" "$FRONTEND_DIR" || { echo "Failed to copy frontend tarball."; exit 1; }
cd "$FRONTEND_DIR" || exit

echo "Extracting frontend.tar.gz..."
sudo tar -xzf frontend.tar.gz || { echo "Failed to extract frontend tarball."; exit 1; }

echo "Deleting frontend tarball..."
sudo rm -f "$FRONTEND_DIR/frontend.tar.gz"  # Clean up the tarball

# Step 2: Move and extract the backend.tar.gz to /var/opt/api
echo "Ensuring $BACKEND_DIR exists..."
sudo mkdir -p "$BACKEND_DIR"  # This will create the directory if it doesn't exist

echo "Moving backend.tar.gz to $BACKEND_DIR..."
sudo cp "$BACKEND_TAR" "$BACKEND_DIR" || { echo "Failed to copy backend tarball."; exit 1; }
cd "$BACKEND_DIR" || exit

echo "Extracting backend.tar.gz..."
sudo tar -xzf backend.tar.gz || { echo "Failed to extract backend tarball."; exit 1; }

echo "Deleting backend tarball..."
sudo rm -f "$BACKEND_DIR/backend.tar.gz"  # Clean up the tarball

# Step 3: Reset and start the backend systemd services
echo "Resetting and restarting the Spring Boot systemd service..."
sudo systemctl daemon-reload
sudo systemctl stop "$SERVICE_NAME".service || { echo "Failed to stop $SERVICE_NAME service."; exit 1; }
sudo systemctl start "$SERVICE_NAME".service || { echo "Failed to start $SERVICE_NAME service."; exit 1; }

# Ensure the systemd service is enabled to start on boot
sudo systemctl enable "$SERVICE_NAME".service || { echo "Failed to enable $SERVICE_NAME service."; exit 1; }

# Step 4: Restart NGINX and PostgreSQL services
echo "Restarting NGINX service..."
sudo systemctl restart "$NGINX_SERVICE" || { echo "Failed to restart NGINX."; exit 1; }

echo "Restarting PostgreSQL service..."
sudo systemctl restart "$POSTGRES_SERVICE" || { echo "Failed to restart PostgreSQL."; exit 1; }

# Step 5: Clean up all archives in /tmp after successful operations
echo "Cleaning up archive files in $TEMP_DIR..."
sudo rm -f "$TEMP_DIR/frontend.tar.gz"
sudo rm -f "$TEMP_DIR/backend.tar.gz"

# Final status message
echo "Process completed successfully!"
