
#include "printf.h"
#include "serial_msg.h"
#include "Timer.h"


//Number of LEDs to control
#define DATA_NUM 40
#define THRESHOLD 4000
////////////////////////////////////////////////////////////////////////////////////////
// Packet specification for radio_msg
// param_one --> Duration for LED 0
// param_two --> Duration for LED 1
// param_three --> Duration for LED 2
// Range of duration allowable for each param: 0 to 65000 milliseconds
 ////////////////////////////////////////////////////////////////////////////////////////
module IRNodeC {
  uses {
    interface Leds;
    interface Boot;
    interface Timer<TMilli> as MilliTimer;

    //Mote to mote communication
    interface Packet;
    interface AMPacket;
    interface Receive;
    interface AMSend;
    interface SplitControl as AMControl;

    //Serial communication
    interface AMSend as SerialSend;
    interface Packet as SerialPacket;
    interface SplitControl as SerialAMControl;

// --------- ADC related ---------
    interface Read<uint16_t> as ReadLight;
  }
}

implementation {
  /**************************************************************************
                            GLOBAL VARIABLES
  ***************************************************************************/

  //message to be sent to the PC
  message_t packet,serialPacket;
  radio_msg_t sensorData;
  uint8_t len,data_ctr;
  uint16_t sum[DATA_NUM];
  bool isDone[3] = {FALSE,FALSE,FALSE};
  bool locked, isSense = FALSE;

 /**************************************************************************
                            TASKS AND PRIVATE METHODS
  ***************************************************************************/

  //LED Indicators 
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }

  void handleState(uint8_t setting)
  {
    report_received();
    if(setting == 0x01)
    {
      isSense = TRUE;
      call MilliTimer.startPeriodic(5);
    } else if (setting == 0x00) 
    {
      call MilliTimer.stop();
      isSense = FALSE;
    }
  }
  /* 
    Simple Bubble sort algorithm for median filtering. Note function makes use of 
    global variables so as to optimize on memory by saving on the stack.
  */

  uint16_t medianFilter()
  {
    int8_t i = 0,j = 0;
    uint16_t tempVar;
    for(i = 0; i<DATA_NUM;i++)
    {
      for(j = 0;j<DATA_NUM -1;j++)
      {
        if(sum[j] > sum[j+1])
        {
          tempVar = sum[j];
          sum[j] = sum[j+1];
          sum[j+1] = tempVar;
        }
      }
    }
/*
    for(i = 0;i<DATA_NUM;i++)
    {
      printf("%i ", sum[i]);
      printfflush();  
    }
*/
    return sum[DATA_NUM/2 -1];
  }

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
      if (call SerialSend.send(AM_SERIAL_MSG, &serialPacket, sizeof(radio_msg_t)) == SUCCESS) {
        locked = TRUE;
      }
    }
  }

  void sendAirMessage()
  {
      if (locked) {
      report_problem();
      return;
    }
    else {
      //Reply with Acknowledgement

      if (call AMSend.send(LIGHT, &packet, sizeof(radio_msg_t)) == SUCCESS) {
        report_sent();
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
  }


/* -------- EVENT: Air interface start up sequence--------------- */
  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
        printf("Hi! Light Sensor Node here!\n");
        printfflush();
        //call MilliTimer.startPeriodic(5);
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
    call ReadLight.read();
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

/* -------- EVENT: Receive Message over Air interfaces-------------- */
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t _len)
	{
    if (_len == sizeof(radio_msg_t)) {
      //radio_msg_t* ptrpkt = (radio_msg_t*)(call Packet.getPayload(&packet, len));
      radio_msg_t* rcvpkt = (radio_msg_t*)payload;
      handleState(rcvpkt->param_one);
    }
    
    return msg;

  }
/****************************
  Sensor Callback for Temperature, Humidity and Light Sensors
****************************/
/*
    Based on a Vref of 1.5V
    Formula for light conversion:
     Lumens = 0.769*10000*1000*(ADC/4096)*1.5/100000
     */

 event void ReadLight.readDone(error_t result, uint16_t data) {
    int16_t val = 0;
    if (result != SUCCESS)
      {
  data = 0xffff;
  report_problem();
      }
       else  if(data_ctr == 20)
       {
          val = medianFilter();
          printf("v: %i\n",val);
          printfflush();
          //Disable Light Node due to bright condition

          if(val > THRESHOLD)
          {
            radio_msg_t* ptrpkt = (radio_msg_t*)(call Packet.getPayload(&packet, len));
            ptrpkt->param_one = 2;
            printf("sent: %i\n",val);
            printfflush();
  
            sendAirMessage();
          }
          data_ctr = 0;
       }
      {
        //Formula 
        sum[data_ctr] = data*230700/8192;// centi lumens used for better accuracy
        data_ctr++;
      }
  }

}

