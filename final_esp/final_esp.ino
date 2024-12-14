#include <Arduino.h>
#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>
#include "DHT.h"
#include <HTTPClient.h>

// Provide the token generation process info.
#include "addons/TokenHelper.h"
// Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"  // Real Time DataBase

#define WIFI_SSID "habiba"
#define WIFI_PASSWORD "00000000"

// Insert Firebase project API Key
#define API_KEY "AIzaSyCvS7Qe_0Bh9crrqlz-tF23UVphZQ0LdT0"

// Insert RTDB URL
#define DATABASE_URL "https://sohila-1efc2-default-rtdb.firebaseio.com/"

#define FIREBASE_PROJECT_ID "sohila-1efc2"

FirebaseData fbdoVoltage;
FirebaseData fbdoCurrent;
FirebaseData fbdoSpeed;
FirebaseData fbdoT;
FirebaseData fbdoH;
FirebaseJson json;

FirebaseAuth auth; // Authentication
FirebaseConfig config; // Configuration

unsigned long sendDataPrevMillis = 0;
bool signupOK = false;

// DHT Sensor setup
#define DHTPIN 21
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// Voltage sensor setup
const int VOLTAGE_SENSOR_PIN = 35;

// Current sensor setup
const int CURRENT_SENSOR_PIN = 34;

// IR Photoelectric Encoder Sensor
const int ENCODER_PIN = 4;
volatile int encoderCount = 0;

// Calibration constants (adjust based on your sensors)
const float VOLTAGE_CALIBRATION = 5.0; // Adjust based on voltage divider
const float CURRENT_CALIBRATION = 10.0; // Adjust based on sensor specs

void IRAM_ATTR handleEncoder() {
  encoderCount++;
}

void setup() {
  Serial.begin(115200);
  pinMode(ENCODER_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(ENCODER_PIN), handleEncoder, RISING);

  dht.begin();

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  /* Assign the API key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("ok");
    signupOK = true;
  } else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

float readVoltage() {
  int analogValue = analogRead(VOLTAGE_SENSOR_PIN);
  return (analogValue / 4095.0) * VOLTAGE_CALIBRATION;
}

float readCurrent() {
  int analogValue = analogRead(CURRENT_SENSOR_PIN);
  return (analogValue / 4095.0) * CURRENT_CALIBRATION;
}

void uploadDocument(float humidity, float temp, float voltage, float current, int speed) {
  String documentId = String(millis()); // Use the current time in milliseconds as the document ID

  json.set("fields/humidity/doubleValue", humidity);
  json.set("fields/temp/doubleValue", temp);
  json.set("fields/voltage/doubleValue", voltage);
  json.set("fields/current/doubleValue", current);
  json.set("fields/speed/integerValue", speed);

  if (Firebase.Firestore.createDocument(&fbdoVoltage, FIREBASE_PROJECT_ID, "", "sensors/" + documentId, json.raw())) {
    Serial.println("New document created successfully!");
  } else {
    Serial.println("Error creating new document: " + fbdoVoltage.errorReason());
  }
}

void loop() {
  float humidity = dht.readHumidity();
  float temperatureC = dht.readTemperature();

  float voltage = readVoltage();
  float current = readCurrent();

  int speed = encoderCount; // Get the encoder count
  encoderCount = 0;         // Reset encoder count for next cycle

  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 1000 || sendDataPrevMillis == 0)) {
    sendDataPrevMillis = millis();

    if (Firebase.RTDB.setFloat(&fbdoVoltage, "sensors/voltage", voltage)) {
      Serial.println("Voltage sent");
    } else {
      Serial.println("FAILED: " + fbdoVoltage.errorReason());
    }

    if (Firebase.RTDB.setFloat(&fbdoCurrent, "sensors/current", current)) {
      Serial.println("Current sent");
    } else {
      Serial.println("FAILED: " + fbdoCurrent.errorReason());
    }

    if (Firebase.RTDB.setInt(&fbdoSpeed, "sensors/speed", speed)) {
      Serial.println("Speed sent");
    } else {
      Serial.println("FAILED: " + fbdoSpeed.errorReason());
    }

    if (Firebase.RTDB.setFloat(&fbdoT, "dht/temp", temperatureC)) {
      Serial.println("Temperature sent");
    } else {
      Serial.println("FAILED: " + fbdoT.errorReason());
    }

    if (Firebase.RTDB.setFloat(&fbdoH, "dht/humidity", humidity)) {
      Serial.println("Humidity sent");
    } else {
      Serial.println("FAILED: " + fbdoH.errorReason());
    }

    uploadDocument(humidity, temperatureC, voltage, current, speed);
  }
}
