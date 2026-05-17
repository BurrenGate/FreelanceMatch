# PiedPiper Freelance Platform - Complete Documentation

## Project Overview
PiedPiper is a comprehensive freelance marketplace platform built with Java Spring Boot, providing a complete solution for connecting freelancers with clients, managing projects, payments, and communications.

## Technology Stack
- **Backend**: Java Spring Boot
- **Database**: PostgreSQL (with Flyway migrations)
- **Storage**: MinIO (S3-compatible object storage)
- **Build Tool**: Maven

## Project Structure

### Source Code (`src/main/java/sdu/database/piedpiper/`)

#### Controllers
- `AccountController` - User account management
- `AdminJobStatusController` - Admin job status operations
- `AdminReviewController` - Admin review management
- `AdminTransactionController` - Admin transaction monitoring
- `AuthController` - Authentication and authorization
- `ChatController` - Real-time messaging between users
- `ClientProfileController` - Client profile management
- `ContractController` - Contract management and lifecycle
- `DebugClientController` - Debugging utilities for clients
- `DebugController` - General debugging endpoints
- `FileController` - File upload/download management
- `FreelancerProfileController` - Freelancer profile management
- `JobController` - Job posting and management
- `JobRequiredSkillController` - Job skill requirements
- `JobStatusController` - Job status tracking
- `MilestoneController` - Project milestone management
- `NotificationController` - User notifications
- `ProfileController` - User profile operations
- `ProfileSkillController` - User skill management
- `ProposalController` - Proposal submission and tracking
- `ReviewController` - Review and rating system

#### Core Components
- **Config**: Configuration classes for CORS, MinIO, and Swagger/API documentation
- **DTO**: Data Transfer Objects for request/response handling
- **Exception**: Custom exception handling
- **Model**: JPA entities and database models
- **Repository**: Spring Data repositories for database operations
- **Security**: Authentication and authorization configuration
- **Service**: Business logic implementation

#### Entry Point
- `PiedPiperApplication` - Main Spring Boot application class

### Database Migrations (`resources/db/migration/`)
- `V1__public_tables.sql` - Initial public schema setup
- `V2__seed_data.sql` - Seed data for testing
- `V3__sync_sequences.sql` - Database sequence synchronization
- `V4__user_management.sql` - User and authentication tables
- `V5__account_management.sql` - Account-related tables
- `V6__profile_management.sql` - Profile tables
- `V7__job_management.sql` - Job posting tables
- `V8__job_market.sql` - Job marketplace tables
- `V9__contract_management.sql` - Contract tables
- `V10__payment_management.sql` - Payment processing tables
- `V11__chat_management.sql` - Chat/messaging tables
- `V12__skill_management.sql` - Skill system tables
- `V13__app_management.sql` - Application management tables
- `V14__admin_management.sql` - Admin functionality tables

### Configuration
- `application.properties` - Application configuration file
- `index.html` - Static frontend file

## Key Features

### 1. User Management
- User registration and authentication
- Profile management (Client and Freelancer profiles)
- User skill tracking and endorsements
- Role-based access control

### 2. Job Management
- Job posting and listing
- Job skill requirements
- Job status tracking
- Job marketplace functionality

### 3. Contract Management
- Contract creation and lifecycle management
- Contract status tracking
- Contract cancellation handling

### 4. Payment Processing
- Milestone-based payments
- Transaction management
- Payment tracking and history

### 5. Chat & Communication
- Real-time messaging between users
- Chat history management
- Notification system

### 6. Review System
- User reviews and ratings
- Review management
- Admin review oversight

### 7. Proposal Management
- Freelancer proposal submission
- Proposal tracking and status
- Proposal acceptance/rejection

### 8. File Management
- File upload and download
- File storage via MinIO

### 9. Admin Features
- Admin review management
- Transaction monitoring
- Job status admin controls
- System administration tools

### 10. Skills Management
- Skill catalog and management
- User skill profiles
- Job required skills

## API Documentation
The application provides Swagger/OpenAPI documentation accessible through the configured Swagger endpoint. All REST endpoints are fully documented with request/response schemas.

## Getting Started

### Prerequisites
- Java 8 or higher
- PostgreSQL database
- Maven
- MinIO instance (optional, for file storage)

### Configuration
Update `application.properties` with your database and MinIO credentials:
- Database connection details
- MinIO endpoint and credentials
- CORS settings
- Other environment-specific settings

### Database Setup
Flyway automatically manages database migrations on application startup. Ensure the PostgreSQL database exists before starting the application.

### Running the Application
```bash
mvn spring-boot:run
```

The application will:
1. Run pending database migrations
2. Initialize the Spring Boot context
3. Start the embedded Tomcat server
4. Become available at `http://localhost:8080`

## Development Notes

### REST API Standards
- All endpoints follow RESTful conventions
- JSON request/response format
- Proper HTTP status codes
- Error handling with meaningful messages

### Database Design
- PostgreSQL with JPA/Hibernate ORM
- Flyway-managed migrations
- Proper indexing and constraints
- Referential integrity enforcement

### Security
- Spring Security framework
- JWT-based authentication
- Role-based access control
- CORS configuration for cross-origin requests

### File Storage
- MinIO for object storage (S3-compatible)
- Support for profile pictures, job attachments, etc.

## Testing
Located in `src/test/java/sdu/database/piedpiper/`:
- Unit tests for services
- Integration tests
- Test utilities and helpers

## Support & Maintenance
For issues or questions:
1. Review the API documentation via Swagger endpoint
2. Check application logs for error details
3. Verify database migrations completed successfully
4. Ensure all required services (PostgreSQL, MinIO) are running

## Version History
- Current Version: Actively maintained
- Database: Latest migrations integrated (V14)
- Build: Maven-based with standard Spring Boot configuration
