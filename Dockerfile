FROM eclipse-temurin:21-jre
ARG JAR_FILE=target/warehouse-tamplate-2.0.0.jar
WORKDIR /app
COPY ${JAR_FILE} app.jar
ENV JAVA_OPTS=""
EXPOSE 8080
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]
