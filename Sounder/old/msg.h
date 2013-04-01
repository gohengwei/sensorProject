#ifndef MSG
#define MSG

typedef nx_struct serial_msg {
  nx_uint16_t param_one;
  nx_uint16_t param_two;
  nx_uint16_t param_three;

}msg_t;


enum {
  AM_SERIAL_MSG = 101,
  AM_RADIO_MSG = 102,
  SOUNDER_ADDR = 1
};

#endif
