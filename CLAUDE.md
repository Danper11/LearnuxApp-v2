# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# Compile only
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
- Connection resolution order: `DATABASE_URL` env var (Railway/Render format) → `src/main/resources/learnux.properties` → hardcoded defaults (`postgres`/`danper.exe`)
- To reset or seed: `psql -U postgres learnux_db < learnux_dump.sql`
- Additional data: `ejercicios_adicionales.sql`, `enriquecer_flags.sql`
- Heavy business logic lives in PostgreSQL stored functions/procedures — check the dump before reimplementing in Java:
  - `f_buscar_usuario`, `f_get_comandos_de_nivel`, `f_get_ejercicios_nivel` — query functions
  - `sp_registrar_usuario`, `sp_registrar_intento`, `sp_actualizar_progreso` — stored procedures
  - `fn_avanzar_nivel_usuario` — DB trigger that unlocks the next level after boss completion

## Architecture

Three-tier layered architecture:

```
UI (Swing panels)  →  Service layer  →  DAO layer  →  PostgreSQL
```

- **`models/`** — plain POJOs mapping DB rows (`Usuario`, `Comando`, `Nivel`, `Ejercicio`, `OpcionComando`, `ProgresoUsuario`, `Categoria`)
- **`dao/`** — all SQL lives here; uses `DatabaseConnection.getConnection()` and try-with-resources; returns empty collections on error (fail-safe). Notable: `ResumenDao` has nested records `Resumen` and `FilaProgreso` used by `ProgresoPanel`. `BuscadorDao` powers the search in the Explorar tab.
- **`service/`** — validates input, orchestrates DAOs, throws `ServiceException` with user-facing messages
- **`ui/`** — Swing panels; catches `ServiceException` and shows it via `JOptionPane`
- **`SoundPlayer`** — synthesizes audio tones via `javax.sound.sampled` (no external files). Static methods: `playCorrect()`, `playWrong()`, `playGameOver()`, `playLevelPass()`

## UI Navigation

`MainFrame` owns a `CardLayout` and controls all screen transitions:

```
IntroPanel → LoginPanel → PrincipalPanel (5-tab JTabbedPane)
                                ↓
                         NivelesPanel → EjercicioPanel
                                ↓
                ExamenPanel / JefeFinalPanel (Boss Fight)
```

Key `MainFrame` methods:
- `mostrarLogin()` — also calls `NivelService.resetRepetidos()` to clear anti-repetition state
- `mostrarPanelPrincipal(Usuario)` / `mostrarPanelPrincipal(Usuario, esNuevo)` — the `esNuevo=true` path shows `TutorialBienvenidaDialog` after the fade-in
- `mostrarEjercicioPanel(JPanel)` — removes the previous ejercicio panel before adding the new one
- `mostrarExamenPanel(Usuario)`, `volverAPrincipal()`

`PrincipalPanel` contains 5 tabs: Noticias, Explorar (command browser with `JSplitPane` + live search via `BuscadorDao`), Progreso, Niveles, Evaluación.

## Exercise & Level Systems

Exercises (`Ejercicio` model) have five types driven by the `ejercicio_tipo` DB domain:
`DRAG_DROP`, `MULTIPLE_CHOICE`, `FILL_BLANK`, `TYPE_COMMAND`, `TERMINAL_SIM`

`EjercicioPanel` renders different UI for each type. `Ejercicio.getOpciones()` delegates to `UiUtil.parseJsonArray()`. `Ejercicio.esCorrecta(respuesta)` does case-insensitive trimmed comparison.

There are **24 levels** grouped into 4 tiers of 6 levels each:

| Tier | Levels | Label |
|------|--------|-------|
| 1 | 1–6 | Fundamentos (green) |
| 2 | 7–12 | Intermedio (yellow) |
| 3 | 13–18 | Avanzado (orange) |
| 4 | 19–24 | Maestro (pink) |

Level 6, 12, 18, and 24 are boss fights (`esJefeFinal` in `NivelesPanel`). Completing a boss writes directly to `progreso_nivel` via `ProgresoDao.completarNivelBoss()`, which fires the DB trigger to unlock the next tier.

`TERMINAL_SIM` exercises are only shown at levels 6, 12, and 13+ — `NivelService.filtrarPorTier()` strips them elsewhere.

`NivelService` maintains a static `IDs_USADOS` set to avoid repeating exercises across sessions for levels 1–12. It resets on logout via `NivelService.resetRepetidos()`. Each level play selects 4 exercises (shuffled, non-repeated when possible).

### Exam & Boss Systems
- **`ExamenPanel`**: 10-minute timed exam with 5 questions drawn from fixed levels `{1, 4, 7, 11, 15}`. Prefers `MULTIPLE_CHOICE`/`FILL_BLANK` question types. No hints.
- **`JefeFinalPanel`**: Hardcoded boss fights (no DB) — questions and narrative are defined as `BossData`/`BossEj` records directly in the class. One boss per tier, triggered by `NivelesPanel` passing the tier index (1–4).

## Styling Conventions

All shared colors and UI helpers are in `UiUtil`. The palette is Catppuccin Mocha-inspired — use the constants defined there (`BG_DARK`, `BG_CARD`, `BG_HDR`, `ACCENT`, `BLUE`, `GREEN`, `YELLOW`, `RED`, `PINK`, `MAUVE`, etc.) rather than raw hex values.

Fonts: `FONT_TITLE` (32pt bold mono), `FONT_SUB` (22pt bold mono), `FONT_REG` (18pt mono), `FONT_SMALL` (15pt mono), `FONT_MONO` (20pt mono).

Other `UiUtil` helpers:
- `estilizarScroll(JScrollPane)` — applies thin custom scrollbar styling
- `parseJsonArray(String)` / `parseJsonObjeto(String)` — hand-rolled JSON parsers (no external libs)
- `marcarError(JPanel)` — briefly flashes a panel red to indicate a wrong answer

**Warning:** `ExamenPanel` and `JefeFinalPanel` currently use locally defined color constants. When modifying these, prefer refactoring them to use `UiUtil` for consistency.

## Deployment

The app runs in Docker as a headless Java Swing app exposed via browser through noVNC:

```
Xvfb (virtual display) → x11vnc → websockify → noVNC (port 8080)
```

`start.sh` orchestrates the startup sequence. The `PORT` env var (default 8080) is read by websockify. `DATABASE_URL` env var overrides local DB config (used by Railway/Render).
