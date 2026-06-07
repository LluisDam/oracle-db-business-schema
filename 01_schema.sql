-- Oracle DB Business Schema — Kit Digital Project Management
-- Autor: Lluis Soberats | github.com/LluisDam

CREATE TABLE clients (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(200) NOT NULL,
    nif VARCHAR2(20) UNIQUE,
    email VARCHAR2(200),
    phone VARCHAR2(30),
    city VARCHAR2(100),
    sector VARCHAR2(100),
    kit_digital CHAR(1) DEFAULT 'N' CHECK (kit_digital IN ('Y','N')),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE team_members (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(200) NOT NULL,
    email VARCHAR2(200) NOT NULL UNIQUE,
    role VARCHAR2(100),
    hourly_rate NUMBER(10,2) DEFAULT 0,
    active CHAR(1) DEFAULT 'Y' CHECK (active IN ('Y','N'))
);

CREATE TABLE projects (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id NUMBER NOT NULL REFERENCES clients(id),
    name VARCHAR2(300) NOT NULL,
    description CLOB,
    status VARCHAR2(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING','IN_PROGRESS','COMPLETED','CANCELLED','ON_HOLD')),
    priority VARCHAR2(10) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    budget NUMBER(12,2) DEFAULT 0,
    spent NUMBER(12,2) DEFAULT 0,
    start_date DATE,
    end_date DATE,
    kit_digital_code VARCHAR2(50),
    kit_digital_amount NUMBER(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT ck_project_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE sprints (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id NUMBER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR2(100) NOT NULL,
    goal VARCHAR2(500),
    status VARCHAR2(20) DEFAULT 'PLANNED' CHECK (status IN ('PLANNED','ACTIVE','COMPLETED','CANCELLED')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    velocity_planned NUMBER DEFAULT 0,
    velocity_actual NUMBER DEFAULT 0,
    CONSTRAINT ck_sprint_dates CHECK (end_date > start_date)
);

CREATE TABLE tasks (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id NUMBER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    sprint_id NUMBER REFERENCES sprints(id),
    title VARCHAR2(500) NOT NULL,
    description CLOB,
    status VARCHAR2(20) DEFAULT 'TODO' CHECK (status IN ('TODO','IN_PROGRESS','IN_REVIEW','DONE','CANCELLED')),
    priority VARCHAR2(10) DEFAULT 'MEDIUM',
    story_points NUMBER DEFAULT 0,
    estimated_hours NUMBER(6,2) DEFAULT 0,
    logged_hours NUMBER(6,2) DEFAULT 0,
    assignee_id NUMBER REFERENCES team_members(id),
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE time_logs (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id NUMBER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    member_id NUMBER NOT NULL REFERENCES team_members(id),
    hours NUMBER(5,2) NOT NULL CHECK (hours > 0),
    log_date DATE DEFAULT SYSDATE,
    description VARCHAR2(500),
    billable CHAR(1) DEFAULT 'Y' CHECK (billable IN ('Y','N'))
);

CREATE TABLE risks (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id NUMBER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    description VARCHAR2(1000) NOT NULL,
    probability VARCHAR2(10) CHECK (probability IN ('LOW','MEDIUM','HIGH')),
    impact VARCHAR2(10) CHECK (impact IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    status VARCHAR2(20) DEFAULT 'OPEN',
    mitigation VARCHAR2(1000),
    owner_id NUMBER REFERENCES team_members(id)
);

-- Performance indexes
CREATE INDEX idx_projects_client ON projects(client_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_tasks_project ON tasks(project_id);
CREATE INDEX idx_tasks_sprint ON tasks(sprint_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_sprints_project ON sprints(project_id);
CREATE INDEX idx_time_logs_task ON time_logs(task_id);

COMMIT;
