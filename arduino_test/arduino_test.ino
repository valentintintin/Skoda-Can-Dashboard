void setup() {
  Serial.begin(115200);
}

void loop() {
  Serial.println("10915673,00000366,false,Rx,1,8,00,00,00,00,00,00,00,00,"); delay(100);
  Serial.println("13982008,00000366,false,Rx,1,8,00,00,80,0A,00,00,00,00,"); delay(100);
  Serial.println("14381753,00000366,false,Rx,1,8,00,00,80,00,00,00,00,00,"); delay(100);
  Serial.println("13982008,00000366,false,Rx,1,8,00,00,80,0A,00,00,00,00,"); delay(100);
  Serial.println("13915480,00000366,false,Rx,1,8,00,00,00,00,00,00,00,00,"); delay(100);

  delay(1000);
}
