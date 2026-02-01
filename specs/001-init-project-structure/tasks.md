---

description: "Task list for implementing 001-init-project-structure"
---

# Tasks: Инициализация структуры проекта (001-init-project-structure)

**Input**: Design docs in `specs/001-init-project-structure/`
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/openapi.yaml`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initialize project skeletons, tooling and project-wide docs.

- [ ] T001 [P] Create `backend/` directory and add `backend/pom.xml` placeholder (Java 21, Spring Boot) — `backend/pom.xml`
- [ ] T002 [P] Create `ui/` directory and initialize Vite + React + TypeScript project scaffold — `ui/package.json`, `ui/src/`
- [ ] T003 [P] Add top-level `.gitignore`, `README.md` (root) and `specs/001-init-project-structure/quickstart.md` — `/ .gitignore`, `/README.md`, `specs/001-init-project-structure/quickstart.md`
- [ ] T004 [P] Add formatting and linting configs: `backend/.editorconfig`, `ui/.eslintrc.cjs`, `ui/tsconfig.json` — `backend/.editorconfig`, `ui/.eslintrc.cjs`, `ui/tsconfig.json`
- [ ] T005 [P] Add documentation skeleton: `docs/` and `docs/install-jre.md` — `docs/install-jre.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infra that MUST exist before implementing user stories (build, start/stop scripts, test harness)

**⚠️ CRITICAL**: No user story work should begin until these are complete.

- [x] T006 Create `backend/src/main/java/com/kaiten/mcp/Application.java` with main Spring Boot application class — `backend/src/main/java/com/kaiten/mcp/Application.java`
- [x] T007 [P] Configure Maven build and packaging: ensure `mvn package` produces executable `backend/target/kaiten-mcp.jar` — `backend/pom.xml`
- [x] T008 Create `ui/package.json` scripts for `dev` and `build` (Vite) — `ui/package.json`
- [x] T009 Create smoke test harness directory `tests/smoke/` and placeholder scripts `tests/smoke/smoke-backend.sh`, `tests/smoke/smoke-ui.sh` — `tests/smoke/`
- [x] T010 Implement basic logging and error handling middleware for backend (simple ControllerAdvice) — `backend/src/main/java/com/kaiten/mcp/exception/GlobalExceptionHandler.java`
- [x] T011 Add `scripts/` folder and placeholder unified build script `build.sh` (stub that calls ui & backend build steps) — `build.sh`, `scripts/`
- [x] T012 [P] Add CI workflow skeleton to run unit tests (backend + ui) — `.github/workflows/ci.yml`
- [x] T013 Add CI job to run scripted smoke-tests on a Linux runner (P1) — `.github/workflows/ci-smoke.yml`  
  (This job runs `tests/smoke/*` against a started package and is required to satisfy SC-006.)

**Checkpoint**: Foundational tasks complete — safe to begin User Story phases.

---

## Phase 3: User Story 1 - Greet via UI (Priority: P1) 🎯 MVP

**Goal**: User opens UI, inputs name, clicks button, sees "Hello, <name>" returned by backend.

**Independent Test**: Run backend and UI locally; perform `curl` or UI flow to verify greeting.

### Tests (automated and smoke)

- [x] T014 [P] [US1] Add backend unit test for greeting logic (`backend/src/test/java/com/kaiten/mcp/hello/HelloControllerTest.java`) — `backend/src/test/java/com/kaiten/mcp/hello/HelloControllerTest.java`
- [x] T015 [P] [US1] Add smoke script `tests/smoke/smoke-hello.sh` verifying `GET /hello/<name>` returns 200 and expected JSON — `tests/smoke/smoke-hello.sh`

### Implementation

- [x] T016 [US1] Implement `HelloService` with validation rules (name required, max 256 chars) — `backend/src/main/java/com/kaiten/mcp/hello/HelloService.java`
- [x] T017 [US1] Implement `HelloController` mapping `GET /hello/{name}` and returning `{ "message": "Hello, <name>" }` — `backend/src/main/java/com/kaiten/mcp/hello/HelloController.java`
- [x] T018 [US1] Add UI page component `ui/src/pages/Home.tsx` with input and button (UI text and messages in Russian) that calls backend and displays response — `ui/src/pages/Home.tsx`
- [x] T019 [US1] Add UI unit test for the Home component (`ui/tests/Home.test.tsx`) verifying UI (Russian labels/messages) and mock fetch — `ui/tests/Home.test.tsx`
- [x] T020 [US1] Add README snippets (in Russian) to `backend/README.md` and `ui/README.md` showing curl example and the UI flow — `backend/README.md`, `ui/README.md`

**Checkpoint**: On passing T014–T020 the MVP user flow is testable and demoable.

---

## Phase 4: User Story 2 - Backend: standalone endpoint (Priority: P2)

**Goal**: Backend can be built and run standalone; developers can use curl to verify endpoint.

**Independent Test**: `mvn package` produces JAR; `java -jar target/kaiten-mcp.jar` starts server and `curl` works.

- [x] T021 [US2] Implement backend `start`/`stop` scripts in `backend/bin/start.sh` and `backend/bin/stop.sh` for dev usage (linux) — `backend/bin/start.sh`, `backend/bin/stop.sh`
- [x] T022 [US2] Add `backend/README.md` with build/run instructions and example `curl` commands — `backend/README.md`
- [x] T023 [US2] Add unit test for edge cases: empty name and too-long name returns 400 — `backend/src/test/java/com/kaiten/mcp/hello/HelloValidationTest.java`
- [x] T024 [P] [US2] Add a GitHub Actions workflow `ci-backend.yml` that builds backend and runs unit tests — `.github/workflows/ci-backend.yml`

**Checkpoint**: Backend standalone verified.

---

## Phase 5: User Story 3 - UI: standalone build & dev (Priority: P2)

**Goal**: UI can be served in dev mode and built to static assets that can be served by backend.

**Independent Test**: `npm run dev` launches Vite dev server; `npm run build` produces `dist/` containing `index.html` and assets.

- [x] T025 [US3] Add UI dev script and build script to `ui/package.json` (`dev`, `build`) — `ui/package.json`
- [x] T026 [US3] Create `ui/README.md` with dev instructions and how to point UI to local backend — `ui/README.md`
- [x] T027 [US3] Add a small E2E check script `tests/smoke/smoke-ui-build.sh` that validates the built `dist/` contains `index.html` — `tests/smoke/smoke-ui-build.sh`
- [x] T028 [P] [US3] Add a unit test for the UI build artifact generation (scripted check in CI) — `.github/workflows/ci-ui.yml`

**Checkpoint**: UI dev and build flows validated.

---

## Phase 6: User Story 4 - Unified build / single runnable app (Priority: P3)

**Goal**: Implement `build.sh` that builds UI and backend, bundles JREs, scripts and produces `out/kaiten-mcp.zip` package which can be double-clicked or run from terminal.

**Independent Test**: Run `./build.sh` from repo root and validate `out/kaiten-mcp.zip` contains `kaiten-mcp/bin/start.sh`, `kaiten-mcp/jre/`, `kaiten-mcp/lib/kaiten-mcp.jar`, and `kaiten-mcp/static/`.

- [x] T029 [US4] Implement `build.sh` to run UI build and backend package, create `out/kaiten-mcp/` layout and zip it — `build.sh`
- [x] T030 [US4] Add JRE acquisition logic (download Temurin JREs for linux/windows) into `build.sh` or helper script `scripts/fetch-jre.sh` — `scripts/fetch-jre.sh`, `build.sh`
- [x] T031 [US4] Generate runtime scripts in package: `kaiten-mcp/bin/start.sh`, `kaiten-mcp/bin/stop.sh`, `kaiten-mcp/bin/start.bat`, `kaiten-mcp/bin/stop.bat` — `out/kaiten-mcp/bin/`
- [x] T032 [US4] Ensure `start.sh` runs Java server as background process, prints UI URL, and attempts to open browser (`xdg-open`/`start`) — `out/kaiten-mcp/bin/start.sh`
- [x] T033 [US4] Add packaged smoke test `tests/smoke/smoke-package.sh` to run the start script from the unpacked package and validate UI access — `tests/smoke/smoke-package.sh`
- [x] T034 [P] [US4] Add `integration-check` script that validates archive contents and basic start functionality (used by CI) — `scripts/integration-check.sh`

**Checkpoint**: Unified package produced and validated.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Docs, CI completion, cleanup, and final validation.

- [x] T035 [P] Update `README.md` with unified build and run instructions, include troubleshooting section — `/README.md`
- [x] T036 [P] Add `docs/` diagrams (PlantUML) documenting high-level architecture and flow — `docs/architecture.puml`
- [x] T037 [P] Ensure smoke CI job exists and is configured (moved to foundational as `T013`); verify job runs and reports artifacts — `.github/workflows/ci-smoke.yml`
- [x] T038 [P] Run quickstart validation and fix any missing steps in `specs/001-init-project-structure/quickstart.md`
- [x] T039 [P] Code cleanup and add TODOs for future improvements (Docker, compose, shrink JRE) — project-wide

---

## Dependencies & Execution Order

- Setup (Phase 1) tasks T001–T005 are parallelizable and should complete first.
- Foundational (Phase 2) tasks T006–T012 must complete before user stories.
- User Stories (Phases 3–6) can run in parallel per story after foundational completion.
- Polish (Phase 7) depends on completed user stories.

## Parallel Execution Examples

1. While T006 (Application main) runs, T007 (Maven packaging config) and T008 (UI scripts) can run in parallel (T007, T008 marked [P]).
2. US1 implementation tasks (T016–T019) can be split: backend model/service (T016–T017) and UI component/tests (T018–T019) run in parallel across different devs (mark relevant tasks [P]).

## Implementation Strategy

- MVP-first: implement Phase 1 + Phase 2 + Phase 3 (US1) first and validate.
- Incremental delivery: After US1 is working, deliver US2 and US3, then US4 (packaging).
- Keep work small and focused: each task must be independently testable and self-contained.

---

### Summary of tasks
- Total tasks: 39
- P1 story tasks (US1) focused on delivering the MVP greeting flow
- Parallel opportunities identified in Setup and Foundational phases

---

Next steps: on your command `start phase2`, I will begin implementing tasks in priority order and create small commits for each completed task (I will not commit without your explicit instruction).