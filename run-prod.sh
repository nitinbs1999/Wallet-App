#!/bin/bash
# Run Spring Boot application with PostgreSQL (requires PostgreSQL to be running)

echo "Starting Wallet App with PostgreSQL..."
echo "Make sure PostgreSQL is running on localhost:5432"
./gradlew bootRun
