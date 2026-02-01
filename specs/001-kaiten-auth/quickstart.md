# Quickstart: Kaiten Integration (001-kaiten-auth)

This feature adds the ability to connect your Kaiten organization by providing an organization URL and a personal token.

## Local Environment

- Java 21 (use `sdkman` to install/switch): https://sdkman.io/
- Node.js (use `nvm`): see project `package.json` for required version.
- SQLite3 (CLI) for debug and inspection if needed.

## Running locally

1. Start backend:
   - mvn -f backend/ spring-boot:run
2. Start frontend:
   - cd ui && npm install && npm run dev

## DB & Data
- Database file: `data/kaiten.db` (will be created automatically on first run).
- Credentials are stored in plaintext per spec requirement. The table `kaiten_credentials` contains columns `{ id, org_url, token, profile_json, saved_at }`.

## Notes
- Security tradeoff: tokens are stored in plaintext in SQLite as requested. If you need better security, consider using OS keystore or encryption at rest.
- API calls to Kaiten use `Authorization: Bearer <token>` header and call `https://<org>/api/latest/users/current` to verify tokens and fetch profile.
