# quickstart.md — 001-init-project-structure

## Цель
Краткое руководство для быстрого старта разработки и для объединённой сборки самодостаточной поставки.

## Требования

**Разработка и сборка:**
- Java 21 (JDK)
- Maven 3.8+
- Node.js 16+ и npm 8+
- bash (Unix/Linux/macOS) или Windows Command Prompt

**Выполнение:**
- Java 21 или встроенная JRE (в полной сборке)

## Development

### Backend (dev)
1. Перейти в `backend/`.
2. Запустить:

```bash
mvn -f backend/pom.xml spring-boot:run
```

Сервер доступен по адресу `http://localhost:8080`.

### UI (dev)
1. Перейти в `ui/`.
2. Установить зависимости и запустить dev сервер:

```bash
npm install
npm run dev
```

По-умолчанию Vite запускает UI на `http://localhost:5173`.

### Оба компонента одновременно (dev)

**Терминал 1 — Backend:**
```bash
cd backend
mvn spring-boot:run
```

**Терминал 2 — UI:**
```bash
cd ui
npm install   # если первый раз
npm run dev
```

Будут доступны:
- Backend API: `http://localhost:8080/hello/{name}`
- UI dev server: `http://localhost:5173`

## Unified build (production package)

В корне репозитория выполнить:

```bash
./build.sh
```

Что делает `build.sh`:
- Проверяет зависимости (Java 21, Maven, npm)
- Билдит UI: `npm install` → `npm test` → `npm run build`
- Билдит бэкенд: `mvn -f backend/pom.xml clean package`
- Загружает JRE (опционально, флаг `--no-jre`)
- Собирает структуру `out/kaiten-mcp/` с подпапками: `bin/`, `jre/`, `lib/`, `static/`, `config/`
- Копирует артефакты (JAR, UI assets, скрипты запуска)
- Валидирует пакет (`integration-check.sh`)
- Создаёт архив `out/kaiten-mcp.zip`

**Варианты сборки:**

```bash
./build.sh                    # Полная сборка с JRE (~200MB)
./build.sh --no-jre          # Без JRE (~19MB)
./build.sh --skip-ui         # Только backend
./build.sh --skip-backend    # Только UI
```

## Запуск распакованной поставки

### Linux/macOS/WSL:

```bash
cd out/kaiten-mcp
./bin/start.sh              # Запустить сервер
# Открыть браузер на http://localhost:8080

./bin/stop.sh               # Остановить сервер
```

### Windows:

```powershell
cd out\kaiten-mcp
start.bat                   # Запустить сервер
# Открыть браузер на http://localhost:8080

stop.bat                    # Остановить сервер
```

**Как работают скрипты:**

**start.sh/start.bat:**
- Проверяет Java
- Запускает JVM с JAR в фоновом режиме
- Сохраняет PID процесса в `.server.pid`
- Ждёт 2 сек, проверяет доступность `/hello/test`
- По успеху пытается открыть браузер (macOS/Linux/Windows)

**stop.sh/stop.bat:**
- Читает PID из `.server.pid`
- Отправляет graceful SIGTERM сигнал
- Ждёт 10 сек на завершение
- При необходимости force kill (SIGKILL)
- Удаляет PID файл

## Smoke tests

В `tests/smoke/` находятся скрипты валидации:

```bash
./tests/smoke/smoke-package.sh      # Тест упакованного приложения
./tests/smoke/smoke-backend.sh      # Тест backend API (stub)
./tests/smoke/smoke-ui-build.sh     # Проверка UI артефактов
```

**smoke-package.sh** (основной):
- Распаковывает `out/kaiten-mcp.zip`
- Запускает сервер из пакета
- Тестирует endpoints:
  - `GET /hello/World` → проверяет ответ
  - `GET /hello/Иван` → проверяет кириллицу
  - `GET /hello` → проверяет валидацию (HTTP 400)
  - `GET /hello/<300-char-name>` → проверяет max length (HTTP 400)
- Тестирует доступность UI
- Останавливает сервер gracefully

**smoke-ui-build.sh**:
- Проверяет существование `dist/`
- Валидирует `index.html`
- Ищет JavaScript assets
- Проверяет CSS (bundled или отдельный)
- Выводит размеры артефактов

## Unit тесты

```bash
# Backend
cd backend && mvn test

# UI
cd ui && npm test
```

## Troubleshooting

### Backend не запускается

**Ошибка:** `java: command not found`
```bash
# Проверить версию Java
java -version                    # Должна быть 21+

# Если Java не установлена:
# Загрузить с https://adoptium.net
```

**Ошибка:** `Address already in use: :8080`
```bash
# Проверить, что на порте 8080
lsof -i :8080
# Либо изменить порт в backend/src/main/resources/application.properties
```

### UI не загружается

**Проблема:** Browser console shows errors
```bash
# Убедиться, что backend запущен
curl http://localhost:8080/hello/test

# Проверить, что static assets доступны
ls out/kaiten-mcp/static/
```

### Сборка не удается

**Ошибка:** Maven build failure
```bash
cd backend && mvn clean     # Очистить старые артефакты
cd backend && mvn install   # Переустановить зависимости
```

**Ошибка:** npm install failed
```bash
cd ui && npm cache clean --force
cd ui && npm install
```

## CI/CD

GitHub Actions workflows запускаются автоматически:

- **ci-backend.yml**: Unit + integration тесты
- **ci-ui.yml**: Tests + build + smoke validation
- **ci-smoke.yml**: Smoke tests (daily или manual)

Все workflows создают artifacts для inspection.

## Примечания

- Документация по установке JRE для CI описана в `scripts/fetch-jre.sh`
- Все пользовательские/инструкционные тексты — на русском языке (requirement)
- Полная документация: см. [README.md](../../README.md), [backend/README.md](../../backend/README.md), [ui/README.md](../../ui/README.md)
- Архитектурная диаграмма: [docs/architecture.puml](../../docs/architecture.puml)