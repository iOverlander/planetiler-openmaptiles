FROM eclipse-temurin:21-jdk AS build
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .
RUN git init && git config user.email "build@local" && git config user.name "build" && git add -A && git commit -m "build"
RUN ./mvnw -B -ntp clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*with-deps.jar /app/planetiler.jar
ENTRYPOINT ["java", "-jar", "/app/planetiler.jar"]
