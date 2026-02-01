# research.md — 001-init-project-structure

Дата: 2026-02-01

## Решения и обоснования

1) Backend build tool
- Decision: Использовать **Maven (Apache Maven)** с Spring Boot Maven Plugin.
- Rationale: Maven — широко используемый стандарт для Spring Boot проектов; простая конфигурация для сборки исполняемого JAR и удобная интеграция в CI. Простота важнее (Конституция: Скорость и Простота).
- Alternatives: Gradle (быстрее в некоторых сценариях), но добавляет семантику и сложность сборки.

2) UI tool
- Decision: Использовать **Vite + React + TypeScript**.
- Rationale: Vite обеспечивает быстрый dev сервер и быстрые сборки, простота конфигурации и широкая поддержка React+TS.
- Alternatives: Create React App (более тяжеловесный), Next.js (SSR — лишнее для данной задачи).

3) Unified packaging / JRE inclusion
- Decision: `build.sh` будет загружать (при необходимости) и помещать в `out/kaiten-mcp/jre/` две платформенные версии JRE (linux и windows) из **Eclipse Temurin (Adoptium)** соответствующей Java 21. Скрипт соберёт backend JAR, UI статические файлы, добавит запускающие скрипты `start.sh`/`stop.sh` и `start.bat`/`stop.bat` и упакует всё в `out/kaiten-mcp.zip`.
- Rationale: jlink/jpackage варианты дают более тонкую настройку, но добавляют сложность; простое скачивание проверенных сборок JRE обеспечивает предсказуемость и быструю реализацию (соответствует принципу Скорости и Простоты).
- Alternatives: jlink (optimize size, but requires больше конфигурации), требовать наличия JRE у пользователя (упрощает поставку, но противоречит требованию "включает JRE").

4) Smoke / тесты
- Decision: Для соответствия Конституции (unit-only) — реализовать **unit-тесты** (JUnit 5) для backend и UI компоненты; для проверки P1/P2 добавить **скриптовые смоук-тесты** (bash scripts / curl) в `tests/smoke/` которые не запускают Spring Context и выполняют реальные HTTP-запросы к запущенному приложению (manual/CI job). Это удовлетворяет требование "минимальный набор автоматизированных тестов" без написания медленных интеграционных тестов, и даёт быструю обратную связь.
- Rationale: Unit-тесты следуют Конституции по скорости; скриптовые smoke-тесты обеспечивают необходимое интеграционное покрытие без внедрения тестового фреймворка, и легко исполняются в CI.
- Alternatives: Полноценные интеграционные тесты на базе Spring Boot Test (НЕ рекомендуется — противоречит Конституции).

5) Packaging scripts behavior
- Decision: `build.sh` выполняет: UI build (vite build -> dist), backend build (mvn package -> app.jar), создание `out/kaiten-mcp/` структуры, копирование `jre/`, генерация `start/stop` скриптов, упаковка ZIP. `start.sh` запускает backend Java в фоновом режиме (nohup/daemon) и по возможности открывает `http://localhost:8080` в браузере (xdg-open/windows start). Скрипты должны быть безопасными и idempotent по запуску/остановке процесса.
- Rationale: Требование пользователя на самодостаточную поставку.

## Remaining unknowns / risks
- Network access required in `build.sh` to download JREs — CI environments may restrict downloads.
- Windows testing on CI requires runner with Windows; smoke-tests for Windows may require separate verification.

---

В результате все исходные `NEEDS CLARIFICATION` разрешены; дальнейший шаг — Phase 1 (data-model, contracts, quickstart) и подготовка skeleton кода и скриптов.