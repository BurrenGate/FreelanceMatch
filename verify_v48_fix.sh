#!/bin/bash

# Comprehensive verification script for V48 file_type fix
# This script checks all aspects of the fix

set -e

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║              🔍 V48 File Type Fix - Comprehensive Verification              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
    ((WARNINGS++))
}

info() {
    echo -e "${BLUE}ℹ️  INFO${NC}: $1"
}

# Check 1: Files exist
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Checking if all required files exist..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FILES=(
    "src/main/resources/db/migration/V48__fix_chat_file_type_length.sql"
    "FIX_FILE_TYPE_LENGTH.md"
    "QUICK_FIX_GUIDE.md"
    "CHANGES_V48_SUMMARY.md"
    "MIME_TYPES_REFERENCE.sql"
    "FIX_REFERENCE_CARD.txt"
    "apply_file_type_fix.sh"
    "test_v48_file_type_fix.sql"
    "check_file_type_status.sql"
    "GIT_COMMIT_MESSAGE.txt"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "File exists: $file"
    else
        fail "File missing: $file"
    fi
done
echo ""

# Check 2: Migration file syntax
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Checking migration file syntax..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

MIGRATION_FILE="src/main/resources/db/migration/V48__fix_chat_file_type_length.sql"

if grep -q "ALTER TABLE chat_messages" "$MIGRATION_FILE"; then
    pass "Contains ALTER TABLE statement"
else
    fail "Missing ALTER TABLE statement"
fi

if grep -q "VARCHAR(255)" "$MIGRATION_FILE"; then
    pass "Contains VARCHAR(255) definition"
else
    fail "Missing VARCHAR(255) definition"
fi

if grep -q "chat_management.send_message" "$MIGRATION_FILE"; then
    pass "Contains send_message function"
else
    fail "Missing send_message function"
fi

if grep -q "chat_management.get_conversation_messages" "$MIGRATION_FILE"; then
    pass "Contains get_conversation_messages function"
else
    fail "Missing get_conversation_messages function"
fi
echo ""

# Check 3: Docker containers
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Checking Docker containers..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if docker ps | grep -q postgres; then
    pass "PostgreSQL container is running"
    DB_RUNNING=true
else
    warn "PostgreSQL container is not running"
    info "Start with: docker-compose up -d db"
    DB_RUNNING=false
fi

if docker ps | grep -q minio; then
    pass "MinIO container is running"
else
    warn "MinIO container is not running"
    info "Start with: docker-compose up -d minio"
fi

if docker ps | grep -q app; then
    pass "Application container is running"
else
    warn "Application container is not running"
    info "Start with: docker-compose up -d app"
fi
echo ""

# Check 4: Database connection (only if DB is running)
if [ "$DB_RUNNING" = true ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "4. Checking database connection..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    DB_CONTAINER=$(docker ps -qf "name=db")
    
    if docker exec "$DB_CONTAINER" psql -U user -d freelance -c "SELECT 1" > /dev/null 2>&1; then
        pass "Database connection successful"
        
        # Check if V48 migration is applied
        V48_APPLIED=$(docker exec "$DB_CONTAINER" psql -U user -d freelance -t -c "SELECT EXISTS(SELECT 1 FROM flyway_schema_history WHERE version = '48' AND success = true)" 2>/dev/null | tr -d ' ')
        
        if [ "$V48_APPLIED" = "t" ]; then
            pass "V48 migration is applied"
        else
            warn "V48 migration is NOT applied yet"
            info "Apply with: docker-compose restart app"
        fi
        
        # Check column length
        COLUMN_LENGTH=$(docker exec "$DB_CONTAINER" psql -U user -d freelance -t -c "SELECT character_maximum_length FROM information_schema.columns WHERE table_name = 'chat_messages' AND column_name = 'file_type'" 2>/dev/null | tr -d ' ')
        
        if [ "$COLUMN_LENGTH" = "255" ]; then
            pass "file_type column is VARCHAR(255)"
        elif [ "$COLUMN_LENGTH" = "50" ]; then
            fail "file_type column is still VARCHAR(50) - migration not applied"
        else
            warn "file_type column length is unexpected: $COLUMN_LENGTH"
        fi
    else
        fail "Cannot connect to database"
    fi
    echo ""
fi

# Check 5: Documentation completeness
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. Checking documentation completeness..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if grep -q "FIX_FILE_TYPE_LENGTH.md" README.md; then
    pass "README.md updated with fix documentation link"
else
    fail "README.md not updated"
fi

if [ -s "FIX_FILE_TYPE_LENGTH.md" ]; then
    pass "FIX_FILE_TYPE_LENGTH.md is not empty"
else
    fail "FIX_FILE_TYPE_LENGTH.md is empty"
fi

if [ -s "QUICK_FIX_GUIDE.md" ]; then
    pass "QUICK_FIX_GUIDE.md is not empty"
else
    fail "QUICK_FIX_GUIDE.md is empty"
fi
echo ""

# Check 6: Script permissions
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. Checking script permissions..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -x "apply_file_type_fix.sh" ]; then
    pass "apply_file_type_fix.sh is executable"
else
    fail "apply_file_type_fix.sh is not executable"
    info "Fix with: chmod +x apply_file_type_fix.sh"
fi

if [ -x "verify_v48_fix.sh" ]; then
    pass "verify_v48_fix.sh is executable"
else
    warn "verify_v48_fix.sh is not executable (current script)"
fi
echo ""

# Summary
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                              📊 VERIFICATION SUMMARY                         ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✅ Passed:${NC}   $PASSED"
echo -e "${RED}❌ Failed:${NC}   $FAILED"
echo -e "${YELLOW}⚠️  Warnings:${NC} $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    ✅ ALL CHECKS PASSED - READY TO DEPLOY                    ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Apply fix: ./apply_file_type_fix.sh"
    echo "  2. Test: docker exec -i \$(docker ps -qf \"name=db\") psql -U user -d freelance < test_v48_file_type_fix.sql"
    echo "  3. Commit: git add . && git commit -F GIT_COMMIT_MESSAGE.txt"
    exit 0
else
    echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                    ❌ SOME CHECKS FAILED - REVIEW REQUIRED                   ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please fix the failed checks before deploying."
    exit 1
fi
