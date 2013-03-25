#define NEW_PRINTF_SEMANTICS
#include "serial_msg.h"
#include "printf.h"

configuration SerialAppC{
}
implementation {
  components MainC, SerialC as App, LedsC;
  components new TimerMilliC();

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;
  components PrintfC;
  components SerialStartC;

  // --------- Sensor related ---------
  components new SensirionSht11C();
  components new HamamatsuS10871TsrC();

  App.ReadTemp -> SensirionSht11C.Temperature;
  App.ReadHumidity -> SensirionSht11C.Humidity;
  App.ReadLight -> HamamatsuS10871TsrC;

  // --------- Message related ---------
  //Serial Sender to PC
  components SerialActiveMessageC as Serial;
  App.SerialPacket -> Serial;
  App.SerialSend -> Serial.AMSend[AM_SERIAL_MSG];
  App.SerialAMControl -> Serial;

  //Receiver Mote communication
  components ActiveMessageC;
  components new AMSenderC(AM_MOTE_MSG);
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMPacket -> AMSenderC;
  App.Packet -> AMSenderC;

  
  
}
