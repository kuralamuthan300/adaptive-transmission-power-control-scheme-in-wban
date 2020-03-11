#include <XBee.h>
#include <Wire.h>

//Xbee struct
typedef struct XBeeStruct {
  long seq;
  float x1;
  float y1;
  float z1;
  float x2;
  float y2;
  float z2;
} XBeeDataStruct;
static XBeeDataStruct XBeeData;
XBee xbee = XBee();

long sequence=1;
//MPU6050
const int MPU = 0x68;

//label button

void setup()
{
    Serial.begin(9600);
    //MPU6050
    Wire.begin();                      
    Wire.beginTransmission(MPU);       
    Wire.write(0x6B);                 
    Wire.write(0x00);                  
    Wire.endTransmission(true);

   


    //To initialize Xbee Modules
    delay(5000);
}

void loop()
{
  //Activity label
   
    //Accellerometer
    Wire.beginTransmission(MPU);
    Wire.write(0x3B); 
    Wire.endTransmission(false);
    Wire.requestFrom(MPU, 6, true);

    XBeeData.x1 = (Wire.read() << 8 | Wire.read()) / 16384.0; // X-axis value
    XBeeData.y1 = (Wire.read() << 8 | Wire.read()) / 16384.0; // Y-axis value
    XBeeData.z1= (Wire.read() << 8 | Wire.read()) / 16384.0;


    //Gyroscope

    Wire.beginTransmission(MPU);
    Wire.write(0x43); 
    Wire.endTransmission(false);
    Wire.requestFrom(MPU, 6, true); 
    XBeeData.x2 = (Wire.read() << 8 | Wire.read()) / 131.0; 
    XBeeData.y2 = (Wire.read() << 8 | Wire.read()) / 131.0;
    XBeeData.z2 = (Wire.read() << 8 | Wire.read()) / 131.0;

    XBeeData.seq = sequence;
    sequence++; 

    
    XBeeAddress64 addr64 = XBeeAddress64(0x0000, 0xFFFF);
    Tx16Request tx16 = Tx16Request(addr64, (uint8_t *)&XBeeData, sizeof(XBeeDataStruct));

    
    xbee.send( tx16 );
}
