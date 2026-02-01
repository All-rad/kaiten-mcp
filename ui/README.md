# UI — Kaiten MCP

React + TypeScript + Vite фронтенд-приложение для Kaiten MCP.

## Быстрый старт

### Инсталляция и разработка

```bash
cd ui
npm install
npm run dev
```

Откройте браузер на http://localhost:5173

## Разработка

### Локальная разработка с backend

По умолчанию UI ищет backend на `http://localhost:8080`.

#### Вариант 1: Запустить backend с использованием скриптов

```bash
# В отдельном терминале, из корня проекта
./backend/bin/start.sh

# UI автоматически подключится к http://localhost:8080
```

#### Вариант 2: Запустить backend вручную

```bash
cd backend
mvn spring-boot:run
```

#### Вариант 3: Запустить скомпилированный JAR

```bash
cd backend
mvn clean package
java -jar target/kaiten-mcp*.jar
```

### Настройка backend URL

Если backend запущен на другом хосте/порту, отредактируйте [src/pages/Home.tsx](src/pages/Home.tsx) строку с URL:

```typescript
const response = await fetch('http://localhost:8080/hello/Анна');
// Измените на:
const response = await fetch('http://your-backend-host:port/hello/Анна');
```

### Использование UI

1. Введите имя в поле "Имя:"
2. Нажмите кнопку "Поздороваться"
3. UI отправит `GET /hello/{имя}` на backend
4. Результат отобразится в поле "Статус"

**Пример:**
- Введите: "Иван"
- Результат: "Hello, Иван"

## Сборка (Production)

### Собрать статические файлы

```bash
npm run build
```

Результат: `ui/dist/` содержит:
- `index.html` — точка входа
- `assets/` — скомпилированный JavaScript и CSS

### Проверить собранные файлы

```bash
npm run build
# Проверить, что dist/ создана
ls -la dist/
```

## Структура проекта

```
ui/
├── src/
│   ├── App.tsx              # Корневой компонент
│   ├── pages/
│   │   └── Home.tsx         # Главная страница с формой
│   ├── index.css            # Стили
│   └── main.tsx             # Точка входа React
├── tests/
│   └── Home.test.tsx        # Unit тесты для Home компонента
├── package.json             # npm зависимости и скрипты
├── vite.config.ts           # Конфигурация Vite
├── tsconfig.json            # Конфигурация TypeScript
├── jest.config.cjs          # Конфигурация Jest
└── README.md                # Этот файл
```

## Тестирование

### Запустить unit тесты

```bash
npm test
```

Результат: Jest запустит все тесты в `tests/` директории и отобразит результаты.

### Написать новые тесты

Новые тест-файлы должны быть в `tests/` и иметь расширение `.test.tsx` или `.test.ts`.

Пример:

```typescript
// tests/NewFeature.test.tsx
import { render, screen } from '@testing-library/react';
import NewFeature from '../src/components/NewFeature';

test('renders new feature', () => {
  render(<NewFeature />);
  expect(screen.getByText('Feature')).toBeInTheDocument();
});
```

## Требования для разработки

- Node.js 16+ (проверить: `node --version`)
- npm 8+ (проверить: `npm --version`)

## Связанные ссылки

- Backend: см. [backend/README.md](../backend/README.md)
- Полная документация: см. [README.md](../README.md)
- Архитектура: см. [docs/architecture.puml](../docs/architecture.puml) (если существует)
