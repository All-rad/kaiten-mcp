---
description: "Tasks for 001-kaiten-auth: Kaiten integration feature"
---

# Tasks: Тестовая интеграция с Kaiten API

**Input**: `specs/001-kaiten-auth/spec.md`, `specs/001-kaiten-auth/plan.md`, `specs/001-kaiten-auth/research.md`, `specs/001-kaiten-auth/data-model.md`, `specs/001-kaiten-auth/contracts/openapi.yaml`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare toolchain and project-level dependencies needed for the feature

- [ ] T001 [P] Add SQLite and JDBC dependencies to `backend/pom.xml` (add `org.xerial:sqlite-jdbc` and `org.springframework.boot:spring-boot-starter-jdbc`) — `backend/pom.xml`
- [ ] T002 [P] Add DB configuration properties in `backend/src/main/resources/application.properties` (configure `spring.datasource.url=jdbc:sqlite:${project.basedir}/../data/kaiten.db` or equivalent) — `backend/src/main/resources/application.properties`
- [ ] T003 [P] Add `data/` directory and ignore DB file in `.gitignore` (create `data/` and add `data/kaiten.db` to `.gitignore`) — `data/`, `.gitignore`
- [ ] T004 [P] Create frontend service skeleton `ui/src/services/kaiten.ts` (API client to call backend endpoints) — `ui/src/services/kaiten.ts`
- [ ] T005 [P] Update `specs/001-kaiten-auth/quickstart.md` and `docs/quickstart.md` with local environment steps (Java/Node/SQLite) — `specs/001-kaiten-auth/quickstart.md`, `docs/quickstart.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Implement DB initialization, data model and core infra that all stories rely on

- [ ] T006 Implement DB initializer that ensures `data/kaiten.db` exists and table `kaiten_credentials` is created with schema `{ id INTEGER PRIMARY KEY, org_url TEXT, token TEXT, profile_json TEXT, saved_at TEXT }` — `backend/src/main/java/com/kaiten/mcp/kaiten/db/DatabaseInitializer.java`
- [ ] T007 Create model class `KaitenCredentials` mapping schema fields — `backend/src/main/java/com/kaiten/mcp/kaiten/model/KaitenCredentials.java`
- [ ] T008 Implement `KaitenCredentialsRepository` using `JdbcTemplate` with methods `saveOrUpdate(KaitenCredentials)`, `find() : Optional<KaitenCredentials>`, `delete()` — `backend/src/main/java/com/kaiten/mcp/kaiten/repository/KaitenCredentialsRepository.java`
- [ ] T009 [P] Add unit tests for `KaitenCredentialsRepository` (use temporary SQLite DB file or mocking) — `backend/src/test/java/com/kaiten/mcp/kaiten/repository/KaitenCredentialsRepositoryTest.java`
- [ ] T010 Implement `KaitenClient` to call `${org}/api/latest/users/current` with header `Authorization: Bearer <token>` and return parsed profile (use `RestTemplate`) — `backend/src/main/java/com/kaiten/mcp/kaiten/client/KaitenClient.java`
- [ ] T011 [P] Add unit tests for `KaitenClient` mocking `RestTemplate` and verifying proper headers and responses (valid, 401, 429, network errors) — `backend/src/test/java/com/kaiten/mcp/kaiten/client/KaitenClientTest.java`
- [ ] T012 Implement `KaitenService` that orchestrates verification, transforms response into `KaitenCredentials`/profile, and calls `KaitenCredentialsRepository` to persist — `backend/src/main/java/com/kaiten/mcp/kaiten/service/KaitenService.java`
- [ ] T013 Add unit tests for `KaitenService` (mock `KaitenClient` and `KaitenCredentialsRepository`) — `backend/src/test/java/com/kaiten/mcp/kaiten/service/KaitenServiceTest.java`

---

## Phase 3: User Story 1 - Подключение и проверка токена (Priority: P1) 🎯 MVP

**Goal**: Allow user to input `orgUrl` and `token`, verify token with Kaiten API, display profile and save credentials (single credential behavior)

**Independent Test**: POST valid credentials to `/api/kaiten/connect` and receive `200` with profile; invalid token returns `401` and no credentials are saved.

### Tests for User Story 1

- [ ] T014 [P] [US1] Add contract tests for `POST /api/kaiten/connect` validating success and error responses — `specs/001-kaiten-auth/contracts/openapi.yaml`, `backend/src/test/java/com/kaiten/mcp/kaiten/controller/KaitenControllerContractTest.java`
- [ ] T015 [P] [US1] Add unit tests for `KaitenController` behavior (happy path, 401, 400) — `backend/src/test/java/com/kaiten/mcp/kaiten/controller/KaitenControllerTest.java`

### Implementation for User Story 1

- [ ] T016 [US1] Create DTO `ConnectRequest` and `ConnectResponse` — `backend/src/main/java/com/kaiten/mcp/kaiten/dto/ConnectRequest.java`, `backend/src/main/java/com/kaiten/mcp/kaiten/dto/ConnectResponse.java`
- [ ] T017 [US1] Implement `KaitenController` with endpoints: `POST /api/kaiten/connect` (verify and save) — `backend/src/main/java/com/kaiten/mcp/kaiten/controller/KaitenController.java`
- [ ] T018 [US1] Implement controller error handling for invalid token (return 401) and network errors (return 503 with message) — `backend/src/main/java/com/kaiten/mcp/exception/GlobalExceptionHandler.java` (update or extend as needed)
- [ ] T019 [US1] Implement frontend component `ui/src/pages/KaitenAuth.tsx` with fields `orgUrl`, `token`, buttons `Connect` and `Reset`, and a profile display area — `ui/src/pages/KaitenAuth.tsx`
- [ ] T020 [US1] Implement frontend service methods `connect`, `getProfile`, `disconnect` in `ui/src/services/kaiten.ts` and wire component to them — `ui/src/services/kaiten.ts`, `ui/src/pages/KaitenAuth.tsx`
- [ ] T021 [US1] Add frontend unit tests for `KaitenAuth` component (mock API service) — `ui/tests/KaitenAuth.test.tsx`
- [ ] T022 [US1] Add backend integration/smoke test script to `tests/smoke/smoke-kaiten.sh` that attempts a full connect → profile → disconnect flow using a configurable test token — `tests/smoke/smoke-kaiten.sh`

**Checkpoint**: After T016–T022, US1 should be implementable and independently verifiable.

---

## Phase 4: User Story 2 - Сохранение и автозагрузка (Priority: P2)

**Goal**: Persist credentials in SQLite and automatically load and refresh profile on application startup (single credential model)

**Independent Test**: Start application with saved credentials present and verify that GET `/api/kaiten/profile` returns updated profile without user re-entering credentials.

### Tests for User Story 2

- [ ] T023 [P] [US2] Add tests for startup refresh behavior (simulate existing DB row and mock Kaiten response) — `backend/src/test/java/com/kaiten/mcp/kaiten/init/KaitenStartupRunnerTest.java`

### Implementation for User Story 2

- [ ] T024 [US2] Implement startup runner `KaitenStartupRunner` that checks repository `find()` and, if present, calls `KaitenClient` to refresh profile and update DB — `backend/src/main/java/com/kaiten/mcp/kaiten/init/KaitenStartupRunner.java`
- [ ] T025 [US2] Implement `GET /api/kaiten/profile` endpoint in `KaitenController` that returns stored profile or 404 if not connected — `backend/src/main/java/com/kaiten/mcp/kaiten/controller/KaitenController.java`
- [ ] T026 [US2] Frontend: on app load, query `/api/kaiten/profile` and display profile if exists (update `ui/src/main.tsx` or `ui/src/pages/KaitenAuth.tsx`) — `ui/src/pages/KaitenAuth.tsx`, `ui/src/main.tsx`
- [ ] T027 [US2] Add unit tests for `KaitenStartupRunner` and `GET /api/kaiten/profile` behavior — `backend/src/test/java/com/kaiten/mcp/kaiten/init/KaitenStartupRunnerTest.java`, `backend/src/test/java/com/kaiten/mcp/kaiten/controller/KaitenProfileTest.java`

**Checkpoint**: After T024–T027, autoload/refresh behavior should be testable and functional.

---

## Phase 5: User Story 3 - Сброс авторизации (Priority: P2)

**Goal**: Provide a reset/disconnect action to delete saved token/profile and return UI to not-connected state

**Independent Test**: POST `/api/kaiten/disconnect` and verify DB row is deleted and frontend shows connection UI.

### Tests for User Story 3

- [ ] T028 [P] [US3] Add unit tests for repository `delete()` and controller disconnect behavior — `backend/src/test/java/com/kaiten/mcp/kaiten/controller/KaitenDisconnectTest.java`

### Implementation for User Story 3

- [ ] T029 [US3] Implement `POST /api/kaiten/disconnect` endpoint in `KaitenController` that deletes credentials (returns 204 or 404) — `backend/src/main/java/com/kaiten/mcp/kaiten/controller/KaitenController.java`
- [ ] T030 [US3] Frontend: Add `Reset` button behavior to call `disconnect` and clear profile UI state — `ui/src/pages/KaitenAuth.tsx`, `ui/src/services/kaiten.ts`
- [ ] T031 [US3] Add frontend test verifying reset button removes UI profile and blocks profile calls — `ui/tests/KaitenAuthReset.test.tsx`

**Checkpoint**: After T029–T031, disconnect flow should be fully functional and independently testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, localization, logging, and small improvements

- [ ] T032 [P] Update `docs/quickstart.md` and `specs/001-kaiten-auth/quickstart.md` with exact commands and examples for connecting and resetting — `docs/quickstart.md`, `specs/001-kaiten-auth/quickstart.md`
- [ ] T033 [P] Ensure all user-facing messages are in Russian (backend and frontend) and include localization keys where appropriate — `backend/src/main/resources/messages.properties`, `ui/src/i18n/` (if present) or inline Russian strings
- [ ] T034 [P] Add logging for key events (connect success/fail, disconnect, DB init errors) — `backend/src/main/java/com/kaiten/mcp/kaiten/*`
- [ ] T035 [P] Add smoke tests to `tests/smoke` and update CI configuration to run them locally — `tests/smoke/smoke-kaiten.sh`, `.github/workflows/*`
- [ ] T036 [P] Code cleanup and formatting (run `mvn -q -DskipTests package` and `npm run lint`/`npm run format`) — repo-wide
- [ ] T037 [P] Security note: add issue/template documenting potential encryption/keystore improvement for future work — `specs/001-kaiten-auth/research.md` or `docs/security.md`

---

## Dependencies & Execution Order

- Phase 1 (Setup) tasks can be executed in parallel (T001–T005) ✅
- Phase 2 (Foundational) **must** complete before user story implementation begins (T006–T013) ⚠️
- User Story phases (Phase 3–5) can proceed in priority order or in parallel once foundation is ready
- Polish tasks can run after each story completes or in parallel when applicable

## Parallel opportunities

- Tasks marked with `[P]` are safe to run in parallel (independent files and low coupling)
- Examples:
  - Add dependencies (T001) can run while creating frontend skeleton (T004)
  - Unit tests (T009/T011/T013) can be implemented in parallel by different engineers

## Implementation Strategy

1. Follow MVP approach: implement Phase 1 → Phase 2 → User Story 1 (T016–T022) and validate independently.
2. After US1 passes, implement US2 (autoload/refresh) and US3 (disconnect) in separate PRs.
3. Each PR should be small and self-contained (one PR = one commit per repo governance). Use `git commit --amend` for post-PR fixes to keep single-commit rule.

---

## Estimates & Suggested PR Breakdown (suggested)

- PR 1 (Setup + dependencies + quickstart): T001, T002, T003, T005 — **0.5 - 1d**
- PR 2 (DB init + model + repository + repo tests): T006, T007, T008, T009 — **1 - 2d**
- PR 3 (Client + service + unit tests): T010, T011, T012, T013 — **1 - 2d**
- PR 4 (Controller + connect endpoint + DTOs + tests): T014, T015, T016, T017, T018 — **1 - 2d**
- PR 5 (Frontend component + service + tests): T019, T020, T021 — **1 - 2d**
- PR 6 (Startup refresh + profile endpoint + tests): T023, T024, T025, T026, T027 — **1 - 1.5d**
- PR 7 (Disconnect + UI reset + tests): T028, T029, T030, T031 — **0.5 - 1d**
- PR 8 (Polish and smoke tests): T032–T037 — **0.5 - 1d**

**Total**: ~7–10 working days (MVP + tests + polish). Split into PR-sized chunks as suggested.

---

**File**: `specs/001-kaiten-auth/tasks.md`
**Generated**: 2026-02-01
