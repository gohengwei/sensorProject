#include "serial_msg.h"

configuration BasestationAppC{}
implementation {

    components MainC, BasestationC as App;
    
    components new AMSenderC(AM_RADIO_MSG) as RadioSender;
    components new AMReceiverC(AM_RADIO_MSG) as RadioReceiver;
    components ActiveMessageC;
    
    components SerialActiveMessageC as Serial;

	components LedsC;

    App.Boot -> MainC.Boot;
    
    App.RadioSend -> RadioSender.AMSend;
    App.RadioPacket -> RadioSender.Packet;
    App.RadioControl -> ActiveMessageC.SplitControl;
    App.RadioReceive -> RadioReceiver.Receive;
	App.RadioAMAccess -> RadioReceiver.AMPacket;
    
    App.SerialReceive -> Serial.Receive[AM_SERIAL_MSG]; 
    App.SerialPacket -> Serial.Packet;
    App.SerialControl -> Serial.SplitControl;
	
	App.Leds -> LedsC;
}










