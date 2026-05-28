.PHONY: verify-agent-harness verify-backend verify-frontend verify-db verify-all

verify-agent-harness:
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-agent-harness.ps1

verify-backend: verify-agent-harness

verify-frontend: verify-agent-harness

verify-db: verify-agent-harness

verify-all: verify-agent-harness
