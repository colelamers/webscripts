#!/bin/bash

# Define the base directory
BASE_DIR="$HOME/Desktop/colelamersdotcom"  # Expands ~ to the full path of the user's home directory

# Define the application properties file path
APP_PROPERTIES_FILE="$BASE_DIR/backend/src/main/resources/application.properties"

# Step 1: Find the "Prod" or "Production" line (case insensitive)
PROD_LINE=$(grep -i -n "Prod" "$APP_PROPERTIES_FILE")
if [ -z "$PROD_LINE" ]; then
  echo "No 'Prod' or 'Production' line found."
  exit 1
fi

# Extract line number of "Prod" or "Production"
PROD_LINE_NUM=$(echo "$PROD_LINE" | cut -d: -f1)

# Step 2: Look for the next line with "spring.datasource.password="
PASSWORD_LINE=$(awk -v num=$PROD_LINE_NUM 'NR>num && /spring.datasource.password=/ {print NR ":" $0; exit}' "$APP_PROPERTIES_FILE")
if [ -z "$PASSWORD_LINE" ]; then
  echo "No 'spring.datasource.password=' line found after 'Prod' or 'Production'."
  exit 1
fi

# Extract the line number and content of spring.datasource.password=
PASSWORD_LINE_NUM=$(echo "$PASSWORD_LINE" | cut -d: -f1)
PASSWORD_LINE_CONTENT=$(echo "$PASSWORD_LINE" | cut -d: -f2-)

# Step 3: If the line starts with "#", remove the "#"
if [[ "$PASSWORD_LINE_CONTENT" == \#* ]]; then
  echo "Removing '#' from the 'spring.datasource.password=' line."
  sed -i "${PASSWORD_LINE_NUM}s/^#//" "$APP_PROPERTIES_FILE"
else
  echo "No '#' to remove from the 'spring.datasource.password=' line."
fi

# Step 4: Find the "Stage" or "Staging" line (case insensitive)
STAGE_LINE=$(grep -i -n "Stage" "$APP_PROPERTIES_FILE")
if [ -z "$STAGE_LINE" ]; then
  echo "No 'Stage' or 'Staging' line found."
  exit 1
fi

# Extract line number of "Stage" or "Staging"
STAGE_LINE_NUM=$(echo "$STAGE_LINE" | cut -d: -f1)

# Step 5: Look for the next line with "spring.datasource.password="
PASSWORD_STAGE_LINE=$(awk -v num=$STAGE_LINE_NUM 'NR>num && /spring.datasource.password=/ {print NR ":" $0; exit}' "$APP_PROPERTIES_FILE")
if [ -z "$PASSWORD_STAGE_LINE" ]; then
  echo "No 'spring.datasource.password=' line found after 'Stage' or 'Staging'."
  exit 1
fi

# Extract the line number and content of spring.datasource.password=
PASSWORD_STAGE_LINE_NUM=$(echo "$PASSWORD_STAGE_LINE" | cut -d: -f1)
PASSWORD_STAGE_LINE_CONTENT=$(echo "$PASSWORD_STAGE_LINE" | cut -d: -f2-)

# Step 6: Prepend a "#" to the "spring.datasource.password=" line for "Stage"
if [[ "$PASSWORD_STAGE_LINE_CONTENT" != \#* ]]; then
  echo "Prepending '#' to the 'spring.datasource.password=' line for 'Stage'."
  sed -i "${PASSWORD_STAGE_LINE_NUM}s/^/#/" "$APP_PROPERTIES_FILE"
else
  echo "Line already commented out for 'Stage'."
fi

echo "Process completed successfully!"
