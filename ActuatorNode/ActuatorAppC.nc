#define NEW_PRINTF_SEMANTICS
#include "Timer.h"
#include "serial_msg.h"
#include "printf.h"

configuration ActuatorAppC{
}
implementation {
	components MainC, ActuatorC as App, LedsC;
	components new TimerMilliC();
	App.Boot -> MainC.Boot;
	App.MilliTimer -> TimerMilliC;

	components PrintfC;
	components SerialStartC;
	components	HplMsp430GeneralIOC;
	App.GPIO -> HplMsp430GeneralIOC.Port23;
	App.Leds -> LedsC;

	//Receiver Mote communication
	components ActiveMessageC;
	components new AMReceiverC(AM_MOTE_MSG);
  	App.Receive -> AMReceiverC;
  	App.Packet -> AMReceiverC;
  	App.AMControl -> ActiveMessageC;
}
