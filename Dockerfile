# --- Stage 1: Build Stage ---
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Copy Maven wrapper and pom.xml first to leverage Docker cache
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline

# Copy source and build the application
COPY src ./src
RUN ./mvnw package -DskipTests

# --- Stage 2: Runtime Stage ---
# Using the 'jre' version here because it's smaller than the full 'jdk'
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy only the built JAR from the build stage
COPY --from=build /app/target/PiedPiper-0.0.1-SNAPSHOT.jar app.jar

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]