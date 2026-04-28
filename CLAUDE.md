# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# Compile
mvn clean compile

# Run directly (no packaging needed)
mvn exec:java

# Build fat JAR and run
mvn clean package
java -jar target/LearnuxApp-1.0-SNAPSHOT.jar
```

There are no tests. The `src/test/` directory exists but is empty.

## Database

- PostgreSQL on `localhost:5432`, database `learnux_db`, schema `learnux`
- Credentials are hardcoded in `DatabaseConnection.java`
- To reset or seed: `psql -U postgres learnux_db < learnux_dump.sql`
- Additional data: `ejercicios_adicionales.sql`, `enriquecer_flags.sql`
- Business logic lives in PostgreSQL stored functions/procedures (`f_buscar_usuario`, `f_get_comandos_de_nivel`, `sp_registrar_usuario`, etc.) — check the dump before reimplementing logic in Java

## Architecture

Three-tier layered architecture:

```
UI (Swing panels)  →  Service layer  →  DAO layer  →  PostgreSQL
```

- **`models/`** — plain POJOs mapping DB rows (Usuario, Comando, Nivel, Ejercicio, OpcionComando, etc.)
- **`dao/`** — all SQL lives here; uses `DatabaseConnection.getConnection()` and try-with-resources; returns empty collections on error (fail-safe)
- **`service/`** — validates input, orchestrates DAOs, throws `ServiceException` with user-facing messages
- **`ui/`** — Swing panels; catches `ServiceException` and shows it via `JOptionPane`
- **`SoundPlayer`** — synthesizes audio tones via `javax.sound.sampled` (no external audio files). Static methods: `playCorrect()`, `playWrong()`, `playGameOver()`, `playLevelPass()`.

## UI Navigation

`MainFrame` owns a `CardLayout` and controls all screen transitions:

```
IntroPanel → LoginPanel → PrincipalPanel (5-tab JTabbedPane)
                                ↓
                         NivelesPanel → EjercicioPanel
                                ↓
                ExamenPanel / JefeFinalPanel (Boss Fight)
```

Key `MainFrame` methods: `mostrarLogin()`, `mostrarPanelPrincipal(Usuario)`, `mostrarEjercicioPanel(JPanel)`, `mostrarExamenPanel(Usuario)`, `volverAPrincipal()`.

`PrincipalPanel` contains 5 tabs: Noticias, Explorar (command browser with `JSplitPane`), Progreso, Niveles, Evaluación.

## Exercise & Level Systems

Exercises (`Ejercicio` model) have five types driven by the `ejercicio_tipo` DB domain:
`DRAG_DROP`, `MULTIPLE_CHOICE`, `FILL_BLANK`, `TYPE_COMMAND`, `TERMINAL_SIM`

`EjercicioPanel` renders different UI for each type. `Ejercicio.getOpciones()` parses the `opciones_json` column. `Ejercicio.esCorrecta(respuesta)` does case-insensitive comparison.

There are **24 levels** grouped into 4 tiers; progression is tracked in `progreso_usuario` and unlocked via `sp_registrar_usuario`.

### Exam & Boss Systems
- **`ExamenPanel`**: A 10-minute timed exam with 5 questions drawn from fixed levels {1, 4, 7, 11, 15}. No hints available.
- **`JefeFinalPanel`**: Hardcoded "Boss Fights" triggered after completing a tier. Questions and logic are local (no DB) and follow a theme (e.g., File System Guardian, Process Tracker).

## Styling Conventions

All shared colors and UI helpers are in `UiUtil`. The palette is Catppuccin Mocha-inspired — use the constants defined there (`BG_DARK`, `BG_CARD`, `ACCENT`, `GREEN`, `YELLOW`, `PINK`, etc.) rather than raw hex values. Custom scrollbar styling goes through `UiUtil.estilizarScroll()`. Animated components (Matrix login background, glowing level cards, fade-in overlay) use `javax.swing.Timer`.

**Warning:** `ExamenPanel` and `JefeFinalPanel` currently use locally defined color constants. When modifying these, prefer refactoring them to use `UiUtil` for consistency.
