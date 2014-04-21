/*

PING PING exchanges

*/

char character;
String content = "";
const char* PING = "ping";
bool ready = true;

void setup() {
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    character = Serial.read();
    content.concat(character);
    if (strcmp(content.c_str(), PING) == 0) {
      Serial.print("pong");
      content = "";
    }
  }
}
