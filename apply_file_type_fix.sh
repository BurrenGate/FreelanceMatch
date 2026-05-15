#!/bin/bash

# Quick fix script for file_type length issue
# This script applies the V48 migration to fix chat file_type column

echo "🔧 Applying fix for chat file_type column length..."
echo ""

# Check if PostgreSQL is running
if ! docker ps | grep -q postgres; then
    echo "❌ PostgreSQL container is not running!"
    echo "   Start it with: docker-compose up -d db"
    exit 1
fi

echo "✅ PostgreSQL is running"
echo ""

# Option 1: Restart application (Flyway will apply migration automatically)
echo "📦 Option 1: Restart application (recommended)"
echo "   docker-compose restart app"
echo ""

# Option 2: Apply migration manually
echo "📝 Option 2: Apply migration manually"
echo "   docker exec -i freelancematch-db-1 psql -U user -d freelance < src/main/resources/db/migration/V48__fix_chat_file_type_length.sql"
echo ""

# Ask user which option to use
read -p "Choose option (1 or 2): " option

if [ "$option" = "1" ]; then
    echo ""
    echo "🔄 Restarting application..."
    docker-compose restart app
    echo ""
    echo "✅ Application restarted. Flyway will apply V48 migration automatically."
    echo "   Check logs: docker-compose logs -f app"
elif [ "$option" = "2" ]; then
    echo ""
    echo "🔄 Applying migration manually..."
    docker exec -i $(docker ps -qf "name=db") psql -U user -d freelance < src/main/resources/db/migration/V48__fix_chat_file_type_length.sql
    echo ""
    echo "✅ Migration applied successfully!"
else
    echo "❌ Invalid option. Exiting."
    exit 1
fi

echo ""
echo "🧪 Testing the fix..."
echo "   Run: psql -U user -d freelance -f test_v48_file_type_fix.sql"
echo ""
echo "✅ Fix completed! You can now send files with long MIME types."
echo ""
echo "📚 For more details, see: FIX_FILE_TYPE_LENGTH.md"
