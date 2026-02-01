# data-model.md — 001-init-project-structure

## Entities

### Greeting
- Description: Ответ бэкенда, содержащий человекочитаемое приветствие.
- Fields:
  - `message` (string) — обязательное текстовое поле, UTF-8, содержит приветствие, например: "Hello, Иван".
- Validation rules:
  - `message` генерируется на основе входного параметра `name`.
  - `name` (вход): обязательное поле, строка, не пустая, максимум 256 символов. Поддержка UTF-8.
  - Если длина имени > 256 символов — сервер возвращает 400 Bad Request и JSON `{ "error": "name too long" }`.
  - Если HTTP-запрос не содержит сегмента пути `name` (например, `GET /hello/`) — сервер возвращает 400 Bad Request и JSON `{ "error": "name missing" }`.

## State transitions
- Нет длительных состояний; единственный поток — вход `name` -> валидация -> формирование `message` -> ответ.

## Notes
- Нет персистентных сущностей — хранение не требуется.
- Формат ответа JSON `{ "message": "Hello, <name>" }`.