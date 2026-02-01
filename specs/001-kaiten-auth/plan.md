# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement an MVP Kaiten integration that allows a user to enter their organization URL and personal token, verify the token against Kaiten API (GET https://<org>/api/latest/users/current with `Authorization: Bearer <token>`), fetch the current user profile, and persist credentials in a local SQLite database (`data/kaiten.db`). Backend will provide three internal endpoints (`/api/kaiten/connect`, `/api/kaiten/profile`, `/api/kaiten/disconnect`) and the frontend will provide a simple UI for entering credentials, checking connection, and resetting authorization. Use Spring Boot backend + RestTemplate and JdbcTemplate for persistence; UI in existing React/TypeScript app.


## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Java 21 (backend), TypeScript (frontend)  
**Primary Dependencies**: Spring Boot 3.5.x, `org.xerial:sqlite-jdbc`, `spring-jdbc` (backend); React & TypeScript (frontend)  
**Storage**: SQLite local DB (`data/kaiten.db`)  
**Testing**: JUnit 5 + Mockito (backend unit tests), React testing library / Jest (frontend unit tests)  
**Target Platform**: Linux / Windows local development (desktop)  
**Project Type**: Web application (separate `backend/` and `ui/` projects)  
**Performance Goals**: Low throughput (human-driven operations); ensure token verification completes under 10s under normal conditions and respect Kaiten rate limits (5 req/sec)  
**Constraints**: Respect Kaiten API rate limiting; tokens are stored in plaintext per spec (security tradeoff)  
**Scale/Scope**: Single-user desktop use for now (MVP single credential model)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

All constitution gates apply; this feature follows the project constitution:

- Languages and documentation: Docs and user-facing messages in Russian; code identifiers and commits in English. ✅
- Testing policy: Unit tests only (no Spring context integration tests) — plan includes unit tests for services and repositories. ✅
- Local environment versions: Feature adds no special runtime beyond SQLite; Quickstart documents Java and Node version checks and DB requirements per constitution. ✅

**Additional Gate (Environment)**: Local development and test tool versions (Java, Node, npm, etc.) MUST be verified and set according to the project's documented versions (use `sdkman` for Java, `nvm` for Node). Required versions recorded in `specs/001-kaiten-auth/quickstart.md`. ✅

No constitution violations detected; if any deviation is considered later (e.g., adding native keychain integration), it must be justified and recorded in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: Use the existing `backend/` Spring Boot service for server-side logic and persistence, and the `ui/` React/TypeScript app for user interaction. Concrete changes:

- Backend (`backend/`)
  - Add package `com.kaiten.mcp.kaiten` with `KaitenController`, `KaitenService`, `KaitenClient`, and `KaitenCredentialsRepository`.
  - Add DB initialization and migration helper to create `data/kaiten.db` and table `kaiten_credentials`.
  - Add dependencies: `org.xerial:sqlite-jdbc`, `org.springframework.boot:spring-boot-starter-jdbc`.
  - Add endpoints: `POST /api/kaiten/connect`, `GET /api/kaiten/profile`, `POST /api/kaiten/disconnect`.

- Frontend (`ui/`)
  - Add `src/pages/KaitenAuth.tsx` (or integrate component into `Home.tsx`) for input fields (orgUrl, token), buttons (Check/Connect, Reset), and display of current profile.
  - Add API service `src/services/kaiten.ts` calling backend endpoints.

This structure follows the project constitution: small, focused changes in existing backend and ui projects (KISS principle).

## Phase 0: Research

Artifacts:
- `research.md` — contains confirmation of Kaiten endpoints, authentication scheme (Bearer token), rate limiting, and integration notes.

## Phase 1: Design & Contracts

Deliverables:
- `data-model.md` — KaitenCredentials and KaitenUserProfile
- `contracts/openapi.yaml` — backend endpoints: `/api/kaiten/connect`, `/api/kaiten/profile`, `/api/kaiten/disconnect`
- `quickstart.md` — local environment and DB notes

Acceptance criteria for Phase 1:
1. API contract exists and describes expected inputs/outputs for connect/profile/disconnect.
2. Data model documents storage schema and constraints.
3. Quickstart documents DB location and required local versions.

## Phase 2: Implementation (high-level tasks)

Planned tasks (estimate and owner assigned during task breakdown):

1. Backend - Dependencies & DB initialization (2d)
   - Add `sqlite-jdbc` and `spring-jdbc` to `backend/pom.xml`.
   - Implement DB initialization component that creates `data/kaiten.db` and `kaiten_credentials` table if not present.

2. Backend - Persistence layer (2d)
   - Implement `KaitenCredentialsRepository` using `JdbcTemplate` with methods: `saveOrUpdate(credentials)`, `find()`, `delete()`.

3. Backend - External client & service (2d)
   - Implement `KaitenClient` that calls `{org}/api/latest/users/current` with `Authorization: Bearer <token>` using `RestTemplate` and returns parsed profile.
   - Implement `KaitenService` that orchestrates verification and persistence.

4. Backend - Controller (1d)
   - Implement `KaitenController` with endpoints defined in `contracts/openapi.yaml`.

5. Frontend - UI & integration (2d)
   - Add `KaitenAuth` component for input fields, connect/check button, and reset button.
   - Wire to `/api/kaiten/*` backend endpoints and display profile or errors.

6. Tests (2d)
   - Unit tests for `KaitenClient` (mock RestTemplate), `KaitenCredentialsRepository` (unit tests with embedded/in-memory DB or mocking), `KaitenService` (mock dependencies), and UI component tests.

7. Docs & Quickstart (0.5d)
   - Update `specs/001-kaiten-auth/quickstart.md` and `docs/quickstart.md` if needed to mention DB and environment requirements.

8. Smoke & Manual QA (0.5d)
   - Add a smoke script to `tests/smoke` verifying local behavior (connect/disconnect flows) and update existing smoke tests as needed.

**Total**: ~10 days (TBD) — estimates are conservative; break into smaller tasks for PRs.

## Gate: Re-check Constitution after Phase 1
- Confirm unit tests are present and do not initialize Spring context.
- Confirm docs updated to include environment checks (Java/Node versions) per constitution.

## Complexity Tracking

No constitution violations detected; no special exceptions required at this stage.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
