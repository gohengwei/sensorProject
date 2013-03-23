
#include "serial_msg.h"
#include "Timer.h"
#include "printf.h"
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
    interface Timer<TMilli> as MilliTimer;

    //Mote to mote communication
    interface Packet;
    interface AMPacket;
    interface AMSend;
    interface SplitControl as AMControl;

    //Serial communication
    interface AMSend as SerialSend;
    interface Packet as SerialPacket;
    interface SplitControl as SerialAMControl;

// --------- ADC related ---------
    interface Read<uint16_t> as ReadTemp;
    interface Read<uint16_t> as ReadHumidity;
    interface Read<uint16_t> as ReadLight;
    
  }
}
implementation {
  /**************************************************************************
                            GLOBAL VARIABLES
  ***************************************************************************/

  //message to be sent to the PC
  message_t packet,serialPacket;
  serial_msg_t sensorData;
  uint8_t len;

  bool isDone[3] = {FALSE,FALSE,FALSE};
  bool locked;

 /**************************************************************************
                            TASKS AND PRIVATE METHODS
  ***************************************************************************/

  //LED Indicators 
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }

  /* 
    Message was received successfully, reply with acknowledgement
    param_one = 1 indicates successful ack sent
  */
  void sendSerialMessage()
  {
        if (locked) {
      report_problem();
      return;
    }
    else {
      //Reply with Acknowledgement
      if (call SerialSend.send(126, &serialPacket, sizeof(serial_msg_t)) == SUCCESS) {
        locked = TRUE;
      }
    }
  }

  void sendAirMessage()
  {
      report_sent();
      if (locked) {
      report_problem();
      return;
    }
    else {
      //Reply with Acknowledgement
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(serial_msg_t)) == SUCCESS) {
        locked = TRUE;
      }
    }

  }

  /**************************************************************************
                            EVENT CALLBACKS
  ***************************************************************************/

  event void Boot.booted() {
    call AMControl.start();
    call SerialAMControl.start();
    call MilliTimer.startPeriodic(2000);
  }


/* -------- EVENT: Air interface start up sequence--------------- */
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
  
/* -------- EVENT: Serial interface start up sequence--------------- */
  event void SerialAMControl.startDone(error_t err) {
    if (err == SUCCESS) {
    }
    else {
      call SerialAMControl.start();
    }
  }

  event void SerialAMControl.stopDone(error_t err) {
    // do nothing
  }
  
	event void MilliTimer.fired() {
    call ReadHumidity.read();
    call ReadLight.read();
    call ReadTemp.read();
    report_received();
	}
/* -------- EVENT: Message over Serial and Air interfaces-------------- */

 event void AMSend.sendDone(message_t* msg, error_t error) {
    if (&packet == msg) {
      report_sent();
      locked = FALSE;
      sendSerialMessage();
      report_received();
    }
  }

  event void SerialSend.sendDone(message_t* bufPtr, error_t error)
	{
    report_received();
		locked = FALSE;
    isDone[0] = FALSE;
    isDone[1] = FALSE;
    isDone[2] = FALSE;
  }
	
/****************************
  Sensor Callback for Temperature, Humidity and Light Sensors
****************************/

/*
    Based on multimeter reading of 3V on AVCC and 14bit Temperature
     Constants taken from datasheet
     */
  event void ReadTemp.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS)
      {
        data = 0xffff;
       report_problem();
      } 
      else  
      {
         serial_msg_t* ptrpkt = (serial_msg_t*)(call Packet.getPayload(&packet, len));
         data = -39.6 + 0.01*data;
         ptrpkt->param_one = data;
         ptrpkt = (serial_msg_t*)(call SerialPacket.getPayload(&serialPacket, len));
         ptrpkt->param_one = data;
         isDone[0] = TRUE;
         if(isDone[0] && isDone[1] && isDone[2]) sendAirMessage();
      }

  }
  /*
    Based on multimeter reading of 3V on AVCC and 12bit Humidity
     Constants taken from datasheet
     */
   event void ReadHumidity.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS)
      {
  data = 0xffff;
  report_problem();
      } 
      else  
      {
        serial_msg_t* ptrpkt = (serial_msg_t*)(call Packet.getPayload(&packet, len));
        //Formula for Humidity Sensor Conversion
        data = -2.0468 + 0.0367*data +  -0.0000015955*data*data;
        ptrpkt->param_two = data;
        ptrpkt = (serial_msg_t*)(call SerialPacket.getPayload(&serialPacket, len));
        ptrpkt->param_two = data;
        isDone[1] = TRUE;
        if(isDone[0] && isDone[1] && isDone[2]) sendAirMessage();
      }
  }

/*
    Based on a Vref of 1.5V
    Formula for light conversion:
     Lumens = 0.769*10000*1000*(ADC/4096)*1.5/100000
     */

 event void ReadLight.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS)
      {
  data = 0xffff;
  report_problem();
      }
       else  
      {
        serial_msg_t* ptrpkt = (serial_msg_t*)(call Packet.getPayload(&packet, len));
        //Formula 
        data = data*2307000/8192;// Milli lumens used for better accuracy
        ptrpkt->param_three = data;
        ptrpkt = (serial_msg_t*)(call SerialPacket.getPayload(&serialPacket, len));
        ptrpkt->param_three = data;
        isDone[2] = TRUE;
        if(isDone[0] && isDone[1] && isDone[2]) sendAirMessage();
      }
  }

}

