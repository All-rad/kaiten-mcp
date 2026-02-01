# Data Model for Kaiten integration

## Entities

### KaitenCredentials
- Description: Stores organization URL, token, and the last fetched profile JSON.
- Fields:
  - id: INTEGER, PK
  - org_url: TEXT, not null
  - token: TEXT, not null
  - profile_json: TEXT, nullable — raw JSON response from Kaiten
  - saved_at: TEXT, ISO-8601 timestamp of last save
- Constraints:
  - Single-row model: repository enforces only one active row; `id = 1` is used for single credential.

### KaitenUserProfile (derived)
- Description: Parsed view of `profile_json` to present user-friendly fields in UI.
- Fields (examples parsed from profile_json):
  - id: integer
  - full_name: string
  - email: string
  - username: string
  - updated: string
- Validation:
  - `full_name` and `email` may be missing; UI should display whats available and gracefully handle missing data.

## State transitions
- On successful `connect`: upsert the single credentials row and store `profile_json` and `saved_at`.
- On application start: if credentials exist, read and call Kaiten to refresh `profile_json` (update if changed).
- On `disconnect`: delete the credentials row.

## Notes
- Storing full `profile_json` provides flexibility without evolving DB schema for new fields.
- For multi-credential support later, add `name` and `active` flags and allow multiple rows.
