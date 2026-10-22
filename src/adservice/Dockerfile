# Stage 1: Builder
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Minimal Runtime
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=builder /app/target/*.jar /app/adservice.jar

EXPOSE 9555

ENTRYPOINT ["java", "-jar", "/app/adservice.jar"]
