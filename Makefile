.PHONY: verify-agent-harness verify-repository-structure verify-backend verify-frontend verify-db verify-all

verify-agent-harness:
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-agent-harness.ps1

verify-repository-structure:
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-repository-structure.ps1

verify-backend: verify-agent-harness verify-repository-structure
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-backend.ps1

verify-frontend: verify-agent-harness verify-repository-structure
	powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-frontend.ps1

verify-db: verify-agent-harness verify-repository-structure

verify-all: verify-agent-harness verify-repository-structure verify-backend verify-frontend
