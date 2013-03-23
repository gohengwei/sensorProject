#include "Timer.h"
#include "serial_msg.h"
#include "SBT80ADCmap.h"
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
module SensorC {
  uses {
    interface Leds;
    interface Boot;

    interface Timer<TMilli> as MilliTimer;
    interface Read<uint16_t> as ReadVL;
    interface Read<uint16_t> as ReadTEMP;

    interface HplMsp430GeneralIO as SBcontrol;
    interface HplMsp430GeneralIO as SBswitch;

    interface Packet;
    interface Packet as SerialPacket;
    interface Receive;
    interface AMPacket;
    interface SplitControl as AMControl;
    interface SplitControl as SerialAMControl;
    interface AMSend as SerialSend;
  }
}
implementation {
  /**************************************************************************
                            GLOBAL VARIABLES
  ***************************************************************************/

   //message to be sent to the PC
  message_t packet;
  serial_msg_t* sensorData;

  uint8_t len;
  bool isDone[3] = {FALSE,FALSE,FALSE};
  bool locked;
  uint32_t counter = 0;


 /**************************************************************************
                            TASKS AND PRIVATE METHODS
  ***************************************************************************/

  //LED Indicators 
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }


  /* -------- TASK : Collect data from all the sensors --------------- */
  void task getData()
  {
    report_received();
    call ReadVL.read();
    call ReadTEMP.read();
  }


  /* 
    Message was received successfully, reply with acknowledgement
    param_one = 1 indicates successful ack sent
  */
  void sendMessage()
  {
    report_sent();
    if (locked) {
      return;
    }
    else {
      serial_msg_t* pkptr = (serial_msg_t *)call SerialPacket.getPayload(&packet, sizeof(serial_msg_t));
      if (pkptr == NULL) {
        return;
      }
      //Reply with Acknowledgement
            if (call SerialSend.send(126, &packet, sizeof(serial_msg_t)) == SUCCESS) {
        locked = TRUE;
      }
    }
  }


  /**************************************************************************
                            EVENT CALLBACKS
  ***************************************************************************/



/* --------  EVENT: Boot up sequence for sensors and air interface--------------- */
  event void Boot.booted() {
    call AMControl.start();
       /* Wake up the sensor board */
    call SBcontrol.clr();
    call SBcontrol.makeOutput();
    call SBcontrol.selectIOFunc();
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

  }
    /* -------- EVENT: Receive from Neighbouring Node--------------- */

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t _len)
  {

    if (_len == sizeof(serial_msg_t)) {
    serial_msg_t* ptrpkt = (serial_msg_t*)(call SerialPacket.getPayload(&packet, len));
    serial_msg_t* rcvpkt = (serial_msg_t*)payload;
    ptrpkt->param_one = rcvpkt->param_one;
    ptrpkt->param_two = rcvpkt->param_two;
    ptrpkt->param_three = rcvpkt->param_three;
    len = _len;
    report_received();
    post getData();
    }
  
    return msg;
  }

  event void SerialSend.sendDone(message_t* bufPtr, error_t error)
  {
    locked = FALSE;
    isDone[0] = FALSE;
    isDone[1] = FALSE;
    report_sent();
  }

  
/****************************
  Sensor Event Callback for Temperature and Light Sensors
****************************/

/* -------- EVENT: Read Light data  --------------- */
  event void ReadVL.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS)
      {
        data = 0xffff;
        report_problem();
      } 
      else  
      {
        //report_received();
        serial_msg_t* ptrpkt = (serial_msg_t*)(call SerialPacket.getPayload(&packet, len));
        ptrpkt->param_four = data;
        isDone[0] = TRUE;
        if(isDone[0] && isDone[1]) sendMessage();
      }

  }

/* -------- EVENT: Read TEMP data  --------------- 
  Formula for temperature conversion based on formula and constants from datasheet
  http://www.easysen.com/support/Datasheets/TempSensor_MAX6612MXK_Maxim.pdf*/
   event void ReadTEMP.readDone(error_t result, uint16_t data) {
    double temp;
    if (result != SUCCESS)
      {
  data = 0xffff;
  report_problem();
      } 
      else  
      {
        serial_msg_t* ptrpkt = (serial_msg_t*)(call SerialPacket.getPayload(&packet, len));
        //Formula for temperature conversion
        temp = ((data*0.0007324) -0.4)/0.01953;
        ptrpkt->param_five = temp;
        isDone[1] = TRUE;
        if(isDone[0] && isDone[1]) sendMessage();
      }
  }

}


