FROM eclipse-temurin:25-jdk AS build
WORKDIR /app

COPY . .
RUN chmod +x mvnw

# Passo obrigatório da Receita: gerar o banco SQLite via Flyway
RUN mkdir -p ./calculadora/db && \
    ./mvnw flyway:migrate -Dflyway.configFiles=./flyway/flyway-pro.conf --batch-mode --errors

# Gerar o pacote JAR pulando os testes para economizar memória no Render
RUN ./mvnw clean package -DskipTests

FROM eclipse-temurin:25-jre
WORKDIR /app

COPY --from=build /app/target/api-regime-geral.jar app.jar
COPY --from=build /app/calculadora ./calculadora

EXPOSE 8080
ENTRYPOINT ["java", "-Dspring.profiles.active=offline", "-jar", "app.jar"]
