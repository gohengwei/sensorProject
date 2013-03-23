#define NEW_PRINTF_SEMANTICS
#include "serial_msg.h"
#include "Timer.h"
#include "printf.h"

configuration SensorAppC{
}
implementation {
  components MainC, SensorC as App, LedsC;
  components new TimerMilliC();
  App.Boot -> MainC.Boot;
  
  App.MilliTimer -> TimerMilliC;
  App.Leds -> LedsC;
  
  components PrintfC;
  components SerialStartC;
  components HplMsp430GeneralIOC;
  App.SBcontrol -> HplMsp430GeneralIOC.Port23;

// --------- ADC related ---------
  components new SBT80_ADCconfigC() as VL;
  components new SBT80_ADCconfigC() as TEMP;

  App.ReadVL    -> VL.ReadADC0;
  App.ReadTEMP  -> TEMP.ReadADC3;

  // --------- Message related ---------
  //Serial Sender to PC
  components SerialActiveMessageC as Serial;
  App.SerialPacket -> Serial;
  App.SerialSend -> Serial.AMSend[AM_SERIAL_MSG];
  App.SerialAMControl -> Serial;

  //Receiver Mote communication
  components ActiveMessageC;
  components new AMReceiverC(AM_MOTE_MSG);
  App.Receive -> AMReceiverC;
  App.AMControl -> ActiveMessageC;
}
