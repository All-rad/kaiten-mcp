# Kaiten MCP - Multi-Component Project

English | [Русский](#русский)

> A lightweight multi-component project starter with a Java Spring Boot backend, React UI, and unified packaging for cross-platform deployment.

## Quick Start

### Build Everything

```bash
./build.sh
```

This creates a complete distribution package:
- **Backend**: Java Spring Boot REST service (port 8080)
- **UI**: React web interface (served from backend)
- **Package**: Unified `kaiten-mcp.zip` with all components and scripts

### Run the Package

```bash
cd out/kaiten-mcp
./bin/start.sh          # Unix/Linux/macOS
# or
./bin/start.bat         # Windows
```

Access the application at: **http://localhost:8080**

### Stop the Server

```bash
cd out/kaiten-mcp
./bin/stop.sh           # Unix/Linux/macOS
# or
./bin/stop.bat          # Windows
```

## Project Structure

```
kaiten-mcp/
├── backend/                          # Java Spring Boot service
│   ├── bin/                         # Runtime scripts (start.sh, stop.sh)
│   ├── src/main/java/               # Java source code
│   ├── src/test/java/               # Unit tests
│   ├── pom.xml                      # Maven configuration
│   └── README.md                    # Backend documentation
├── ui/                              # React TypeScript application
│   ├── src/                         # React components and styles
│   ├── tests/                       # Component tests
│   ├── vite.config.ts               # Vite build configuration
│   ├── package.json                 # npm scripts
│   └── README.md                    # UI documentation
├── scripts/                         # Build utilities
│   ├── fetch-jre.sh                # Java Runtime Environment setup
│   └── integration-check.sh         # Package validation
├── tests/smoke/                     # Smoke tests
│   ├── smoke-package.sh            # Package functionality test
│   ├── smoke-backend.sh            # Backend API test
│   └── smoke-ui-build.sh           # UI build verification
├── docs/                            # Documentation
│   └── architecture.puml            # System architecture diagram
├── out/                             # Build output
│   ├── kaiten-mcp/                 # Assembled package directory
│   └── kaiten-mcp.zip              # Distribution archive
├── build.sh                         # Unified build orchestration
└── README.md                        # This file
```

## Development Setup

### Backend

See [backend/README.md](backend/README.md) for:
- Development server startup
- API endpoint documentation
- Validation rules
- Troubleshooting

**Quick start:**
```bash
cd backend
mvn spring-boot:run
# or
./bin/start.sh
```

### UI

See [ui/README.md](ui/README.md) for:
- Development environment setup
- Backend integration options
- Build instructions
- Testing guide

**Quick start:**
```bash
cd ui
npm install
npm run dev
# or test production build
npm run build
npm run preview
```

## Build Modes

### Full Build (with JRE)
```bash
./build.sh
```
Creates a complete standalone package (~200MB with JRE).

### Fast Build (without JRE)
```bash
./build.sh --no-jre
```
Creates distribution without bundled Java (~19MB). Requires Java 21 on target system.

### Skip Components
```bash
./build.sh --skip-ui               # Build backend only
./build.sh --skip-backend          # Build UI only
./build.sh --skip-ui --no-jre      # Backend without JRE
```

## Testing

### Unit Tests
```bash
cd backend && mvn test              # Backend unit tests
cd ui && npm test                   # UI component tests
```

### Smoke Tests
```bash
./tests/smoke/smoke-package.sh      # Test packaged application
./tests/smoke/smoke-backend.sh      # Test backend API
./tests/smoke/smoke-ui-build.sh     # Verify UI artifacts
```

### Integration Test
```bash
./scripts/integration-check.sh out/kaiten-mcp.zip
```

## API Reference

### Greeting Endpoint

```bash
GET /hello/{name}
```

**Valid Request:**
```bash
curl http://localhost:8080/hello/World
# Response: {"message":"Hello, World"}
```

**Validation Rules:**
- Name is required (HTTP 400 if missing)
- Name must be ≤ 256 characters (HTTP 400 if longer)

**Error Response:**
```bash
curl http://localhost:8080/hello
# HTTP 400: {"error":"Name parameter is required"}
```

## CI/CD

GitHub Actions workflows automate:
- **Backend testing**: Unit tests + integration tests
- **UI testing**: Component tests + build verification
- **Smoke tests**: Package validation and runtime testing

All workflows run on:
- Linux (primary) and Windows targets
- JDK 21 (backend)
- Node.js 18+ (UI)

## System Architecture

See [docs/architecture.puml](docs/architecture.puml) for PlantUML diagram showing:
- Component relationships
- Data flow between backend and UI
- Deployment structure

## Troubleshooting

### Backend won't start
- **Check Java version:** `java -version` (requires Java 21)
- **Check port 8080:** `lsof -i :8080` (may be in use)
- **View logs:** Check `backend/server.log` or console output

### UI not loading
- **Backend running?** Verify `curl http://localhost:8080/hello/test` works
- **Check browser console** for errors
- **Verify static files:** Check `out/kaiten-mcp/static/index.html` exists

### Package creation fails
- **Disk space:** Ensure ~500MB free for build artifacts
- **Dependencies:** Run `npm install` and `mvn clean` if issues persist
- **Permissions:** Ensure execute permission on scripts

## Platform Support

- **Linux/macOS**: Full support with bash scripts
- **Windows**: Full support with batch scripts (start.bat, stop.bat)
- **WSL/WSL2**: Fully supported using Unix scripts

## Requirements

### Development
- Java 21 (development and runtime)
- Maven 3.8+
- Node.js 16+ and npm 8+
- bash or Windows Command Prompt

### Runtime
- Java 21 (or bundled JRE if using full build)
- Modern web browser
- ~1GB RAM minimum

## License

Project initialization framework for Kaiten MCP.

## Further Reading

- [Backend README](backend/README.md) - Backend development guide
- [UI README](ui/README.md) - Frontend development guide
- [Architecture Diagram](docs/architecture.puml) - System design
- [Quick Start Guide](specs/001-init-project-structure/quickstart.md) - Integration walkthrough

---

## Русский

# Kaiten MCP - Многокомпонентный проект

> Легкий стартер многокомпонентного проекта с Java Spring Boot бэкендом, React интерфейсом и унифицированной упаковкой для кроссплатформенного развертывания.

## Быстрый старт

### Построить всё

```bash
./build.sh
```

Создает полный дистрибутив:
- **Backend**: Java Spring Boot REST сервис (порт 8080)
- **UI**: React веб-интерфейс (обслуживается из backend)
- **Пакет**: Унифицированный `kaiten-mcp.zip` со всеми компонентами и скриптами

### Запустить пакет

```bash
cd out/kaiten-mcp
./bin/start.sh          # Unix/Linux/macOS
# или
./bin/start.bat         # Windows
```

Доступ к приложению: **http://localhost:8080**

### Остановить сервер

```bash
cd out/kaiten-mcp
./bin/stop.sh           # Unix/Linux/macOS
# или
./bin/stop.bat          # Windows
```

## Структура проекта

```
kaiten-mcp/
├── backend/                         # Java Spring Boot сервис
│   ├── bin/                         # Скрипты запуска
│   ├── src/main/java/               # Исходный код Java
│   ├── src/test/java/               # Модульные тесты
│   ├── pom.xml                      # Конфигурация Maven
│   └── README.md                    # Документация backend
├── ui/                              # React TypeScript приложение
│   ├── src/                         # React компоненты и стили
│   ├── tests/                       # Тесты компонентов
│   ├── vite.config.ts               # Конфигурация Vite
│   ├── package.json                 # npm скрипты
│   └── README.md                    # Документация UI
├── scripts/                         # Утилиты сборки
│   ├── fetch-jre.sh                # Подготовка Java Runtime
│   └── integration-check.sh         # Валидация пакета
├── tests/smoke/                     # Smoke тесты
│   ├── smoke-package.sh            # Тест функциональности пакета
│   ├── smoke-backend.sh            # Тест API backend
│   └── smoke-ui-build.sh           # Проверка артефактов UI
├── docs/                            # Документация
│   └── architecture.puml            # Диаграмма архитектуры
├── out/                             # Выходные данные сборки
│   ├── kaiten-mcp/                 # Собранный каталог пакета
│   └── kaiten-mcp.zip              # Архив дистрибутива
├── build.sh                         # Унифицированная оркестрация сборки
└── README.md                        # Этот файл
```

## Разработка

### Backend

Смотрите [backend/README.md](backend/README.md) для:
- Запуска сервера разработки
- Документации API эндпоинтов
- Правил валидации
- Решения проблем

**Быстрый старт:**
```bash
cd backend
mvn spring-boot:run
# или
./bin/start.sh
```

### UI

Смотрите [ui/README.md](ui/README.md) для:
- Подготовки среды разработки
- Опций интеграции с backend
- Инструкций сборки
- Руководства тестирования

**Быстрый старт:**
```bash
cd ui
npm install
npm run dev
# или тест production сборки
npm run build
npm run preview
```

## Режимы сборки

### Полная сборка (с JRE)
```bash
./build.sh
```
Создает полностью автономный пакет (~200MB с JRE).

### Быстрая сборка (без JRE)
```bash
./build.sh --no-jre
```
Создает дистрибутив без Java (~19MB). Требует Java 21 на целевой системе.

### Пропустить компоненты
```bash
./build.sh --skip-ui               # Только backend
./build.sh --skip-backend          # Только UI
./build.sh --skip-ui --no-jre      # Backend без JRE
```

## Тестирование

### Модульные тесты
```bash
cd backend && mvn test              # Backend тесты
cd ui && npm test                   # UI тесты
```

### Smoke тесты
```bash
./tests/smoke/smoke-package.sh      # Тест упакованного приложения
./tests/smoke/smoke-backend.sh      # Тест backend API
./tests/smoke/smoke-ui-build.sh     # Проверка артефактов UI
```

### Интеграционный тест
```bash
./scripts/integration-check.sh out/kaiten-mcp.zip
```

## Справочник API

### Эндпоинт приветствия

```bash
GET /hello/{name}
```

**Корректный запрос:**
```bash
curl http://localhost:8080/hello/Мир
# Ответ: {"message":"Hello, Мир"}
```

**Правила валидации:**
- Имя обязательно (HTTP 400, если отсутствует)
- Имя должно быть ≤ 256 символов (HTTP 400, если длиннее)

**Ошибка:**
```bash
curl http://localhost:8080/hello
# HTTP 400: {"error":"Name parameter is required"}
```

## CI/CD

GitHub Actions автоматизирует:
- **Backend тестирование**: Модульные + интеграционные тесты
- **UI тестирование**: Тесты компонентов + проверка сборки
- **Smoke тесты**: Валидация пакета и тестирование во время выполнения

Все workflows запускаются на:
- Linux (основная) и Windows целях
- JDK 21 (backend)
- Node.js 18+ (UI)

## Архитектура системы

Смотрите [docs/architecture.puml](docs/architecture.puml) для PlantUML диаграммы, показывающей:
- Связи компонентов
- Поток данных между backend и UI
- Структуру развертывания

## Решение проблем

### Backend не запускается
- **Проверьте версию Java:** `java -version` (требуется Java 21)
- **Проверьте порт 8080:** `lsof -i :8080` (может быть занят)
- **Просмотрите логи:** Проверьте `backend/server.log` или вывод консоли

### UI не загружается
- **Backend запущен?** Проверьте `curl http://localhost:8080/hello/test`
- **Проверьте консоль браузера** на ошибки
- **Проверьте статические файлы:** `out/kaiten-mcp/static/index.html` существует?

### Создание пакета не удается
- **Место на диске:** Убедитесь, что свободно ~500MB для артефактов
- **Зависимости:** Запустите `npm install` и `mvn clean` при необходимости
- **Права доступа:** Убедитесь в правах на выполнение скриптов

## Поддерживаемые платформы

- **Linux/macOS**: Полная поддержка с bash скриптами
- **Windows**: Полная поддержка с batch скриптами (start.bat, stop.bat)
- **WSL/WSL2**: Полностью поддерживается с Unix скриптами

## Требования

### Разработка
- Java 21 (разработка и выполнение)
- Maven 3.8+
- Node.js 16+ и npm 8+
- bash или Windows Command Prompt

### Выполнение
- Java 21 (или встроенная JRE при использовании полной сборки)
- Современный веб-браузер
- ~1GB RAM минимум

## Дополнительное чтение

- [Backend README](backend/README.md) - Руководство разработки backend
- [UI README](ui/README.md) - Руководство разработки фронтенда
- [Диаграмма архитектуры](docs/architecture.puml) - Дизайн системы
- [Руководство быстрого старта](specs/001-init-project-structure/quickstart.md) - Пошаговая интеграция
