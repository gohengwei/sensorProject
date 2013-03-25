COMPONENT=SerialAppC
BUILD_EXTRA_DEPS += serial_msg.java

serial_msg.java: serial_msg.h
	mig java -java-classname=blah.foo.$(@:.java=) $< $(@:.java=) -o $@

include $(MAKERULES)

