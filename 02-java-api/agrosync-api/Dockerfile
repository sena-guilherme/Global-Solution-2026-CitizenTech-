# syntax=docker/dockerfile:1

# ======================= Etapa 1: compilar o projeto =======================
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build

# copia só o pom.xml primeiro: as dependências ficam em cache e o build seguinte é bem mais rápido
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q clean package -DskipTests

# ======================= Etapa 2: imagem final (só o necessário para rodar) =======================
FROM eclipse-temurin:21-jre

# curl para o HEALTHCHECK
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# usuário SEM privilégios de administrador (boa prática e exigência da disciplina de DevOps)
RUN groupadd --system app && useradd --system --gid app --create-home app

WORKDIR /app
COPY --from=build /build/target/*.jar app.jar

# pasta das fotos da comunidade (vira volume no docker-compose)
RUN mkdir -p /app/uploads && chown -R app:app /app
USER app

# perfil "prod" = PostgreSQL. Banco, JWT_SECRET e demais valores chegam por variáveis de ambiente.
ENV SPRING_PROFILES_ACTIVE=prod \
    UPLOAD_DIR=/app/uploads \
    JAVA_OPTS="-XX:MaxRAMPercentage=75"

EXPOSE 8080

# a API responde em /api/status quando está pronta (a 1ª subida leva ~40 s)
HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=5 \
    CMD curl -fs http://localhost:8080/api/status || exit 1

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]
