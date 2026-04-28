# AGENTS.md

## Build & Run

```bash
mvn clean compile      # compile only
mvn exec:java        # run directly (don't use java -jar)
mvn clean package    # build fat JAR
```

## Database Prerequisite

- PostgreSQL **must be running** on `localhost:5432` before starting the app
- Database: `learnux_db`, schema: `learnux`
- Credentials are hardcoded in `DatabaseConnection.java` (check there if DB connection fails)
- Reset data: `psql -U postgres learnux_db < learnux_dump.sql`

## No Tests

`src/test/` is empty. No `mvn test` command works.

## Styling

Each UI component defines its own `BG_DARK`, `BG_CARD`, `ACCENT`, `GREEN`, `YELLOW`, `PINK` constants locally. Use these instead of raw hex values. Custom scrollbars via `UiUtil.estilizarScroll()`.

## Tech Stack

- Java 21 (Swing UI, no web framework)
- PostgreSQL with JDBC driver 42.7.3
- Entry point: `com.learnux.ui.MainFrame`

## Architecture Notes

- Business logic lives in PostgreSQL **stored functions/procedures** (`f_buscar_usuario`, `sp_registrar_usuario`, etc.) — check `learnux_dump.sql` before reimplementing in Java
- DAO layer returns empty collections on error (fail-safe)
- Service layer throws `ServiceException` with user-facing messages