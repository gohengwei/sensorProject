#include "Timer.h"
//Number of LEDs to control
#define NUM_LEDS 3
////////////////////////////////////////////////////////////////////////////////////////
// Packet specification for serial_msg
// param_one --> Duration for LED 0
// param_two --> Duration for LED 1
// param_three --> Duration for LED 2
// Range of duration allowable for each param: 0 to 65000 milliseconds
 ////////////////////////////////////////////////////////////////////////////////////////
module SerialC {
  uses {
    interface Leds;
    interface Boot;
    interface AMSend as SerialSend;
		interface Receive as SerialReceive;
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;
    interface Packet;
  }
}
implementation {
  //Global variables

  //LED duration counters
  uint16_t ledDur[NUM_LEDS] = {0,0,0};
  uint16_t ledVal[NUM_LEDS] = {0,0,0};
  //message to be sent to the PC
  message_t packet;

  bool locked;
  uint32_t counter = 0;
  
  event void Boot.booted() {
    call AMControl.start();
    call MilliTimer.startPeriodic(1);
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
 
	void sendMessage(); 
  
	event void MilliTimer.fired() {
    uint8_t i = 0;
		//sendMessage();
    for(i = 0;i<NUM_LEDS;i++)
    {
      if(ledVal[i] < ledDur[i]) ledVal[i]++;
      else 
      {
        call Leds.set(call Leds.get() & ~(1<<i));
      }
    }

    //Stop timer interrupt from continuously triggering to save on power
    if(call Leds.get() == 0)
    {
      call MilliTimer.stop();
    }
	}
	
  /* 
    Message was received successfully, reply with acknowledgement
    param_one = 1 indicates successful ack sent
  */
	void sendMessage()
	{
  	if (locked) {
			return;
    }
    else {
     	serial_msg_t* rcm = (serial_msg_t *)call Packet.getPayload(&packet, sizeof(serial_msg_t));
     	if (rcm == NULL) {
				return;
     	}
      //Reply with Acknowledgement
     	rcm->param_one= 1 ;
     	if (call SerialSend.send(126, &packet, sizeof(serial_msg_t)) == SUCCESS) {
				locked = TRUE;
     	}
    }
  }

  event void SerialSend.sendDone(message_t* bufPtr, error_t error)
	{
		locked = FALSE;
  }

/*
  Read parameters sent from PC and store the duration required for each Led. Initialise the leds and start the timer. 
*/
	event message_t* SerialReceive.receive(message_t* bufPtr, void* payload, uint8_t len)
	{
		serial_msg_t* rcm = (serial_msg_t *)(payload);
		ledDur[0] = rcm->param_one;
    ledDur[1] = rcm->param_two;
    ledDur[2] = rcm->param_three;

    call MilliTimer.startPeriodic(1);
    ledVal[0]=0;
    ledVal[1]=0;
    ledVal[2]=0;
    call Leds.led1On();
    call Leds.led2On();
    call Leds.led0On();
    sendMessage();
		return bufPtr;
	}
			
}
