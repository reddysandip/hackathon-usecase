# Multi-stage build for Spring Boot app targeting Java 21
# Build stage uses Maven with Temurin JDK 21
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Cache dependencies first
COPY pom.xml .
RUN mvn -q -e -DskipTests dependency:go-offline

# Copy source and build
COPY src ./src
RUN mvn -q -DskipTests package

# Runtime stage: slim JRE 21 image
FROM eclipse-temurin:21-jre
WORKDIR /app

# Expose default Spring Boot port
ENV JAVA_OPTS=""
EXPOSE 8080

# Copy the built jar
COPY --from=build /app/target/*.jar app.jar

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
