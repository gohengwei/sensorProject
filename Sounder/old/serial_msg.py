#
# This class is automatically generated by mig. DO NOT EDIT THIS FILE.
# This class implements a Python interface to the 'serial_msg'
# message type.
#

import tinyos.message.Message

# The default size of this message type in bytes.
DEFAULT_MESSAGE_SIZE = 6

# The Active Message type associated with this message.
AM_TYPE = 101

class serial_msg(tinyos.message.Message.Message):
    # Create a new serial_msg of size 6.
    def __init__(self, data="", addr=None, gid=None, base_offset=0, data_length=6):
        tinyos.message.Message.Message.__init__(self, data, addr, gid, base_offset, data_length)
        self.amTypeSet(AM_TYPE)
    
    # Get AM_TYPE
    def get_amType(cls):
        return AM_TYPE
    
    get_amType = classmethod(get_amType)
    
    #
    # Return a String representation of this message. Includes the
    # message type name and the non-indexed field values.
    #
    def __str__(self):
        s = "Message <serial_msg> \n"
        try:
            s += "  [param_one=0x%x]\n" % (self.get_param_one())
        except:
            pass
        try:
            s += "  [param_two=0x%x]\n" % (self.get_param_two())
        except:
            pass
        try:
            s += "  [param_three=0x%x]\n" % (self.get_param_three())
        except:
            pass
        return s

    # Message-type-specific access methods appear below.

    #
    # Accessor methods for field: param_one
    #   Field type: int
    #   Offset (bits): 0
    #   Size (bits): 16
    #

    #
    # Return whether the field 'param_one' is signed (False).
    #
    def isSigned_param_one(self):
        return False
    
    #
    # Return whether the field 'param_one' is an array (False).
    #
    def isArray_param_one(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'param_one'
    #
    def offset_param_one(self):
        return (0 / 8)
    
    #
    # Return the offset (in bits) of the field 'param_one'
    #
    def offsetBits_param_one(self):
        return 0
    
    #
    # Return the value (as a int) of the field 'param_one'
    #
    def get_param_one(self):
        return self.getUIntElement(self.offsetBits_param_one(), 16, 1)
    
    #
    # Set the value of the field 'param_one'
    #
    def set_param_one(self, value):
        self.setUIntElement(self.offsetBits_param_one(), 16, value, 1)
    
    #
    # Return the size, in bytes, of the field 'param_one'
    #
    def size_param_one(self):
        return (16 / 8)
    
    #
    # Return the size, in bits, of the field 'param_one'
    #
    def sizeBits_param_one(self):
        return 16
    
    #
    # Accessor methods for field: param_two
    #   Field type: int
    #   Offset (bits): 16
    #   Size (bits): 16
    #

    #
    # Return whether the field 'param_two' is signed (False).
    #
    def isSigned_param_two(self):
        return False
    
    #
    # Return whether the field 'param_two' is an array (False).
    #
    def isArray_param_two(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'param_two'
    #
    def offset_param_two(self):
        return (16 / 8)
    
    #
    # Return the offset (in bits) of the field 'param_two'
    #
    def offsetBits_param_two(self):
        return 16
    
    #
    # Return the value (as a int) of the field 'param_two'
    #
    def get_param_two(self):
        return self.getUIntElement(self.offsetBits_param_two(), 16, 1)
    
    #
    # Set the value of the field 'param_two'
    #
    def set_param_two(self, value):
        self.setUIntElement(self.offsetBits_param_two(), 16, value, 1)
    
    #
    # Return the size, in bytes, of the field 'param_two'
    #
    def size_param_two(self):
        return (16 / 8)
    
    #
    # Return the size, in bits, of the field 'param_two'
    #
    def sizeBits_param_two(self):
        return 16
    
    #
    # Accessor methods for field: param_three
    #   Field type: int
    #   Offset (bits): 32
    #   Size (bits): 16
    #

    #
    # Return whether the field 'param_three' is signed (False).
    #
    def isSigned_param_three(self):
        return False
    
    #
    # Return whether the field 'param_three' is an array (False).
    #
    def isArray_param_three(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'param_three'
    #
    def offset_param_three(self):
        return (32 / 8)
    
    #
    # Return the offset (in bits) of the field 'param_three'
    #
    def offsetBits_param_three(self):
        return 32
    
    #
    # Return the value (as a int) of the field 'param_three'
    #
    def get_param_three(self):
        return self.getUIntElement(self.offsetBits_param_three(), 16, 1)
    
    #
    # Set the value of the field 'param_three'
    #
    def set_param_three(self, value):
        self.setUIntElement(self.offsetBits_param_three(), 16, value, 1)
    
    #
    # Return the size, in bytes, of the field 'param_three'
    #
    def size_param_three(self):
        return (16 / 8)
    
    #
    # Return the size, in bits, of the field 'param_three'
    #
    def sizeBits_param_three(self):
        return 16
    