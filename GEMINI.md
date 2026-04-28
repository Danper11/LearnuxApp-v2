# LearnuxApp (v2) — Project Context

This is a desktop application (Java Swing) designed to teach Linux commands through an interactive, gamified experience. It follows a three-tier architecture with a heavy emphasis on delegating business logic to PostgreSQL stored procedures and functions.

## Project Overview

*   **Primary Goal:** Provide a platform for learning Linux commands with various exercise types and level progression.
*   **Main Technologies:**
    *   **Language:** Java 21
    *   **Build System:** Maven
    *   **UI Framework:** Java Swing (Custom themed)
    *   **Database:** PostgreSQL 16+
*   **Architecture:**
    *   `com.learnux.ui`: Swing panels and main frame coordination.
    *   `com.learnux.service`: Orchestrates DAOs and handles business validation (throws `ServiceException`).
    *   `com.learnux.dao`: SQL execution and row mapping (uses `DatabaseConnection`).
    *   `com.learnux.models`: Plain POJOs mapping database entities.

## Building and Running

### Prerequisites
*   Java 21 (JDK)
*   Maven 3.x
*   PostgreSQL running on `localhost:5432`

### Database Setup
1.  Create database `learnux_db`.
2.  Import the schema and initial data:
    ```bash
    psql -U postgres learnux_db < learnux_dump.sql
    ```
3.  (Optional) Add extra content:
    ```bash
    psql -U postgres learnux_db < ejercicios_adicionales.sql
    psql -U postgres learnux_db < enriquecer_flags.sql
    ```

### Build Commands
```bash
# Compile the project
mvn clean compile

# Run directly via Maven
mvn exec:java

# Build a fat JAR
mvn clean package

# Run the JAR
java -jar target/LearnuxApp-1.0-SNAPSHOT.jar
```

## Development Conventions

### Coding Style
*   **Error Handling:** DAOs should fail gracefully, returning `null` or empty collections rather than throwing `SQLException`. Services validate inputs and throw `ServiceException` with user-friendly messages.
*   **Database Logic:** Favor PostgreSQL stored functions (`f_...`) and procedures (`sp_...`) for complex logic or data integrity checks. Check `learnux_dump.sql` before implementing business logic in Java.
*   **UI Design:** Strictly adhere to the **Catppuccin Mocha** palette defined in `UiUtil.java`.
    *   Use `UiUtil.estilizarScroll(JScrollPane)` for all scrollable areas.
    *   Transitions are managed by `MainFrame` via `CardLayout`.
*   **Testing:** Currently, there are no automated tests. The `src/test/` directory is empty.

### UI Colors (Catppuccin Mocha)
*   **Background:** `30, 30, 46` (BG_DARK)
*   **Cards:** `49, 50, 68` (BG_CARD)
*   **Accent:** `180, 190, 254` (LAVENDER)
*   **Success:** `166, 227, 161` (GREEN)
*   **Warning/Error:** `243, 139, 168` (RED)

## Key Components

*   **MainFrame:** The root container using `CardLayout` for high-level screen switching.
*   **PrincipalPanel:** The main dashboard with a `JTabbedPane` (Noticias, Explorar, Progreso, Niveles, Evaluación).
*   **EjercicioPanel:** Dynamic panel that renders different UI components based on `ejercicio_tipo` (DRAG_DROP, MULTIPLE_CHOICE, FILL_BLANK, TYPE_COMMAND, TERMINAL_SIM).
*   **UiUtil:** Utility class for scrollbar styling and shared UI constants.
