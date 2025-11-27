Warehouse Monitoring Service
Reactive UDP Sensor Listener + Threshold Monitoring + Alarm Logging + REST API

This application is a unified monitoring service that receives environmental measurements (Temperature & Humidity) via UDP, evaluates thresholds, logs alarms, stores events, and exposes REST endpoints for querying alarms — all inside one Spring Boot service.

No external “central service” is needed — everything is built into one application.

📘 System Overview

Warehouses are equipped with Temperature and Humidity sensors.
Each sensor sends readings via UDP datagrams in a simple text format:

sensor_id=t1; value=30
sensor_id=h1; value=40


This service:

Listens to UDP ports 3344 & 3355

Parses sensor messages

Validates measurement format

Evaluates thresholds

Logs normal status or alarms

Persists alarm events into PostgreSQL

Provides REST API to fetch alarms

Everything runs fully automatically — no user input required.



🏗️ Architecture
┌─────────────────────────┐
│   Temperature Sensor    │
│   UDP → 3344            │
└──────────────┬──────────┘
               │ UDP
               ▼
       ┌──────────────────────┐
       │                      │
       │ Warehouse Monitoring │
       │       Service       │
       │ (Single Application)│
       │                      │
       │ - UDP Listener       │
       │ - Regex Parser       │
       │ - Threshold Checker  │
       │ - Alarm Logger       │
       │ - PostgreSQL Storage │
       │ - REST API           │
       └───────┬─────────────┘
               │
               ▼
     ┌──────────────────────────┐
     │ GET /v1/api/alarms       │
     │ pageable, filter by type │
     └──────────────────────────┘




🌡️ Sensor Specifications
Sensor Type	UDP Port	Format	Threshold
Temperature	3344	sensor_id=t1; value=30	> 35°C
Humidity	3355	sensor_id=h1; value=40	> 50%
📂 Main Components
Component	Description
UdpListenerComponent	Reactive Netty UDP server listening on ports 3344 and 3355
SensorMeasurementEvent	Internal model representing parsed sensor message
EventListenerMapper	Maps parsed datagrams to event objects and entities
MeasurementProducer	(Optional) Kafka producer for distributed event processing
MeasurementConsumer	Evaluates thresholds and stores alarms
SensorService	JPA service that persists sensor alarms
AlarmResponseDto	REST DTO returned by /v1/api/alarms
SensorMeasurementController	REST endpoint to fetch alarms
🚀 How to Run
1. Start PostgreSQL (optional docker-compose)
docker compose up -d

2. Run Application
./mvnw spring-boot:run


You will see:

UDP listener ready for [TEMPERATURE] on 0.0.0.0:3344
UDP listener ready for [HUMIDITY] on 0.0.0.0:3355

🧪 Testing UDP Messages

Use netcat (nc):

Temperature OK
echo "sensor_id=t1; value=25.5" | nc -u -w1 127.0.0.1 3344

Temperature ALARM (>35)
echo "sensor_id=t1; value=40" | nc -u -w1 127.0.0.1 3344

Humidity OK
echo "sensor_id=h1; value=40" | nc -u -w1 127.0.0.1 3355

Humidity ALARM (>50)
echo "sensor_id=h1; value=60.2" | nc -u -w1 127.0.0.1 3355

📡 REST Endpoints
Fetch last 20 alarms
GET http://localhost:8080/v1/api/alarms


Supports:

?page=0&size=20&sort=createdAt,desc


Filter by type:

GET /v1/api/alarms?sensorType=temperature


Example response:

{
  "content": [
    {
      "sensorId": "t1",
      "sensorType": "temperature",
      "value": 40,
      "threshold": 35,
      "alarm": true,
      "createdAt": "2025-11-27T16:30:00Z"
    }
  ]
}

🧪 Run Unit Tests
./mvnw test


Coverage includes:

UDP message parsing

Wrong format handling

Regex extraction

Threshold evaluation logic

REST controller pagination + filtering

AlarmResponseMapper

Producer/consumer logic

Service layer

⚙️ Configuration
application.yml
udp:
  listeners:
    - type: TEMPERATURE
      bindHost: 0.0.0.0
      port: 3344
    - type: HUMIDITY
      bindHost: 0.0.0.0
      port: 3355
