#!/bin/bash

# Define cleanup function to kill processes
cleanup() {
    echo "Cleaning up and killing processes..."
    kill $SPRING_PID $NG_PID 2>/dev/null
    # Print success message after both processes are done
    echo "Stage Build Ended Successfully"
    exit 1  # Exit with an error code
}

# Trap SIGINT (Ctrl+C) and SIGTERM (kill signal) to invoke cleanup
trap cleanup SIGINT SIGTERM

# Ensure processes are killed when the script exits
trap "kill $SPRING_PID $NG_PID 2>/dev/null" EXIT

# Start Spring Boot in the background
cd ~/Desktop/colelamersdotcom/backend || { echo "Failed to change to backend directory"; exit 1; }
echo "Starting Spring Boot..."
mvn spring-boot:run &
SPRING_PID=$!
if [ $? -ne 0 ]; then
  echo "Failed to start Spring Boot"
  exit 1
fi

# Start Angular in the background
cd ~/Desktop/colelamersdotcom/frontend || { echo "Failed to change to frontend directory"; exit 1; }
echo "Starting Angular..."
ng serve --port 4000 &
NG_PID=$!
if [ $? -ne 0 ]; then
  echo "Failed to start Angular"
  exit 1
fi

echo "Spring Boot PID: $SPRING_PID"
echo "Angular PID: $NG_PID"

# Wait for both processes to finish
wait $SPRING_PID $NG_PID
