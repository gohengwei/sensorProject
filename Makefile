COMPONENT=ActuatorAppC
CFLAGS += -I$(TOSDIR)/lib/printf
BUILD_EXTRA_DEPS += serial_msg.java

serial_msg.java: serial_msg.h
	mig java -target=null $(CFLAGS) -java-classname=blah.foo.$(@:.java=) $< $(@:.java=) -o $@

include $(MAKERULES)

