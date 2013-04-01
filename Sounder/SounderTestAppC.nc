#include "serial_msg.h"

configuration SounderTestAppC{}
implementation {

    components MainC, SounderTestC as App, LedsC;
    components SounderC; 
    components new TimerMilliC() as Timer;
    
    components new AMReceiverC(AM_RADIO_MSG) as RadioReceiver;
    components ActiveMessageC;
    
    App.RadioControl -> ActiveMessageC.SplitControl;
    App.RadioReceive -> RadioReceiver.Receive;
    	
    App.Boot -> MainC.Boot;
    App.Timer -> Timer;
    App.Leds -> LedsC;
    App.Mts300Sounder -> SounderC;

}
