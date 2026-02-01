# Quickstart — Kaiten-MCP

Краткое руководство по настройке локальной среды и версиям инструментов.

## Требуемые версии (Project requirements)
- Java: 21 (JDK)
- Maven: 3.8+
- Node.js: 16+
- npm: 8+

> Версии должны поддерживаться через `sdkman` (Java) и `nvm` (Node.js).

## Проверка среды
Перед началом разработки выполните:

```bash
# Быстрая проверка
./scripts/check-env.sh
```

Если версии не совпадают, используйте `sdkman`/`nvm` для переключения:

```bash
# Java (sdkman)
sdk install java 21.0.0-open
sdk use java 21.0.0-open

# Node.js (nvm)
nvm install 16
nvm use 16
```

## Dev commands (summary)
- Backend: `cd backend && mvn spring-boot:run`
- UI: `cd ui && npm install && npm run dev`
- Unified build: `./build.sh`

Подробности: `specs/001-init-project-structure/quickstart.md`