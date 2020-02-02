//https://electronicshobbyists.com/arduino-sd-card-shield-tutorial-arduino-data-logger/
//cs pin changed
#include <SD.h>
#include <SPI.h>
File sdcard_file;
int CS_pin = 53; 
void setup() {
 Serial.begin(9600); //Setting baudrate at 9600
 pinMode(CS_pin, OUTPUT);//declaring CS pin as output pin
 if (SD.begin())
 {
 Serial.println("SD card is initialized and it is ready to use");
 } else
 {
 Serial.println("SD card is not initialized");
 return;
 }
 
 sdcard_file = SD.open("data.csv", FILE_WRITE); //Looking for the data.txt in SD card
 
 if (sdcard_file) { //If the file is found
 Serial.println("Writing to file is under process");
 sdcard_file.println("1,2,3,4,5,6"); //Writing to file
 sdcard_file.close(); //Closing the file
 Serial.println("Done");
 }
 else {
 Serial.println("Failed to open the file");
 }
 
 }
void loop() {
//Nothing in the loop
 }
