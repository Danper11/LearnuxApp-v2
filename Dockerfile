# ── Etapa 1: compilar ────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests -q

# ── Etapa 2: runtime con escritorio virtual + noVNC ───────────────────
FROM eclipse-temurin:21-jre

RUN apt-get update && apt-get install -y \
        xvfb \
        x11vnc \
        novnc \
        websockify \
        fluxbox \
        fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/target/LearnuxApp-1.0-SNAPSHOT.jar app.jar
COPY start.sh .
RUN chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]
