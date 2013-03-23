#!/usr/bin/env python

import os,sys,traceback,time
import string

sys.path.append(os.path.join(os.environ["TOSROOT"], "support/sdk/python"))

import tinyos.message.MoteIF as MoteIF
import serial_msg


def main(*args):
  t = serial_recv(args[1], args[2])

class serial_recv():
  def __init__(self, host, port):
    self.mif = MoteIF.MoteIF()
    hostString = "%s%s" % ("sf@", host)
    moteString = "%s:%d" % (hostString, string.atoi(port))
    print(moteString)
    self.source = self.mif.addSource(moteString)
    time.sleep(1)
    self.mif.addListener(self, serial_msg.serial_msg)
    time.sleep(1)

  def receive(self, src, m): 
    param_1 = m.get_param_one()
    param_2 = m.get_param_two()
    param_3 = m.get_param_three()
    param_4 = m.get_param_four()
    param_5 = m.get_param_five()
    param_6 = m.get_param_six()
    param_7 = m.get_param_seven()
    param_8 = m.get_param_eight()
    param_9 = m.get_param_nine()
    param_10 = m.get_param_ten()

    '''
     Based on multimeter reading of 3V on AVCC and 14 Bit for temperature and 12bit
     Constants taken from datasheet
    '''
    temperature = -39.6 + 0.01*param_1

    humidity = -2.0468 + 0.0367*param_2 +  -0.0000015955*param_2*param_2
    light = param_3*2307/8192
   # light = param_3*1.5*6250/4096

    print "Temperature--> Raw:" + str(param_1) + " Converted:" + str(temperature)
    print "Humidity--> Raw:" + str(param_2) + " Converted:" + str(humidity)
    print "Light--> Raw:" + str(param_3) + " Converted:" + str(light)

if __name__=='__main__':
 main(*sys.argv)
