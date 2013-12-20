/*



*/

char character;
String content = "";

void setup() {
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    character = Serial.read();
    content.concat(character);
    if (character == '\n') {
      Serial.print(content);
      content = "pong: ";
    }
  }
}