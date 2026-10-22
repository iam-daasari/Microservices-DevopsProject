# Stage 1: Build stage (Debian based - contains full glibc for protoc)
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /app

# Cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Compile protobuf & package jar
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Final Minimal Runtime Stage
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=builder /app/target/*.jar /app/adservice.jar

EXPOSE 9555

ENTRYPOINT ["java", "-jar", "/app/adservice.jar"]
