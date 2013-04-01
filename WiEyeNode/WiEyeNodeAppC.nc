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
 * Oscilloscope demo application. Uses the demo sensor - change the
 * new DemoSensorC() instantiation if you want something else.
 *
 * See README.txt file in this directory for usage instructions.
 *
 * @author David Gay
 */
#include "serial_msg.h"
configuration WiEyeNodeAppC { }
implementation
{
  components WiEyeNodeC, MainC, ActiveMessageC, LedsC,
    new TimerMilliC(),
    new AMSenderC(AM_OSCILLOSCOPE), new AMReceiverC(AM_OSCILLOSCOPE);
    components new SBT80_ADCconfigC() as VL;

  components HplMsp430GeneralIOC;
  WiEyeNodeC.SBcontrol -> HplMsp430GeneralIOC.Port23;

  WiEyeNodeC.Boot -> MainC;
  WiEyeNodeC.RadioControl -> ActiveMessageC;
  WiEyeNodeC.AMSend -> AMSenderC;
  WiEyeNodeC.Receive -> AMReceiverC;
  WiEyeNodeC.Timer -> TimerMilliC;
  //OscilloscopeC.Read -> Sensor;
  WiEyeNodeC.ReadVL -> VL.ReadADC0;
  WiEyeNodeC.Leds -> LedsC;

  
}
