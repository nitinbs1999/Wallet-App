-- Database initialization script for Wallet Application
-- This script runs automatically when PostgreSQL container starts for the first time

-- Ensure database exists
SELECT 'CREATE DATABASE test_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'test_db')\gexec

-- Connect to the database
\c test_db

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE test_db TO postgres;

-- Log initialization
DO $$
BEGIN
    RAISE NOTICE 'Database initialized successfully';
END $$;
