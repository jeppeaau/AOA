"""
Embedded Python Blocks:

Each time this file is saved, GRC will instantiate the first class it finds
to get ports and parameters of your block. The arguments to __init__  will
be the parameters. All of them are required to have default values!
"""

import numpy as np
from gnuradio import gr
import serial


class blk(gr.sync_block):  # other base classes are basic_block, decim_block, interp_block
    """ SUPER AWESOME SERIAL PORT
    IT WORKS WITH MAGIK (AND SOME PYTHON)
    COUNTER IS USED TO AVOID KILLING THE
    POOR ARDUINO. BE CAREFUL """

    def __init__(self, baud_rate=9600, port_name='/dev/cu.usbmodem1411', counter=100):  # only default arguments here
        """arguments to this function show up as parameters in GRC"""
        gr.sync_block.__init__(
            self,
            name='Float Serial Sink',   # will show up in GRC
            in_sig=[np.float32],
            out_sig=[np.float32],
        )
        # if an attribute with the same name as a parameter is found,
        # a callback is registered (properties work, too).
        self.serial_device=serial.Serial(port_name,baud_rate,timeout=1)
        self.counter=counter
        self.index=0


    def work(self, input_items, output_items):
        """example: multiply with constant"""
        self.index=self.index+1
        
        if(self.index>=self.counter):
            self.index=0
            avg_result=np.mean(input_items[0])
            self.serial_device.write(str(avg_result))
            
        output_items[0][:] = input_items[0]
        return len(output_items[0])