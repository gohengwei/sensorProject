#!/usr/bin/python
# -*- coding: utf-8 -*-


import sys,os,traceback, string
import time
from datetime import datetime
from PyQt4 import QtGui, QtCore

"""
sys.path.append(os.path.join(os.environ["TOSROOT"], "support/sdk/python"))

import tinyos.message.MoteIF as MoteIF
import serial_msg
"""

class Alarm(QtGui.QWidget):
    

    def __init__(self):
        super(Alarm, self).__init__()
        
        self.initUI()
        
    def initUI(self):      

        cal = QtGui.QCalendarWidget(self)
        cal.setGridVisible(True)
        cal.move(420, 20)
        cal.clicked[QtCore.QDate].connect(self.showDate)
        
        
        self.timeSelect = QtGui.QTimeEdit(self)
        self.timeSelect.setGeometry(20,20,100,20)        
        
        self.timeSelectButton = QtGui.QPushButton(self)        
        self.timeSelectButton.setGeometry(120,20,140,20)
        self.timeSelectButton.setText("Set Alarm Time")  
        self.timeSelectButton.clicked.connect(self.setAlarmTime)      

        self.selectedTimeLabelText = QtGui.QLabel(self)
        self.selectedTimeLabelText.setGeometry(20,80,150,20)
        self.selectedTimeLabelText.setText("Selected Time")

        self.selectedTimeLabel = QtGui.QLabel(self)
        self.selectedTimeLabel.setGeometry(20,100,150,20)

        self.selectedDateLabelText = QtGui.QLabel(self)
        self.selectedDateLabelText.setGeometry(700,230,150,20)
        self.selectedDateLabelText.setText("Selected Date")
        
        self.selectedDateLabel = QtGui.QLabel(self)
        self.date = cal.selectedDate()
        self.selectedDateLabel.setGeometry(700,260,150,20)
        self.selectedDateLabel.setText(self.date.toString())
        
        self.currentDateLabelText = QtGui.QLabel(self)
        self.currentDateLabelText.setGeometry(450,230,150,20)
        self.currentDateLabelText.setText("Current Date and Time")
        
        self.currentDateLabel = QtGui.QLabel(self)
        currentDate = datetime.now()
        self.currentDateLabel.setGeometry(450,260,150,20)
        self.currentDateLabel.setText(currentDate.strftime("%a %b %d %Y %H:%M"))
        
        
        self.timerUpLabel = QtGui.QLabel(self)
        self.timerUpLabel.setGeometry(20,180,150,20)

        self.setGeometry(100, 100, 1000, 450)
        self.setWindowTitle('Alarm')
        self.show()
        
    def showDate(self, date):     
        self.selectedDateLabel.setText(date.toString())

    def timerUp(self):
        self.timerUpLabel.setText("Time's Up!!!")

    def setAlarmTime(self, time):     
        self.selectedTimeLabel.setText(self.timeSelect.time().toString())
        selectedTime = self.timeSelect.time().toPyTime()
        selectedDate = self.date.toPyDate()
        selectedDateTime = datetime.combine(selectedDate, selectedTime)
        currentDateTime = datetime.now()
        self.currentDateLabel.setText(currentDateTime.strftime("%a %b %d %Y %H:%M"))
        timeDifference = selectedDateTime - currentDateTime
        timer = QtCore.QTimer.singleShot(int(timeDifference.total_seconds()) * 1000, self.timerUp)

"""
class serial_send():
  def __init__(self, host, port):
    self.mif = MoteIF.MoteIF()
    hostString = "%s%s" % ("sf@", host)
    moteString = "%s:%d" % (hostString, string.atoi(port))
    print(moteString)
    self.source = self.mif.addSource(moteString)
  
  def send(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10):
	  m = serial_msg.serial_msg()
	  m.set_param_one(arg1)
	  m.set_param_two(arg2)
	  m.set_param_three(arg3)
	  m.set_param_four(arg4)
	  m.set_param_five(arg5)
	  m.set_param_six(arg6)
	  m.set_param_seven(arg7)
	  m.set_param_eight(arg8)
	  m.set_param_nine(arg9)
	  m.set_param_ten(arg10)
	  self.mif.sendMsg(self.source, 0x0, m.get_amType(), 0xFF, m)
 """   
        
        
def main(*args):
    
    t = serial_send(args[1], args[2])

    app = QtGui.QApplication(sys.argv)
    alarm= Alarm()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
