# Implementation Plan: 001-init-project-structure

**Branch**: `001-init-project-structure` | **Date**: 2026-02-01 | **Spec**: `specs/001-init-project-structure/spec.md`
**Input**: Feature specification from `specs/001-init-project-structure/spec.md`

---

## Short plan (3–5 steps) 🚀
1. Initialize skeletons: create `backend/` (Maven, Java 21 + Spring Boot) and `ui/` (Vite + React + TypeScript) projects and basic docs. ✅
2. Implement foundational tooling: CI for unit tests, smoke test harness, `build.sh` stub, and start/stop scripts. ✅
3. Deliver MVP greeting flow (US1): backend `GET /hello/{name}`, validation & unit tests, UI page with Russian labels and unit test, smoke script. ✅
4. Harden and package (US2–US4): backend standalone scripts, UI build validation, `build.sh` packaging with JREs, packaged smoke-tests and CI smoke job. ✅
5. Polish docs, PlantUML diagrams, and CI completion; create PR for review. ✅

> This short plan follows the Constitution: prioritize speed & simplicity, documentation in Russian, code identifiers in English, and unit-tests plus scripted smoke tests.

---

## Technical Context (concise)
- Languages: **Java 21** (backend), **TypeScript 5.x / ES2023** (UI)
- Frameworks: **Spring Boot 3.5.x** (backend), **React + Vite + TypeScript** (UI)
- DB: **SQLite** available (not required for MVP)
- Testing: **JUnit 5 + Mockito** (backend unit tests), **Jest + React Testing Library** (UI unit tests); **scripted smoke-tests** (curl/bash) for integration-level checks without starting Spring Context.
- Packaging: `build.sh` produces `out/kaiten-mcp/` + `out/kaiten-mcp.zip` and includes platform JREs (Eclipse Temurin/Adoptium) for Linux & Windows.
- Target: Desktop demo & developer experience on Linux/Windows.

---

## Constitution Check (re-evaluated)
- Language rules: Docs and UI strings — **Russian**; code & API — **English**. ✅
- Testing rules: **Unit tests only** for automated tests + **scripted smoke-tests** that do not initialize Spring Context — justified and PASS. ✅
- Packaging rules: ZIP with included JREs and runnable scripts — designed and PASS. ✅
- Gate status: **PASSED**. No unresolved NEEDS CLARIFICATION remain.

---

## Phase outputs (current)
- Phase 0: `research.md` — decisions recorded (tooling, packaging, tests). ✅
- Phase 1: `data-model.md`, `contracts/openapi.yaml`, `quickstart.md` — design artifacts created and consistent with Constitution. ✅
- Phase 2: `tasks.md` — implementation tasks (blocking + user stories) exists and prioritized. ✅

---

## Phase 2 (Implementation) — Execution Plan (high level)
Priority order: Foundational (P) → US1 (P1) → US2/US3 (P2) → Packaging (P3) → Polish.

1. Foundational (parallelizable):
   - Create skeletons (`backend/`, `ui/`) and basic docs & linting.
   - Implement CI jobs for unit tests and stub smoke job.
   - Add smoke-test harness `tests/smoke/` and `build.sh` stub.
2. MVP (US1 - P1):
   - Implement backend `HelloService` and `HelloController` with validation (name required, max 256 chars; missing -> 400 `{"error":"name missing"}`).
   - Add JUnit tests for happy path and validation edge cases.
   - Implement UI `Home` page (input, button, Russian labels), tests (Jest + RTL), and smoke script `tests/smoke/smoke-hello.sh`.
3. Standalone backend & UI (US2/US3 - P2):
   - Finish backend dev scripts, ensure `mvn package` produces executable JAR, add README snippets.
   - Ensure UI dev/build scripts, create `ui/README.md`, and add checks for built `dist/`.
4. Packaging & distribution (US4 - P3):
   - Implement `build.sh` to assemble artifacts, fetch Temurin JREs, generate `out/kaiten-mcp.zip` and `kaiten-mcp/bin/*` scripts.
   - Add packaged smoke tests verifying start/stop and UI accessibility.
5. Polish & CI finalization:
   - Add PlantUML diagrams, finalize `README.md` and quickstart steps, verify smoke CI and artifact content.

---

## Risks & Mitigations
- JRE downloads in CI might be blocked → add cached artifacts or use CI-provided JREs; document manual steps in `docs/install-jre.md`.
- Windows-specific checks need Windows runner for full validation → verify basic packaging on Linux CI and request manual Windows verification if no runner available.

---

## Deliverables (to produce before PR)
- `backend/` skeleton with Spring Boot app and `Hello` endpoint + unit tests.
- `ui/` skeleton with React + Vite + `Home` page and unit tests.
- `build.sh` producing `out/kaiten-mcp.zip` with JREs and start/stop scripts.
- `tests/smoke/` scripts covering P1/P2/P4 scenarios; CI smoke job for Linux runner.
- Updated documentation: `README.md`, `docs/install-jre.md`, `specs/001-init-project-structure/quickstart.md`.

---

## Next actions (explicit)
- Execute Phase 2 tasks from `specs/001-init-project-structure/tasks.md` in priority order, starting with Foundational tasks (T001–T005). Run tasks in small commits and open PR `001-init-project-structure` when MVP (US1) passes smoke-tests.
- Update agent context (copilot) with final decisions and technologies (done: `.specify/scripts/bash/update-agent-context.sh copilot`).

---

**Branch to use for work:** `001-init-project-structure`
**Plan file:** `specs/001-init-project-structure/plan.md`

*If you approve this plan, say `start phase2` and I will begin implementing tasks in priority order (I will create small commits and run relevant smoke-tests as tasks complete).*


## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Java 21 (backend), TypeScript 5.x / ES2023 (UI)
**Primary Dependencies**: Spring Boot 3.5.x, SQLite (backend); React + Vite + TypeScript (UI)
**Storage**: SQLite (available but not used; no persistent storage required for MVP)
**Testing**: JUnit 5 + Mockito (backend unit tests), Jest + React Testing Library (UI unit tests); smoke tests implemented as shell scripts (curl)
**Target Platform**: Linux and Windows (desktop), dev on Linux/macOS
**Project Type**: Web application (separate `backend/` and `ui/` projects)
**Performance Goals**: None for initial MVP (focus on simplicity)
**Constraints**: Package must be distributable as ZIP including JREs for Windows/Linux, must be runnable by double-click or from terminal
**Scale/Scope**: MVP only (single-server local demo), no multi-node or high-load requirements

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Language rules: Documentation and user-facing text will be in **Russian** (spec, README, quickstart), code identifiers and API endpoints in **English** — PASS.
- Testing rules: Constitution requires unit-tests-only policy. Spec originally requested "integration/smoke" tests (FR-006). Resolved by implementing unit tests + **scripted smoke tests** (shell/curl scripts) that do not initialize Spring Context — PASS (justified).
- Packaging rules: Must support ZIP with JRE for Windows and Linux — implemented in research decisions and `build.sh` design — PASS.
- Any deviations: No violations remaining. If future implementation requires full Spring-based integration tests, add Complexity Tracking entry and justification.

GATE RESULT: PASSED

## Project Structure

### Phase outputs (current)

- Phase 0: `research.md` — decisions on tooling, packaging and tests.
- Phase 1: `data-model.md`, `contracts/openapi.yaml`, `quickstart.md` — design artifacts created.
- Phase 2 (planned): `tasks.md` — implementation tasks (created in this phase as plan for work).

### Next steps (Phase 2 planning)

- Implement tasks from `tasks.md` (backend skeleton, ui skeleton, build.sh, tests, docs).
- Add CI jobs: unit tests (backend + ui) AND a smoke-tests job running scripted smoke-tests on a Linux runner (this smoke CI job is considered **P1** for acceptance and must run before marking SC-006 satisfied).
- After Phase 2, open a PR from `001-init-project-structure` with implemented artifacts and README instructions for verification.


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

```text
backend/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/       # package: com.kaiten.mcp.hello
│   │   └── resources/
│   └── test/           # unit tests (JUnit 5)
├── README.md

ui/
├── package.json
├── src/
│   ├── components/
│   └── pages/
├── public/
└── tests/              # unit tests (Jest)

out/                   # generated by build.sh
├── kaiten-mcp/
│   ├── bin/            # start/stop scripts
│   ├── jre/            # platform-specific JREs (linux/, windows/)
│   ├── lib/            # backend jar(s)
│   └── static/         # UI static files
└── kaiten-mcp.zip
```

**Structure Decision**: Разделить проект на `backend/` (Java 21 + Spring Boot) и `ui/` (React + TypeScript + Vite). `build.sh` в корне управляет объединённой сборкой и упаковкой в `out/kaiten-mcp.zip`. Эта структура соответствует Конституции (разделение concerns, документация на русском, технические идентификаторы на английском).

## Complexity Tracking

Нет нарушений Конституции, требующих оправдания. Любые будущие отклонения (например, необходимость полноценных Spring-интеграционных тестов) будут зафиксированы в этой таблице с обоснованием и альтернативами.
