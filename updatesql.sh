#!/bin/bash

# Define the directory containing the files
INPUT_DIR="$HOME/Desktop/colelamersdotcom/posts"

# Initialize an empty variable to store SQL commands
COMMANDS=""

# Iterate over all files in the directory
for file in "$INPUT_DIR"/*; do
    # Get the filename (without the path)
    fileName=$(basename "$file")
    fileNameWithoutExtension="${fileName%.*}"

    # Read the contents of the file
    fileContents=$(<"$file")

    # Step 1: Escape single quotes ' by replacing them with two single quotes ''
    sanitizedFileContents=$(echo "$fileContents" | sed "s/'/''/g")

    # Step 3: Append the SQL command
    COMMANDS+="UPDATE blogs SET html = '$sanitizedFileContents' WHERE title = '$fileNameWithoutExtension'; "
done


# You can also uncomment the next line and run that, then copy paste that in
# instead. Then you don't have to actually set up the shell script.

# Wrap the SQL commands in a transaction block
SQL_COMMANDS="BEGIN; $COMMANDS COMMIT;"

# Execute the SQL commands
echo "$SQL_COMMANDS" | psql -U colelamersdotcom -h 127.0.0.1 -d colelamersdotcom || {
    echo "PostgreSQL transaction failed."
    exit 1
}

echo "Transaction completed successfully."
