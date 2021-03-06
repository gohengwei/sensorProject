#include "printf.h"
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
        interface Timer<TMilli> as Timer1;
        interface Timer<TMilli> as Timer2;
    }
}

implementation {

    bool radio_locked = FALSE;
    bool serial_locked = FALSE;
    message_t packet;
	//message_t packet2;
    //message_t packet3;
    //message_t packet4;
    //message_t packet5;
    
    event void Boot.booted(){
        printf("Started\n");
        printfflush();
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
       

    void sendMessage3(){
        radio_msg_t* msg_send = (radio_msg_t *)call RadioPacket.getPayload(&packet, sizeof(radio_msg_t));
        msg_send->param_one = 2;
        
        if(!radio_locked){    
            if( call RadioSend.send(WIEYE2, &packet, sizeof(radio_msg_t)) == SUCCESS ){
                radio_locked = TRUE;
            }
        }
        
        printf("Sent2to5\n");
        printfflush();
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
        radio_msg_t* msg_send = (radio_msg_t *)call RadioPacket.getPayload(&packet, sizeof(radio_msg_t));
        msg_send->param_one = 0;
        
        
        if(!radio_locked){    
            if( call RadioSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_msg_t)) == SUCCESS ){
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
    
	

    bool receivedFour = FALSE;
    bool isCross = FALSE;
    bool timer1Started = FALSE;
    bool timer2Started = FALSE;
    
    event void Timer2.fired(){
        if(!isCross) receivedFour = FALSE;
        timer2Started = FALSE;
        printf("First 10s exp\n");
        printfflush();
    }
	
event void Timer1.fired(){
        timer2Started = FALSE;
        printf("Second 20s exp\n");
        printfflush();
        sendMessage2();
        printf("Signal off.\n");
        printfflush();
    }

    void sendResetMessage(){
        radio_msg_t* msg_send = (radio_msg_t *)call RadioPacket.getPayload(&packet, sizeof(radio_msg_t));
        msg_send->param_one = 1;
        
        if(!radio_locked){    
            if( call RadioSend.send(BUZZER, &packet, sizeof(radio_msg_t)) == SUCCESS ){
                radio_locked = TRUE;
                printf("i\n");
                printfflush();
            } else {
                printf("j\n");
                printfflush();
            }
        }
        printf("k\n");
        printfflush();
        
    }

    void sendMessageToTurnBuzzerOff(){
        radio_msg_t* msg_send = (radio_msg_t *)call RadioPacket.getPayload(&packet, sizeof(radio_msg_t));
        msg_send->param_one = 0;
        
        if(!radio_locked){    
            if( call RadioSend.send(BUZZER, &packet, sizeof(radio_msg_t)) == SUCCESS ){
                radio_locked = TRUE;
            }
        }
    
    }

    event message_t* RadioReceive.receive(message_t *buf, void *payload, uint8_t len){
		call Leds.led1Toggle();
		
        

        if( (call RadioAMAccess.source(buf) == 4)){
            
            printf("R4\n");
            printfflush();
            if(!receivedFour){            
                sendMessage3();
            }
            receivedFour = TRUE;
            if(timer2Started == FALSE){
                call Timer2.startOneShot(10 * 1024);
                timer2Started = TRUE;
            }           
            
            if(timer1Started == TRUE){

                //receivedFour = FALSE;
                timer1Started = FALSE;
                timer2Started = FALSE;
                isCross = FALSE;
        
                call Timer1.stop();
                call Timer2.stop();

                sendResetMessage();

                printf("Reset, 4 after 5\n");
                printfflush();
            }            

            printfflush();
        }
        
        if( (call RadioAMAccess.source(buf) == 5) && receivedFour){
		    call Leds.led0Toggle();
			
	        sendMessageToTurnBuzzerOff();
            printf("Buzzer off\n");
            printfflush();
            call Timer2.stop();
            //receivedFour = FALSE;
            isCross = TRUE;
            timer2Started = FALSE;     
            printf("R5\n");  
            printfflush();
            
            if(timer1Started == FALSE){
                call Timer1.startOneShot(20 * 1024);
                timer1Started = TRUE;
            }
    
		}
		
        return buf;
    }


}
