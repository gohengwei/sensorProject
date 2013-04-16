#include "Timer.h"
#include "serial_msg.h"
#include "printf.h"

module ActuatorC {
  uses {
    interface Boot;
    interface Leds;
    interface HplMsp430GeneralIO as GPIO;


    interface Timer<TMilli> as MilliTimer;
    interface Packet;
    interface Receive;
    interface AMPacket;
    interface SplitControl as AMControl;
  }
}
  implementation {
  	message_t packet;
  	radio_msg_t* actuatorData;
    bool isBright = FALSE;
    int len;

  //LED Indicators 
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }

  void handleGPIO(uint8_t setting)
  {
    switch(setting)
    {
      //Reset system and go back to sleep
      case 0:
        call GPIO.clr();
        printf("disable");
        printfflush();

        isBright = FALSE;
        break;
      case 3:
        printf("enable");
        printfflush();

        if(!isBright)
        {
          call GPIO.set();
          call Leds.led0On();
        }
        break;
      case 2:
        printf("bright");
        printfflush();

        isBright = TRUE;
        call GPIO.clr();
        call Leds.led0Off();
        break;
      default:
        break;
    } 
  }
  /**************************************************************************
                            EVENT CALLBACKS
  ***************************************************************************/

/* --------  EVENT: Boot up sequence for sensors and air interface--------------- */
  event void Boot.booted() {
       call AMControl.start();
       /* Wake up the sensor board */
   
    call GPIO.makeOutput();
    call GPIO.selectIOFunc();
    call GPIO.clr();
  
    //call GPIO.makeOutput();
    //call GPIO.selectIOFunc();
  }

/* -------- EVENT: Air interface start up sequence--------------- */
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Hi! Actuator Node here!\n");
      printfflush();
      call GPIO.clr();
    }
    else {
      call AMControl.start();
      report_problem();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }

   /* -------- EVENT: Receive from Neighbouring Node--------------- */

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t _len)
  {
    	
    if (_len == sizeof(radio_msg_t)) {
    radio_msg_t* ptrpkt = (radio_msg_t*)(call Packet.getPayload(&packet, len));
    radio_msg_t* rcvpkt = (radio_msg_t*)payload;
    ptrpkt->param_one = rcvpkt->param_one;
    //len = _len;
    handleGPIO(rcvpkt->param_one);
    }
  	
    return msg;
  }
  /* -------- EVENT: Timer fire event--------------- */
  event void MilliTimer.fired() {
    
  }

}
