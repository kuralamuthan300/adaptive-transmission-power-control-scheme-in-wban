#include <XBee.h>
#include <SD.h>
#include <SPI.h>
//SD card
File sdcard_file;
int CS_pin = 53;

//Xbee

int count=1;
int start = 1;
XBee xbee = XBee();

typedef struct XBeeStruct {
  float x1;
  float y1;
  float z1;
  float x2;
  float y2;
  float z2;
} XBeeDataStruct;

static XBeeDataStruct XBeeData;


//Recieve Variables
Rx16Response rx16 = Rx16Response();
uint8_t* data = 0;
int len = 0;

void setup()
{
    Serial.begin(9600);
    xbee.setSerial(Serial3);
    Serial3.begin(9600);
    //SD Card
    pinMode(CS_pin, OUTPUT);//declaring CS pin as output pin
    if (SD.begin())
    {
      Serial.println("SD card is initialized and it is ready to use");
    } else
    {
    Serial.println("SD card is not initialized");
    return;
    }
   

    //Time to initialize XBee 
    delay(5000);
}

void loop()
{
    
    sdcard_file = SD.open("data.txt", FILE_WRITE); //Looking for the data.txt in SD card
    xbee.readPacket(10);
    if (xbee.getResponse().isAvailable())
    {
        if (xbee.getResponse().getApiId() == RX_16_RESPONSE)
        {
            xbee.getResponse().getRx16Response(rx16);
            data = rx16.getData();
            len = rx16.getDataLength();
            XBeeData = (XBeeDataStruct &)*data;
            //Print.
            Serial.println("Data Obtained:");
            Serial.print("\tRSSI = ");
            int RSSI_VALUE = -1*rx16.getRssi(); 
            Serial.print(RSSI_VALUE);
            Serial.print("\tAccX = ");
            Serial.print(XBeeData.x1);
            Serial.print("\tAccY = ");
            Serial.print(XBeeData.y1);
            Serial.println();
            Serial.print("\tAccZ = ");
            Serial.print(XBeeData.z1);
            Serial.print("\tGyroX = ");
            Serial.print(XBeeData.x2);
            Serial.println();
            Serial.print("\tGyroY = ");
            Serial.print(XBeeData.y2);
            Serial.print("\tGyroZ = ");
            Serial.print(XBeeData.z2);
            Serial.println();
            

            count++;
            sdcard_file.print(count-1);
            sdcard_file.print(',');
            sdcard_file.print(RSSI_VALUE);
            sdcard_file.print(',');
            sdcard_file.print(XBeeData.x1);
            sdcard_file.print(',');
            sdcard_file.print(XBeeData.y1);
            sdcard_file.print(',');
            sdcard_file.print(XBeeData.z1);
            sdcard_file.print(',');
            sdcard_file.print(XBeeData.x2);
            sdcard_file.print(',');
            sdcard_file.print(XBeeData.y2);
            sdcard_file.print(',');
            sdcard_file.print(XBeeData.z2);
            sdcard_file.print("\n");
            
            sdcard_file.close();
      
            Serial.println(count-1);
            Serial.println("Close");
            
        }
    }
   
}
