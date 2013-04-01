module BasestationC {
    uses {
        interface Boot;
        
        interface AMSend as RadioSend;
        interface Packet as RadioPacket;
        interface SplitControl as RadioControl;
        interface Receive as RadioReceive;
		interface AMPacket as RadioAMAccess;
        
        interface Receive as SerialReceive;
        interface Packet as SerialPacket;
        interface SplitControl as SerialControl;

		interface Leds;

    }
}

implementation {

    bool radio_locked = FALSE;
    bool serial_locked = FALSE;
    message_t packet;
	message_t packet2;
    
    event void Boot.booted(){
        call RadioControl.start();
    }

    event void RadioControl.startDone(error_t error){
        if (error == SUCCESS) {
            call SerialControl.start();
        }
        else {
            call RadioControl.start();
        }
    }
    
    event void SerialControl.startDone(error_t error){
        if (error == SUCCESS) {
            // nothing to do
        }
        else {
            call SerialControl.start();
        }
    }

    event void RadioControl.stopDone(error_t error){
        //do nothing
    }
    
    event void SerialControl.stopDone(error_t error){
        //do nothing
    }
    
    void sendMessage(radio_msg_t*);
    
    void sendMessage(radio_msg_t* msg_recv){
        radio_msg_t* msg_send = (radio_msg_t *)call RadioPacket.getPayload(&packet, sizeof(radio_msg_t));
        msg_send->param_one = msg_recv->param_one;
        
        
        if(!radio_locked){    
            if( call RadioSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_msg_t)) == SUCCESS ){
                radio_locked = TRUE;
            }
        }
    
    
    }
    
	void sendMessage2();
    
    void sendMessage2(){
        radio_msg_t* msg_send = (radio_msg_t *)call RadioPacket.getPayload(&packet2, sizeof(radio_msg_t));
        msg_send->param_one = 0;
        
        
        if(!radio_locked){    
            if( call RadioSend.send(AM_BROADCAST_ADDR, &packet2, sizeof(radio_msg_t)) == SUCCESS ){
                radio_locked = TRUE;
            }
        }
    
    
    }
	
    event message_t* SerialReceive.receive(message_t *buf, void *payload, uint8_t len){
        radio_msg_t *msg = (radio_msg_t*) payload; 
        sendMessage(msg);
        return buf;
    }
    
    event void RadioSend.sendDone(message_t *msg, error_t error){
        radio_locked = FALSE;
    }
    
	
	bool bed = FALSE;
	bool door = FALSE;

    event message_t* RadioReceive.receive(message_t *buf, void *payload, uint8_t len){
		call Leds.led1Toggle();
		
        if( (call RadioAMAccess.source(buf) == 4) || (call RadioAMAccess.source(buf) == 5) ){
			call Leds.led0Toggle();
			
			sendMessage2();

		}
		
        return buf;
    }


}
