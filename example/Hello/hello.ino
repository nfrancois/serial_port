/*

 Just say Hello !

*/

void setup() {
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    Serial.println("Hello");
    delay(5000);
  }
}
