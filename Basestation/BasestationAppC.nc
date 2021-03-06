#define NEW_PRINTF_SEMANTICS
#include "serial_msg.h"
#include "printf.h"

configuration BasestationAppC{}
implementation {

    components MainC, BasestationC as App;
    
    components new AMSenderC(AM_RADIO_MSG) as RadioSender;
    components new AMReceiverC(AM_RADIO_MSG) as RadioReceiver;
    components ActiveMessageC;
    
    components SerialActiveMessageC as Serial;

	components LedsC;

    components PrintfC;
    components new TimerMilliC() as Timer1;
    components new TimerMilliC() as Timer2;

    App.Boot -> MainC;
    
    App.RadioSend -> RadioSender.AMSend;
    App.RadioPacket -> RadioSender.Packet;
    App.RadioControl -> ActiveMessageC.SplitControl;
    App.RadioReceive -> RadioReceiver.Receive;
	App.RadioAMAccess -> RadioReceiver.AMPacket;
    
    App.SerialReceive -> Serial.Receive[AM_SERIAL_MSG]; 
    App.SerialPacket -> Serial.Packet;
    App.SerialControl -> Serial.SplitControl;
	
	App.Leds -> LedsC;
    App.Timer1 -> Timer1;
    App.Timer2 -> Timer2;
}










