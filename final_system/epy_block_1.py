# Import libraries and neccesary functions
import numpy as np
from gnuradio import gr
import serial
from time import time
import struct

# Definition of the block class
class blk(gr.sync_block):
    """ Serial Port Block
    It starts a communication with the specified port and
    the specified baud rate. It sends the reference for
    the motor with a certain frequency, specified by period"""

    def __init__(self, baud_rate=19200, port_name='/dev/cu.usbmodem1421', period=1.0):
        gr.sync_block.__init__(
            self,
            name='Float Serial Sink',   # will show up in GRC
            in_sig=[np.float32],
            out_sig=[np.float32],
        )

        self.serial_device=serial.Serial(port_name,baud_rate)
        self.period=period
        self.time_var=time()
        self.previous_ref=0;

    def work(self, input_items, output_items):
        """Serial Port Block"""
        # Checks if a sampling period has passed since the last message sent
        if(time()-self.time_var>=self.period):
            # Averages the block input buffer and computes the reference
            # based on the previous reference
            avg_result=np.mean(input_items[0])
            theta_ref=self.previous_ref+avg_result
            
            # Transforms the reference into bytes and sends them through the serial port
            byte_reference=bytearray(struct.pack("f", theta_ref))
            n_bytes_sent=self.serial_device.write(byte_reference)
            
            # Stores current system time for the next iteration and sends log through the terminal
            self.time_var=time()
            print('Message sent at t = {} s\nBytes sent = {}\nCurrent reference = {} rad\n'.format(self.time_var,n_bytes_sent,theta_ref))
            self.previous_ref=theta_ref

        output_items[0][:] = input_items[0]
        return len(output_items[0])
