/*

 Just say Hello  every 5 seconds !

*/

void setup() {
  Serial.begin(9600);
}

void loop() {
    Serial.println("Hello");
    delay(5000);
}
