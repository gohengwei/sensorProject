#define NEW_PRINTF_SEMANTICS
#include "serial_msg.h"
#include "printf.h"

configuration IRNodeAppC{
}
implementation {
  components MainC, IRNodeC as App, LedsC;
  components new TimerMilliC();

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;
  components PrintfC;
  components SerialStartC;

  // --------- Sensor related ---------
  components new HamamatsuS10871TsrC();

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
  components new AMReceiverC(AM_MOTE_MSG);
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.AMControl -> ActiveMessageC;
  App.AMPacket -> AMSenderC;
  App.Packet -> AMSenderC;

  
  
}
