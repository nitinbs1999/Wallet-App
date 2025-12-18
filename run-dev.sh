#!/bin/bash
# Run Spring Boot application with H2 in-memory database for development

echo "Starting Wallet App with H2 database..."
./gradlew bootRun --args='--spring.profiles.active=dev'
