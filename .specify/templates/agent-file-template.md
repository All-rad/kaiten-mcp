# [PROJECT NAME] Development Guidelines

Auto-generated from all feature plans. Last updated: [DATE]

## Active Technologies

[EXTRACTED FROM ALL PLAN.MD FILES]

## Project Structure

```text
[ACTUAL STRUCTURE FROM PLANS]
```

## Commands

[ONLY COMMANDS FOR ACTIVE TECHNOLOGIES]

## Code Style

[LANGUAGE-SPECIFIC, ONLY FOR LANGUAGES IN USE]

## Recent Changes

[LAST 3 FEATURES AND WHAT THEY ADDED]

<!-- MANUAL ADDITIONS START -->

## Development Process

- **Pull Request policy**: **MUST** — Каждый Pull Request (PR) ДОЛЖЕН содержать ровно один коммит. Если требуются дополнительные фиксы после открытия PR, вносите их через `git commit --amend` или интерактивный `git rebase`, чтобы PR остался единым коммитом до слияния. Commit messages **MUST** быть на английском языке.

- **Local development environment**: Use `sdkman` for Java and `nvm` for Node. Before starting development or running tests, verify local tool versions and align them with the project's required versions (documented in `docs/quickstart.md` or feature `quickstart.md`).

<!-- MANUAL ADDITIONS END -->
