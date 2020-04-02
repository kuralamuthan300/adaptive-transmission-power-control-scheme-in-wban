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


//Ack packet
typedef struct AckStruct {
  boolean flag = true;
} AckPacketStruct;
static AckPacketStruct AckData;



//Recieve Variables
Rx16Response rx16 = Rx16Response();
uint8_t* data = 0;
int len = 0;
long sequence = 1;

void setup()
{
    
    xbee.setSerial(Serial2);
    Serial2.begin(9600);
    //SD Card
    pinMode(CS_pin, OUTPUT);//declaring CS pin as output pin
    if (SD.begin())
    {
      //Serial.println("SD card is initialized and it is ready to use");
    } else
    {
    //Serial.println("SD card is not initialized");
    return;
    }

    while(1){
    xbee.readPacket(10);
    if (xbee.getResponse().isAvailable())
    {
        if (xbee.getResponse().getApiId() == RX_16_RESPONSE)
        {
            xbee.getResponse().getRx16Response(rx16);
            data = rx16.getData();
            len = rx16.getDataLength();
            AckData = (AckPacketStruct &)*data;
            
            if(AckData.flag == false)
            {
            XBeeAddress64 addr64 = XBeeAddress64(0x0000, 0xFFFF);
            Tx16Request tx16 = Tx16Request(addr64, (uint8_t *)&AckData, sizeof(AckPacketStruct));
            xbee.send( tx16 );
            }
        }
    }  
    }

    //Time to initialize XBee 
    delay(5000);
}

void write_to_SD(float x1,float y1,float z1,float x2,float y2,float z2,int count,int RSSI_VALUE,long seq)
{
            sdcard_file = SD.open("data.csv", FILE_WRITE); //Looking for the data.txt in SD card
            sdcard_file.print(count-1);
            sdcard_file.print(',');
            sdcard_file.print(RSSI_VALUE);
            sdcard_file.print(',');
            sdcard_file.print(x1);
            sdcard_file.print(',');
            sdcard_file.print(y1);
            sdcard_file.print(',');
            sdcard_file.print(z1);
            sdcard_file.print(',');
            sdcard_file.print(x2);
            sdcard_file.print(',');
            sdcard_file.print(y2);
            sdcard_file.print(',');
            sdcard_file.print(z2);
            sdcard_file.print(',');
            sdcard_file.print(seq);
            sdcard_file.print("\n");
            
            sdcard_file.close();
   

   
  
  }
void loop()
{
    
   
    xbee.readPacket(10);
    if (xbee.getResponse().isAvailable())
    {
        if (xbee.getResponse().getApiId() == RX_16_RESPONSE)
        {
            xbee.getResponse().getRx16Response(rx16);
            data = rx16.getData();
            len = rx16.getDataLength();
            XBeeData = (XBeeDataStruct &)*data;
            int RSSI_VALUE = -1*rx16.getRssi();
            //Print.
            /*
            Serial.println("Data Obtained:");
            Serial.print("\tRSSI = ");
             
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
            */

            count++;
            write_to_SD(XBeeData.x1,XBeeData.y1,XBeeData.z1,XBeeData.x2,XBeeData.y2,XBeeData.z2,count-1,XBeeData.rssi,XBeeData.seq);

            //Sending ACK Packets
            XBeeAddress64 addr64 = XBeeAddress64(0x0000, 0xFFFF);
            Tx16Request tx16 = Tx16Request(addr64, (uint8_t *)&AckData, sizeof(AckPacketStruct));
            xbee.send( tx16 );
            
            //Serial.println(count-1);
            //Serial.println("Close");
            
        }
    }
   
}
