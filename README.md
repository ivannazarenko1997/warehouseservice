1. Overview

This application is a small reactive monitoring platform for warehouses equipped with environmental sensors. Each warehouse contains sensors that periodically send measurements (temperature and humidity) via UDP.

The solution consists of two logical services:

Warehouse Service – receives raw UDP datagrams from sensors, validates and normalizes the data, and forwards structured events to a central system (optionally via a message broker).

Central Monitoring Service – aggregates measurements from one or more warehouses, applies configured thresholds for temperature and humidity, and raises alarms when limits are exceeded. Alarms are visible in the logs/console and can be further integrated with external monitoring tools.

The system is designed to be reactive, non-blocking, and easily extensible for additional sensor types or alert channels.

2. Functional Requirements Mapping
   2.1 Sensor Types and Protocol

The system currently supports two sensor types:

Temperature

UDP Port: 3344

Message format: sensor_id=t1; value=30

Threshold: 35°C

Humidity

UDP Port: 3355

Message format: sensor_id=h1; value=40

Threshold: 50%

Each sensor sends UDP packets in the form:

sensor_id=<ID>; value=<numeric_value>


The Warehouse Service parses these datagrams, extracts sensor_id and value, and also derives the sensor type based on the port or configuration.

2.2 Threshold Monitoring & Alarms

The Central Monitoring Service maintains configurable thresholds for:

TEMPERATURE_MAX = 35°C

HUMIDITY_MAX = 50%

For each incoming measurement:

If the value is within the allowed range → status is logged as OK.

If the value exceeds the configured threshold → an ALARM is raised.

 
Possible urls:


GET http://localhost:8080/v1/api/alarms?sensorType=TEMPERATURE
GET http://localhost:8080/v1/api/alarms?sensorType=HUMIDITY
GET http://localhost:8080/v1/api/alarms?page=0&size=20
GET http://localhost:8080/v1/api/alarms?page=1&size=20
GET http://localhost:8080/v1/api/alarms?page=2&size=50
GET http://localhost:8080/v1/api/alarms?page=0&size=100
GET http://localhost:8080/v1/api/alarms?sort=id,asc
GET http://localhost:8080/v1/api/alarms?sort=id,desc
GET http://localhost:8080/v1/api/alarms?sensorType=TEMPERATURE&page=0&size=20&sort=createdAt,desc
GET http://localhost:8080/v1/api/alarms?sensorType=HUMIDITY&page=1&size=50&sort=createdAt,asc
