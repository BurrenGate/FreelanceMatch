DROP TABLE IF EXISTS reviews        CASCADE;
DROP TABLE IF EXISTS transactions   CASCADE;
DROP TABLE IF EXISTS contracts      CASCADE;
DROP TABLE IF EXISTS proposals      CASCADE;
DROP TABLE IF EXISTS profile_skills CASCADE;
DROP TABLE IF EXISTS jobs           CASCADE;
DROP TABLE IF EXISTS job_statuses   CASCADE;
DROP TABLE IF EXISTS profiles       CASCADE;
DROP TABLE IF EXISTS skills         CASCADE;
DROP TABLE IF EXISTS accounts       CASCADE;
DROP TABLE IF EXISTS roles          CASCADE;

CREATE TABLE roles (
                       id   INTEGER PRIMARY KEY,
                       name VARCHAR(50) NOT NULL
);

CREATE TABLE job_statuses (
                              id          INTEGER PRIMARY KEY,
                              status_name VARCHAR(50) NOT NULL
);

CREATE TABLE accounts (
                          id            BIGSERIAL PRIMARY KEY,
                          email         VARCHAR(255) UNIQUE NOT NULL,
                          password_hash VARCHAR(255)        NOT NULL,
                          role_id       INTEGER REFERENCES roles(id),
                          status        VARCHAR(50)  DEFAULT 'active',
                          last_login    TIMESTAMP,
                          created_at    TIMESTAMP    DEFAULT NOW()
);

CREATE TABLE profiles (
                          id          BIGSERIAL PRIMARY KEY,
                          account_id  BIGINT REFERENCES accounts(id) ON DELETE CASCADE,
                          first_name  VARCHAR(100),
                          last_name   VARCHAR(100),
                          bio         TEXT,
                          hourly_rate DECIMAL(10,2),
                          avatar_url  VARCHAR(255),
                          updated_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE skills (
                        id       SERIAL PRIMARY KEY,
                        name     VARCHAR(100) UNIQUE NOT NULL,
                        category VARCHAR(100)
);

CREATE TABLE profile_skills (
                                profile_id  BIGINT  REFERENCES profiles(id) ON DELETE CASCADE,
                                skill_id    INTEGER REFERENCES skills(id)   ON DELETE CASCADE,
                                skill_level VARCHAR(50),
                                PRIMARY KEY (profile_id, skill_id)
);

CREATE TABLE jobs (
                      id          BIGSERIAL PRIMARY KEY,
                      client_id   BIGINT  REFERENCES profiles(id),
                      category_id INTEGER,
                      title       VARCHAR(255)   NOT NULL,
                      description TEXT,
                      budget_type VARCHAR(50),
                      min_budget  DECIMAL(15,2),
                      max_budget  DECIMAL(15,2),
                      status_id   INTEGER REFERENCES job_statuses(id),
                      created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE proposals (
                           id            BIGSERIAL PRIMARY KEY,
                           job_id        BIGINT REFERENCES jobs(id)     ON DELETE CASCADE,
                           freelancer_id BIGINT REFERENCES profiles(id),
                           bid_amount    DECIMAL(15,2),
                           delivery_days INTEGER,
                           cover_letter  TEXT,
                           status        VARCHAR(50) DEFAULT 'pending',
                           created_at    TIMESTAMP   DEFAULT NOW()
);

CREATE TABLE contracts (
                           id            BIGSERIAL PRIMARY KEY,
                           job_id        BIGINT REFERENCES jobs(id),
                           freelancer_id BIGINT REFERENCES profiles(id),
                           total_amount  DECIMAL(15,2),
                           status        VARCHAR(50) DEFAULT 'active'
);

CREATE TABLE transactions (
                              id          BIGSERIAL PRIMARY KEY,
                              contract_id BIGINT REFERENCES contracts(id),
                              amount      DECIMAL(15,2),
                              type        VARCHAR(50),
                              created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE reviews (
                         id          BIGSERIAL PRIMARY KEY,
                         contract_id BIGINT REFERENCES contracts(id),
                         reviewer_id BIGINT REFERENCES profiles(id),
                         rating      INTEGER CHECK (rating BETWEEN 1 AND 5),
                         comment     TEXT
);

INSERT INTO roles (id, name) VALUES
                                 (1, 'client'),
                                 (2, 'freelancer'),
                                 (3, 'admin');

INSERT INTO job_statuses (id, status_name) VALUES
                                               (1, 'OPEN'),
                                               (2, 'IN_PROGRESS'),
                                               (3, 'COMPLETED'),
                                               (4, 'CANCELLED');

CREATE TABLE job_required_skills (
                                     job_id   BIGINT  REFERENCES jobs(id)   ON DELETE CASCADE,
                                     skill_id INTEGER REFERENCES skills(id) ON DELETE CASCADE,
                                     PRIMARY KEY (job_id, skill_id)
);

