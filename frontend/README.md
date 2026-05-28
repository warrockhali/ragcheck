# Frontend

Frontend code will expose the RAGCheck test harness experience.

This milestone uses a dependency-free static skeleton:

- `index.html`: app shell, navigation, MVP placeholder pages.
- `src/app.js`: hash-based route rendering for skeleton screens.
- `src/styles.css`: responsive layout and placeholder states.

MVP screens should focus on:

- Project management
- RAG endpoint configuration
- Response mapping
- Test case management
- Evaluation run execution
- Evaluation result dashboard
- Failure type classification

Do not build a chatbot UI or a document upload app as the MVP surface.

Verify frontend skeleton files with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify-frontend.ps1
```
