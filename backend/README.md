# Backend — Kaiten MCP

## Обзор

Backend сервис Kaiten MCP предоставляет REST API для приветствия пользователей. Сервис написан на Java 21 с использованием Spring Boot 3.5.2.

## Быстрый старт

### Развертывание с использованием скриптов (Linux)

Самый простой способ запустить backend:

```bash
# Собрать и запустить сервер
./backend/bin/start.sh

# Тестировать эндпоинт
curl -s http://localhost:8080/hello/World | jq

# Остановить сервер
./backend/bin/stop.sh
```

### Запуск через Maven напрямую

```bash
# Собрать backend
cd backend
mvn clean package

# Запустить в режиме разработки
mvn spring-boot:run

# Или запустить скомпилированный JAR
java -jar target/kaiten-mcp.jar
```

## Сборка и упаковка

### Полная сборка (с тестами)

```bash
mvn clean package
```

Результат: `backend/target/kaiten-mcp.jar` — исполняемый JAR файл.

### Сборка без тестов

```bash
mvn clean package -DskipTests
```

### Запуск unit тестов

```bash
mvn test
```

## API эндпоинты

### Приветствие

Возвращает приветственное сообщение для указанного имени.

**Запрос:**
```bash
GET /hello/{name}
```

**Успешный ответ (200 OK):**
```json
{
  "message": "Hello, {name}"
}
```

### Примеры использования curl

```bash
# Простой запрос
curl -s http://localhost:8080/hello/Иван | jq

# С полной информацией (заголовки, статус)
curl -i http://localhost:8080/hello/Иван

# Пример ответа
# HTTP/1.1 200 OK
# Content-Type: application/json
# {"message":"Hello, Иван"}

# Проверка валидации (пустое имя - должна ошибка 400)
curl -s http://localhost:8080/hello/ | jq

# Проверка валидации (длинное имя > 256 символов - должна ошибка 400)
curl -s 'http://localhost:8080/hello/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' | jq
```

## Валидация

Эндпоинт `/hello/{name}` применяет следующие правила валидации:

- **Имя требуется**: Пустое имя возвращает HTTP 400 Bad Request с сообщением об ошибке.
- **Максимальная длина**: Имя не может быть длиннее 256 символов. Более длинное имя возвращает HTTP 400.

## Логирование

Сервер выводит логи в консоль. При использовании скриптов `start.sh`/`stop.sh` логи сохраняются в:

```bash
backend/server.log
```

Просмотр логов в реальном времени:

```bash
tail -f backend/server.log
```

## Рабочие директории

- `src/main/java/com/kaiten/mcp/` — исходный код
  - `Application.java` — точка входа Spring Boot
  - `hello/` — сервис приветствия
    - `HelloService.java` — логика приветствия и валидация
    - `HelloController.java` — REST контроллер
  - `exception/` — обработка ошибок
    - `GlobalExceptionHandler.java` — глобальный обработчик исключений
- `src/test/` — unit тесты
- `target/` — скомпилированные артефакты и JAR файл

## Требования для разработки

- Java 21 или выше
- Maven 3.8+

## Устранение проблем

### Ошибка "Maven not found"

Убедитесь, что Maven установлена и добавлена в PATH:

```bash
mvn --version
```

### Ошибка "Port already in use"

Если порт 8080 занят, можно использовать другой порт:

```bash
SERVER_PORT=9090 java -jar target/kaiten-mcp.jar
```

Или при использовании скриптов:

```bash
cd backend && SERVER_PORT=9090 ../backend/bin/start.sh
```

### Сервер не запускается

Проверьте логи:

```bash
tail -20 backend/server.log
```

Затем остановите оставшиеся процессы Java:

```bash
pkill -f kaiten-mcp.jar
rm -f backend/.server.pid
```

## Связанные ссылки

- UI: см. [ui/README.md](../ui/README.md)
- Полная документация: см. [../README.md](../README.md)
