#!/bin/bash

# Quick start script for FreelanceMatch with MinIO

echo "🚀 Starting FreelanceMatch with MinIO..."

# Stop existing containers
echo "📦 Stopping existing containers..."
docker-compose down

# Start all services
echo "🔄 Starting services (PostgreSQL, MinIO, App)..."
docker-compose up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

echo "✅ Services started!"
echo ""
echo "📊 Access points:"
echo "  - Application: http://localhost:8080"
echo "  - Swagger UI: http://localhost:8080/swagger-ui.html"
echo "  - MinIO Web UI: http://localhost:9001"
echo "    Login: minioadmin"
echo "    Password: minioadmin"
echo ""
echo "📝 Check logs:"
echo "  docker-compose logs -f app"
echo ""
echo "🧪 Test file upload:"
echo "  curl -X POST http://localhost:8080/api/files/upload/image \\"
echo "    -H \"Authorization: Bearer YOUR_JWT_TOKEN\" \\"
echo "    -F \"file=@/path/to/image.jpg\""
