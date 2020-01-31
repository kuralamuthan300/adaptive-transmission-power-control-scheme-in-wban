#include <XBee.h>

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
    delay(5000);
}

void loop()
{
    xbee.readPacket(100);
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
            Serial.print(-1*rx16.getRssi());
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
            Serial.println("Close");
        }
    }
}0
