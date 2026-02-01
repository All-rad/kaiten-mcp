# Research: Kaiten API integration (001-kaiten-auth)

## Decisions

- Decision: Use Kaiten endpoint to retrieve current user: GET https://<org>.kaiten.ru/api/latest/users/current (prefer `/api/latest` to get latest version).
  - Rationale: Official documentation provides `/api/latest/users/current`. Using `latest` ensures server will route to newest API.
  - Alternatives evaluated: `/api/v1/users/current` (explicit version) — rejected in favor of `latest` to use newest supported behavior.

- Decision: Authentication header: Use Bearer token via standard HTTP Authorization header: `Authorization: Bearer <token>`.
  - Rationale: Documented by Kaiten API; simple and standard.

- Decision: Handle rate limiting: respect `X-RateLimit-Remaining` and `X-RateLimit-Reset`; implement a simple backoff on 429 (retry after indicated reset) and show user-friendly error when limit reached.
  - Rationale: Kaiten docs state limit 5 req/sec; our usage is low but backoff prevents poor UX.

- Decision: Use Spring RestTemplate for HTTP calls (backend) for simplicity and minimal dependencies.
  - Rationale: RestTemplate is simpler to use for small sync operations; aligns with Constitution principle "Speed and Simplicity". Alternative was WebClient (reactive) — more modern but added complexity for MVP.

- Decision: Persistence: Local SQLite DB (`data/kaiten.db`) storing a single credential row in table `kaiten_credentials` with schema `{ id INTEGER PRIMARY KEY, org_url TEXT, token TEXT, profile_json TEXT, saved_at TEXT }`.
  - Rationale: Specified requirement; chosen because user asked for SQLite. Single-row model simplifies migration.

- Decision: Single credential model (MVP) — new authorization overwrites existing credentials.
  - Rationale: Minimal viable functionality; can be extended later.

## Security notes / Assumptions
- Tokens will be stored in plaintext as requested by stakeholder. This is explicitly a security tradeoff; document in spec and quickstart.
- Future improvement: support OS-protected keystore or encrypt tokens at rest.

## Integration notes
- Kaiten requires `Authorization: Bearer <token>` and JSON responses.
- Typical response includes `id`, `full_name`, `email`; store full response in `profile_json` for flexibility.

## Implementation checklist (research → dev)
- Add `org.xerial:sqlite-jdbc` and `spring-jdbc` to `backend/pom.xml`.
- Implement `KaitenClient` service that queries `${org}/api/latest/users/current` with RestTemplate and `Authorization: Bearer <token>` header.
- Implement `KaitenCredentialsRepository` using `JdbcTemplate` for simple CRUD (single row) and DB initialization script.
- Add backend REST endpoints: `POST /api/kaiten/connect`, `GET /api/kaiten/profile`, `POST /api/kaiten/disconnect`.
- Add UI components: `src/pages/KaitenAuth.tsx` or integrate in `Home.tsx` with inputs for URL and token, check button, and reset button.
- Add unit tests for `KaitenClient` (mock RestTemplate), `KaitenCredentialsRepository` (in-memory SQLite or mocking), and component tests for UI.
