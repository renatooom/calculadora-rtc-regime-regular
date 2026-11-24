FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /app

COPY . .

# Passo obrigatório da Receita: gerar o banco SQLite via Flyway usando mvn global
RUN mkdir -p ./calculadora/db && \
    mvn flyway:migrate -Dflyway.configFiles=./flyway/flyway-pro.conf --batch-mode --errors

# Gerar o pacote JAR pulando os testes para economizar memória no Render
RUN mvn clean package -DskipTests

FROM eclipse-temurin:25-jre
WORKDIR /app

COPY --from=build /app/target/api-regime-geral.jar app.jar
COPY --from=build /app/calculadora ./calculadora

EXPOSE 8080
ENTRYPOINT ["java", "-Dspring.profiles.active=offline", "-jar", "app.jar"]
