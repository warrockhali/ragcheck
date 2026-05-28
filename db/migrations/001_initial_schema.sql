PRAGMA foreign_keys = ON;

CREATE TABLE projects (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rag_endpoints (
    id INTEGER PRIMARY KEY,
    project_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    endpoint_url TEXT NOT NULL,
    method TEXT NOT NULL CHECK (method IN ('GET', 'POST', 'PUT', 'PATCH', 'DELETE')),
    headers_template TEXT NOT NULL DEFAULT '{}',
    body_template TEXT NOT NULL DEFAULT '{}',
    response_mapping TEXT NOT NULL DEFAULT '{}',
    timeout_ms INTEGER NOT NULL CHECK (timeout_ms > 0),
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

CREATE TABLE test_cases (
    id INTEGER PRIMARY KEY,
    project_id INTEGER NOT NULL,
    question TEXT NOT NULL,
    expected_answer TEXT NOT NULL,
    expected_context_hint TEXT NOT NULL,
    category TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

CREATE TABLE evaluation_runs (
    id INTEGER PRIMARY KEY,
    project_id INTEGER NOT NULL,
    rag_endpoint_id INTEGER NOT NULL,
    name TEXT,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (
        status IN ('PENDING', 'RUNNING', 'COMPLETED', 'FAILED')
    ),
    started_at TEXT,
    completed_at TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (rag_endpoint_id) REFERENCES rag_endpoints(id) ON DELETE RESTRICT
);

CREATE TABLE evaluation_results (
    id INTEGER PRIMARY KEY,
    evaluation_run_id INTEGER NOT NULL,
    test_case_id INTEGER NOT NULL,
    request_payload TEXT,
    response_body TEXT,
    actual_answer TEXT,
    actual_contexts TEXT,
    status_code INTEGER,
    retrieval_score REAL CHECK (
        retrieval_score IS NULL OR (retrieval_score >= 0.0 AND retrieval_score <= 1.0)
    ),
    groundedness_score REAL CHECK (
        groundedness_score IS NULL OR (groundedness_score >= 0.0 AND groundedness_score <= 1.0)
    ),
    answer_score REAL CHECK (
        answer_score IS NULL OR (answer_score >= 0.0 AND answer_score <= 1.0)
    ),
    failure_type TEXT NOT NULL CHECK (
        failure_type IN (
            'GOOD',
            'RETRIEVAL_FAILURE',
            'CONTEXT_INSUFFICIENT',
            'HALLUCINATION',
            'ANSWER_INCORRECT',
            'FORMAT_ERROR',
            'API_ERROR'
        )
    ),
    latency_ms INTEGER CHECK (latency_ms IS NULL OR latency_ms >= 0),
    error_message TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (evaluation_run_id) REFERENCES evaluation_runs(id) ON DELETE CASCADE,
    FOREIGN KEY (test_case_id) REFERENCES test_cases(id) ON DELETE RESTRICT
);

CREATE INDEX idx_rag_endpoints_project_id ON rag_endpoints(project_id);
CREATE INDEX idx_test_cases_project_id ON test_cases(project_id);
CREATE INDEX idx_evaluation_runs_project_id ON evaluation_runs(project_id);
CREATE INDEX idx_evaluation_runs_rag_endpoint_id ON evaluation_runs(rag_endpoint_id);
CREATE INDEX idx_evaluation_results_evaluation_run_id
    ON evaluation_results(evaluation_run_id);
CREATE INDEX idx_evaluation_results_test_case_id ON evaluation_results(test_case_id);
