#!/bin/bash

# Script to fix Flyway migration V29 issue

echo "Connecting to database to drop existing functions..."

# Drop the functions manually before running migrations
psql -h localhost -U user -d freelance << EOF
-- Drop existing functions that have changed return types
DROP FUNCTION IF EXISTS job_market.get_freelancer_reviews(BIGINT, INTEGER);
DROP FUNCTION IF EXISTS job_market.get_freelancer_profile(BIGINT);

-- Delete V29 from flyway history if it exists
DELETE FROM flyway_schema_history WHERE version = '29';

\q
EOF

echo "Functions dropped. Now restart the application."
echo "Run: mvn spring-boot:run"
