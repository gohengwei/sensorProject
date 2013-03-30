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
  	serial_msg_t* actuatorData;

  //LED Indicators 
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }

  /**************************************************************************
                            EVENT CALLBACKS
  ***************************************************************************/

/* --------  EVENT: Boot up sequence for sensors and air interface--------------- */
  event void Boot.booted() {
    report_sent();
    call MilliTimer.startPeriodic(1000);
/*
    while(1)
    {
      printf("Hi!!\n");
      printfflush();
    }
    */
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
      report_received();
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
  	/*
    if (_len == sizeof(serial_msg_t)) {
    serial_msg_t* ptrpkt = (serial_msg_t*)(call SerialPacket.getPayload(&packet, len));
    serial_msg_t* rcvpkt = (serial_msg_t*)payload;
    ptrpkt->param_one = rcvpkt->param_one;
    ptrpkt->param_two = rcvpkt->param_two;
    ptrpkt->param_three = rcvpkt->param_three;
    len = _len;
    post getData();
    }
  	*/
    return msg;
  }
  /* -------- EVENT: Timer fire event--------------- */
  event void MilliTimer.fired() {
    call GPIO.toggle();
  }

}
