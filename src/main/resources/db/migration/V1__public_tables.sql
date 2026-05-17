-- V1: This script initializes the public tables for the application,
-- defining the core data structures for users, jobs, contracts, and more.

-- Drop existing tables to ensure a clean slate on re-running the script.
-- CASCADE drops dependent objects.
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS contracts CASCADE;
DROP TABLE IF EXISTS proposals CASCADE;
DROP TABLE IF EXISTS profile_skills CASCADE;
DROP TABLE IF EXISTS jobs CASCADE;
DROP TABLE IF EXISTS job_statuses CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS skills CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS contract_milestones CASCADE;
DROP TABLE IF EXISTS job_required_skills CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS chat_conversations CASCADE;
DROP TABLE IF EXISTS skill_suggestions CASCADE;

-- Table for user roles (e.g., client, freelancer, admin).
CREATE TABLE roles (
    id   INTEGER PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);
COMMENT ON TABLE roles IS 'Stores user roles, such as client, freelancer, or admin.';

-- Table for job statuses (e.g., OPEN, IN_PROGRESS, COMPLETED).
CREATE TABLE job_statuses (
    id          INTEGER PRIMARY KEY,
    status_name VARCHAR(50) UNIQUE NOT NULL
);
COMMENT ON TABLE job_statuses IS 'Defines the possible statuses for a job, like OPEN, IN_PROGRESS, etc.';

-- Table for user accounts, handling authentication and basic user information.
CREATE TABLE accounts (
    id            BIGSERIAL PRIMARY KEY,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255)        NOT NULL,
    role_id       INTEGER REFERENCES roles(id),
    -- Status can be 'active', 'inactive', 'suspended'.
    status        VARCHAR(50)  DEFAULT 'active',
    last_login    TIMESTAMP,
    created_at    TIMESTAMP    DEFAULT NOW()
);
COMMENT ON TABLE accounts IS 'Manages user authentication details and account status.';

-- Table for user profiles, containing personal and professional information.
CREATE TABLE profiles (
    id          BIGSERIAL PRIMARY KEY,
    account_id  BIGINT REFERENCES accounts(id) ON DELETE CASCADE,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    bio         TEXT,
    hourly_rate DECIMAL(10,2),
    avatar_url  VARCHAR(1000),
    updated_at  TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE profiles IS 'Stores detailed user profiles, including bio, rates, and contact information.';

-- Table for skills that can be associated with profiles and jobs.
CREATE TABLE skills (
    id       SERIAL PRIMARY KEY,
    name     VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(100)
);
COMMENT ON TABLE skills IS 'A central repository of skills that can be assigned to users or required by jobs.';

-- Joins profiles and skills, indicating a user's proficiency in a skill.
CREATE TABLE profile_skills (
    profile_id  BIGINT  REFERENCES profiles(id) ON DELETE CASCADE,
    skill_id    INTEGER REFERENCES skills(id)   ON DELETE CASCADE,
    -- e.g., 'Beginner', 'Intermediate', 'Expert'
    skill_level VARCHAR(50),
    PRIMARY KEY (profile_id, skill_id)
);
COMMENT ON TABLE profile_skills IS 'Maps skills to user profiles, defining their skill level.';

-- Table for jobs posted by clients.
CREATE TABLE jobs (
    id          BIGSERIAL PRIMARY KEY,
    client_id   BIGINT  REFERENCES profiles(id),
    category_id INTEGER,
    title       VARCHAR(255)   NOT NULL,
    description TEXT,
    -- e.g., 'fixed', 'hourly'
    budget_type VARCHAR(50),
    min_budget  DECIMAL(15,2),
    max_budget  DECIMAL(15,2),
    status_id   INTEGER REFERENCES job_statuses(id),
    application_deadline DATE,
    start_date DATE,
    end_date DATE,
    is_cancelled BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE jobs IS 'Contains all job postings from clients.';

-- Joins jobs and skills, indicating the skills required for a job.
CREATE TABLE job_required_skills (
    job_id   BIGINT  REFERENCES jobs(id)   ON DELETE CASCADE,
    skill_id INTEGER REFERENCES skills(id) ON DELETE CASCADE,
    PRIMARY KEY (job_id, skill_id)
);
COMMENT ON TABLE job_required_skills IS 'Specifies the skills required for a particular job.';

-- Table for proposals submitted by freelancers for jobs.
CREATE TABLE proposals (
    id            BIGSERIAL PRIMARY KEY,
    job_id        BIGINT REFERENCES jobs(id)     ON DELETE CASCADE,
    freelancer_id BIGINT REFERENCES profiles(id),
    bid_amount    DECIMAL(15,2),
    delivery_days INTEGER,
    cover_letter  TEXT,
    -- e.g., 'pending', 'accepted', 'rejected'
    status        VARCHAR(50) DEFAULT 'pending',
    is_withdrawn BOOLEAN DEFAULT FALSE,
    withdrawn_at TIMESTAMP,
    created_at    TIMESTAMP   DEFAULT NOW()
);
COMMENT ON TABLE proposals IS 'Stores proposals made by freelancers in response to job postings.';

-- Table for contracts created when a proposal is accepted.
CREATE TABLE contracts (
    id            BIGSERIAL PRIMARY KEY,
    job_id        BIGINT REFERENCES jobs(id),
    freelancer_id BIGINT REFERENCES profiles(id),
    total_amount  DECIMAL(15,2),
    -- e.g., 'active', 'completed', 'cancelled'
    status        VARCHAR(50) DEFAULT 'active',
    start_date TIMESTAMP,
    estimated_end_date TIMESTAMP,
    actual_end_date TIMESTAMP,
    cancellation_reason VARCHAR(255),
    cancelled_by BIGINT REFERENCES accounts(id),
    created_at TIMESTAMP DEFAULT NOW(),
    paid_amount DECIMAL(15,2) DEFAULT 0 CHECK (paid_amount >= 0)
);
COMMENT ON TABLE contracts IS 'Represents formal agreements between clients and freelancers.';

-- Table for financial transactions related to contracts.
CREATE TABLE transactions (
    id          BIGSERIAL PRIMARY KEY,
    contract_id BIGINT REFERENCES contracts(id),
    amount      DECIMAL(15,2),
    -- e.g., 'payment', 'refund', 'payout'
    type        VARCHAR(50),
    created_at  TIMESTAMP DEFAULT NOW()
);
COMMENT ON TABLE transactions IS 'Logs all financial transactions, such as payments and refunds.';

-- Table for reviews given by clients or freelancers at the end of a contract.
CREATE TABLE reviews (
    id          BIGSERIAL PRIMARY KEY,
    contract_id BIGINT REFERENCES contracts(id),
    reviewer_id BIGINT REFERENCES profiles(id),
    rating      INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment     TEXT,
    CONSTRAINT ck_rating_valid CHECK (rating BETWEEN 1 AND 5)
);
COMMENT ON TABLE reviews IS 'Stores ratings and comments for completed contracts.';

-- Table for notifications sent to users.
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    notification_type VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    -- Polymorphic association to link to different entities (e.g., 'job', 'proposal').
    related_entity_type VARCHAR(100),
    related_entity_id BIGINT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    read_at TIMESTAMP
);
CREATE INDEX idx_notifications_account_id ON notifications(account_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
COMMENT ON TABLE notifications IS 'Manages notifications for users about various events.';

-- Table for logging audit trails for important changes.
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    entity_type VARCHAR(100) NOT NULL,
    entity_id BIGINT NOT NULL,
    action VARCHAR(50) NOT NULL,
    changed_by BIGINT REFERENCES accounts(id),
    old_value JSONB,
    new_value JSONB,
    change_summary TEXT,
    changed_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_log_changed_at ON audit_log(changed_at DESC);
CREATE INDEX idx_audit_log_changed_by ON audit_log(changed_by);
COMMENT ON TABLE audit_log IS 'Tracks changes to important data for auditing purposes.';

-- Table for contract milestones, breaking down a contract into smaller payable parts.
CREATE TABLE contract_milestones (
    id              BIGSERIAL PRIMARY KEY,
    contract_id     BIGINT REFERENCES contracts(id) ON DELETE CASCADE NOT NULL,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    amount          DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    -- e.g., 'pending', 'in_progress', 'completed', 'paid'
    status          VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'paid')),
    due_date        DATE,
    completed_at    TIMESTAMP,
    paid_at         TIMESTAMP,
    created_at      TIMESTAMP DEFAULT NOW(),
    updated_at      TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_milestones_contract ON contract_milestones(contract_id);
CREATE INDEX idx_milestones_status ON contract_milestones(status);
COMMENT ON TABLE contract_milestones IS 'Defines milestones for a contract, each with its own payment and deadline.';

-- Table to store chat conversations, typically linked to a contract.
CREATE TABLE chat_conversations (
    id              BIGSERIAL PRIMARY KEY,
    contract_id     BIGINT REFERENCES contracts(id) ON DELETE CASCADE,
    client_id       BIGINT REFERENCES profiles(id) NOT NULL,
    freelancer_id   BIGINT REFERENCES profiles(id) NOT NULL,
    last_message_at TIMESTAMP DEFAULT NOW(),
    created_at      TIMESTAMP DEFAULT NOW(),
    UNIQUE(contract_id),
    CONSTRAINT check_different_participants CHECK (client_id != freelancer_id)
);
COMMENT ON TABLE chat_conversations IS 'Stores metadata for a single chat session between a client and a freelancer.';

-- Table to store individual chat messages.
CREATE TABLE chat_messages (
    id                BIGSERIAL PRIMARY KEY,
    conversation_id   BIGINT REFERENCES chat_conversations(id) ON DELETE CASCADE NOT NULL,
    sender_id         BIGINT REFERENCES profiles(id) NOT NULL,
    message_text      TEXT,
    file_object_name  VARCHAR(500),
    file_url          VARCHAR(1000),
    file_type         VARCHAR(255),
    file_size         BIGINT,
    is_read           BOOLEAN DEFAULT FALSE,
    created_at        TIMESTAMP DEFAULT NOW(),
    CONSTRAINT check_message_content CHECK (message_text IS NOT NULL OR file_object_name IS NOT NULL)
);
COMMENT ON TABLE chat_messages IS 'Contains individual chat messages, including text and file attachments.';

-- Table to store skill suggestions from users.
CREATE TABLE skill_suggestions (
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    category        VARCHAR(100),
    suggested_by    BIGINT REFERENCES profiles(id) NOT NULL,
    status          VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    admin_comment   TEXT,
    reviewed_by     BIGINT REFERENCES profiles(id), -- Admin who reviewed the suggestion
    reviewed_at     TIMESTAMP,
    created_at      TIMESTAMP DEFAULT NOW(),
    CONSTRAINT unique_pending_skill_name UNIQUE (name, status)
);
COMMENT ON TABLE skill_suggestions IS 'Stores new skill suggestions from users awaiting admin approval.';

-- Seed data for roles and job_statuses.
INSERT INTO roles (id, name) VALUES
    (1, 'client'),
    (2, 'freelancer'),
    (3, 'admin');

INSERT INTO job_statuses (id, status_name) VALUES
    (1, 'OPEN'),
    (2, 'IN_PROGRESS'),
    (3, 'COMPLETED'),
    (4, 'CANCELLED'),
    (5, 'ARCHIVED')
ON CONFLICT (id) DO NOTHING;
