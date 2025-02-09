#!/bin/bash

# Define the base directory
BASE_DIR="$HOME/Desktop/colelamersdotcom"  # Expands ~ to the full path of the user's home directory

# Define directories, prepending BASE_DIR to each
FRONTEND_DIR="$BASE_DIR/frontend"
FRONTEND_BUILD="$FRONTEND_DIR/dist/cl/browser"
BACKEND_BUILD="$BASE_DIR/backend"
BACKEND_JAR="$BACKEND_BUILD/target/colelamersdotcom-1.0-SNAPSHOT.jar"
SCRIPTS_DIR="$BASE_DIR/scripts"  # Updated to use /scripts instead of /script
DEST_DIR="$BASE_DIR"  # The destination will be BASE_DIR

# Create a timestamp for unique filenames (format: YYYYMMDD)
TIMESTAMP=$(date +%Y%m%d)

# Ensure Postgres prod password set in applications.properties
echo "Ensuring Prod Postgres Password set..."
./jarproddeploypassword.sh || { echo "Failed to set PostgreSQL password."; exit 1; }

# Maven Build backend then tar
echo "Maven JAR file build: $BACKEND_JAR..."
cd $BACKEND_BUILD
mvn clean install -U
echo "Tarring backend JAR file..."
# Navigate to the backend directory and tar only the JAR file (no full paths)
(cd "$BASE_DIR/backend/target" && tar -czf "$DEST_DIR/backend.tar.gz" "$(basename "$BACKEND_JAR")")

# Check and tar the contents of /frontend/dist/cl/browser
echo "Building Angular..."
(cd "$FRONTEND_DIR" && ng build)
echo "Tarring frontend browser files..."
# Navigate to the frontend directory and tar only the files and directories inside it
(cd "$FRONTEND_BUILD" && tar -czf "$DEST_DIR/frontend.tar.gz" *)

# Tar all three generated tar files into one final archive
echo "Tarring all generated files into a final archive..."
tar -czf "$DEST_DIR/final_archive_$TIMESTAMP.tar.gz" -C "$DEST_DIR" frontend.tar.gz backend.tar.gz scripts/proddeploy.sh

# Delete the individual tar files after the final archive is created
echo "Deleting individual tar files..."
rm -f "$DEST_DIR/frontend.tar.gz"
rm -f "$DEST_DIR/backend.tar.gz"

# Final success message
echo "All files have been tarred and stored in $DEST_DIR"
echo "The final archive is located at: $DEST_DIR/final_archive_$TIMESTAMP.tar.gz"
