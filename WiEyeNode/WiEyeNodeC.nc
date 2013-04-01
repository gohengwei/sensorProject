/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Oscilloscope demo application. See README.txt file in this directory.
 *
 * @author David Gay
 */
#include "Timer.h"
#include "Oscilloscope.h"
#include "SBT80ADCmap.h"
#include "serial_msg.h"

module WiEyeNodeC @safe()
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface AMSend;
    interface Receive;
    interface Timer<TMilli>;
    interface Read<uint16_t> as ReadVL;
    interface Leds;
    interface HplMsp430GeneralIO as SBcontrol;
  }
}
implementation
{
  message_t sendBuf, packet_1;
  bool sendBusy;
  int wakeUp;

  /* Current local state - interval, version and accumulated readings */
  oscilloscope_t local;

  uint8_t reading; /* 0 to NREADINGS */

  /* When we head an Oscilloscope message, we check it's sample count. If
     it's ahead of ours, we "jump" forwards (set our count to the received
     count). However, we must then suppress our next count increment. This
     is a very simple form of "time" synchronization (for an abstract
     notion of time). */
  bool suppressCountChange;

  // Use LEDs to report various status issues.
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }
void sendMessage()
	{
		serial_msg_t* rcm = (serial_msg_t *)call AMSend.getPayload(&packet_1, sizeof(serial_msg_t));
		rcm->param_one=1;
		call AMSend.send(AM_BROADCAST_ADDR, &packet_1, sizeof(serial_msg_t));
			
	}

  event void Boot.booted() {
    wakeUp=0;
    local.interval = DEFAULT_INTERVAL;
    local.id = TOS_NODE_ID;
    if (call RadioControl.start() != SUCCESS)
      report_problem();
  }

  void startTimer() {
    call Timer.startPeriodic(local.interval);
    reading = 0;
  }

  event void RadioControl.startDone(error_t error) {
   // startTimer();
  }

  event void RadioControl.stopDone(error_t error) {
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
	
   call Leds.led0Toggle();
   if(wakeUp==0)
	{
		call Leds.led2Toggle();
	 	serial_msg_t* rcm = (serial_msg_t*)payload;
		wakeUp= rcm->param_one;
		return msg;
	}
    else
    {
    oscilloscope_t *omsg = payload;
   

    report_received();

    /* If we receive a newer version, update our interval. 
       If we hear from a future count, jump ahead but suppress our own change
    */
    if (omsg->version > local.version)
      {
	local.version = omsg->version;
	local.interval = omsg->interval;
	startTimer();
      }
    if (omsg->count > local.count)
      {
	local.count = omsg->count;
	suppressCountChange = TRUE;
      }

    return msg;
   }
  }

  /* At each sample period:
     - if local sample buffer is full, send accumulated samples
     - read next sample
  */
  event void Timer.fired() {
    if (reading == NREADINGS)
      {
	if (!sendBusy && sizeof local <= call AMSend.maxPayloadLength())
	  {
	    // Don't need to check for null because we've already checked length
	    // above
	    memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
	    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS)
	      sendBusy = TRUE;
	  }
	if (!sendBusy)
	  report_problem();

	reading = 0;
	/* Part 2 of cheap "time sync": increment our count if we didn't
	   jump ahead. */
	if (!suppressCountChange)
	  local.count++;
	suppressCountChange = FALSE;
      }
    if (call ReadVL.read() != SUCCESS)
      report_problem();
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (error == SUCCESS)
      report_sent();
    else
      report_problem();

    sendBusy = FALSE;
  }

  event void ReadVL.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS)
      {
	data = 0xffff;
	report_problem();
      }
    if(data>4000)
      {
	sendMessage();
      }
    if (reading < NREADINGS) 
      local.readings[reading++] = data;
  }
	
}
