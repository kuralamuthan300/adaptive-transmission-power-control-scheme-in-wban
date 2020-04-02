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
  int rssi;
} XBeeDataStruct;
static XBeeDataStruct XBeeData;


//Ack packet and ecieve variables
typedef struct AckStruct {
  boolean flag = false;
} AckPacketStruct;
static AckPacketStruct AckData;
Rx16Response rx16 = Rx16Response();
uint8_t* data = 0;





XBee xbee = XBee();
long sequence=1;
int lastRSSI=0;
int len = 0;

//MPU6050
const int MPU = 0x68;

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

    while(1){
    //Send init packets to initialize connection
   
    XBeeAddress64 addr64 = XBeeAddress64(0x0000, 0xFFFF);
    Tx16Request tx16 = Tx16Request(addr64, (uint8_t *)&AckData, sizeof(AckPacketStruct));
    xbee.send( tx16 );

    xbee.readPacket(10);
    if (xbee.getResponse().isAvailable())
    {
        if (xbee.getResponse().getApiId() == RX_16_RESPONSE)
        {
            xbee.getResponse().getRx16Response(rx16);
            data = rx16.getData();
            len = rx16.getDataLength();
            AckData = (AckPacketStruct &)*data;
            if(AckData.flag == true)
            {
              int lastRSSI = -1*rx16.getRssi();
              break;
            }
        }
    }
  }
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
    XBeeData.rssi = lastRSSI;

    
    XBeeAddress64 addr64 = XBeeAddress64(0x0000, 0xFFFF);
    Tx16Request tx16 = Tx16Request(addr64, (uint8_t *)&XBeeData, sizeof(XBeeDataStruct));
    xbee.send( tx16 );

    //Recieving ACK Packet
    xbee.readPacket(10);
    if (xbee.getResponse().isAvailable())
    {
        if (xbee.getResponse().getApiId() == RX_16_RESPONSE)
        {
            xbee.getResponse().getRx16Response(rx16);
            data = rx16.getData();
            len = rx16.getDataLength();
            AckData = (AckPacketStruct &)*data;
            if(AckData.flag == true)
            {
              int lastRSSI = -1*rx16.getRssi();
            }
        }
    }
}
