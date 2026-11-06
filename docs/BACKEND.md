# Intelligence integration roadmap

Build 0.1 has no backend and makes no remote AI requests. `AIService` is the replacement seam; `SampleAIService` deliberately labels its responses. A later live implementation must disclose health-context processing and obtain explicit consent before upload.

Plan a separate FastAPI repository with PostgreSQL, OpenAI, personal-baseline computation, Pinecone retrieval, scoped LangChain/LlamaIndex ingestion/retrieval roles, and LangGraph orchestration. Verify compatible versions before selecting dependencies. No additional repository or cloud resources have been created.

Proposed routes (design only, not implemented):

| Method | Route | Purpose |
| --- | --- | --- |
| POST | `/v1/health/sync` | Idempotent, authenticated summary synchronization |
| GET | `/v1/insights/today` | Grounded daily briefing |
| GET | `/v1/insights/history` | Cursor-paginated briefings |
| POST | `/v1/chat` | Grounded conversation |
| GET | `/v1/patterns` | Observations and evidence |
| DELETE | `/v1/account` | Account and derived-data deletion |

Before implementing a client, specify an OpenAPI contract with versioned envelopes, ISO-8601 timestamps, timezone and aggregation period, explicit units, nullable measurements, provenance, stable IDs, cursor pagination, error codes, retry rules, and idempotency semantics. Derive ownership from authenticated identity, never trust a client-supplied user ID. Keep provider keys server-side. Minimize health records; enforce user isolation across relational data, vectors, and memory. Deletion must cover derived embeddings and cached context as well as database records. Treat retrieved content as untrusted data and test unsupported or insufficient-evidence answers.

References consulted for the native integration:

- [Apple: authorizing access to health data](https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data)
- [Apple: transferring data with Watch Connectivity](https://developer.apple.com/documentation/watchconnectivity/transferring-data-with-watch-connectivity)
