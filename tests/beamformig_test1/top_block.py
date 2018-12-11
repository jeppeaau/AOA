#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Top Block
# Generated: Mon Dec 10 11:32:18 2018
##################################################

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print "Warning: failed to XInitThreads()"

from PyQt4 import Qt
from gnuradio import analog
from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import gr
from gnuradio import qtgui
from gnuradio import uhd
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from gnuradio.qtgui import Range, RangeWidget
from optparse import OptionParser
import sip
import sys
import time
from gnuradio import qtgui


class top_block(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "Top Block")
        Qt.QWidget.__init__(self)
        self.setWindowTitle("Top Block")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except:
            pass
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "top_block")
        self.restoreGeometry(self.settings.value("geometry").toByteArray())


        ##################################################
        # Variables
        ##################################################
        self.frequency = frequency = 2e3
        self.tx_gain = tx_gain = 89
        self.trans_width = trans_width = frequency/10
        self.samp_rate = samp_rate = 256e3
        self.rx_gain = rx_gain = 76
        self.pi = pi = 3.1416
        self.offset = offset = 7500
        self.f_c2 = f_c2 = 1.5*frequency
        self.f_c1 = f_c1 = frequency*0.5
        self.delay_val_0 = delay_val_0 = 0
        self.delay_val = delay_val = 0
        self.d = d = 0.0619
        self.carrier_freq = carrier_freq = 2.421e9
        self.c = c = 299792458

        ##################################################
        # Blocks
        ##################################################
        self._delay_val_0_range = Range(0, 100, 1, 0, 200)
        self._delay_val_0_win = RangeWidget(self._delay_val_0_range, self.set_delay_val_0, "delay_val_0", "counter_slider", int)
        self.top_grid_layout.addWidget(self._delay_val_0_win)
        self._delay_val_range = Range(0, 100, 1, 0, 200)
        self._delay_val_win = RangeWidget(self._delay_val_range, self.set_delay_val, "delay_val", "counter_slider", int)
        self.top_grid_layout.addWidget(self._delay_val_win)
        self.uhd_usrp_sink_0 = uhd.usrp_sink(
        	",".join(('', "")),
        	uhd.stream_args(
        		cpu_format="fc32",
        		channels=range(2),
        	),
        )
        self.uhd_usrp_sink_0.set_samp_rate(samp_rate)
        self.uhd_usrp_sink_0.set_center_freq(carrier_freq, 0)
        self.uhd_usrp_sink_0.set_gain(tx_gain, 0)
        self.uhd_usrp_sink_0.set_antenna('TX/RX', 0)
        self.uhd_usrp_sink_0.set_center_freq(carrier_freq, 1)
        self.uhd_usrp_sink_0.set_gain(tx_gain, 1)
        self.uhd_usrp_sink_0.set_antenna('TX/RX', 1)
        self.qtgui_freq_sink_x_1 = qtgui.freq_sink_c(
        	1024, #size
        	firdes.WIN_BLACKMAN_hARRIS, #wintype
        	0, #fc
        	samp_rate, #bw
        	"Output", #name
        	1 #number of inputs
        )
        self.qtgui_freq_sink_x_1.set_update_time(0.10)
        self.qtgui_freq_sink_x_1.set_y_axis(-140, 10)
        self.qtgui_freq_sink_x_1.set_y_label('Relative Gain', 'dB')
        self.qtgui_freq_sink_x_1.set_trigger_mode(qtgui.TRIG_MODE_FREE, 0.0, 0, "")
        self.qtgui_freq_sink_x_1.enable_autoscale(False)
        self.qtgui_freq_sink_x_1.enable_grid(True)
        self.qtgui_freq_sink_x_1.set_fft_average(1.0)
        self.qtgui_freq_sink_x_1.enable_axis_labels(True)
        self.qtgui_freq_sink_x_1.enable_control_panel(False)

        if not True:
          self.qtgui_freq_sink_x_1.disable_legend()

        if "complex" == "float" or "complex" == "msg_float":
          self.qtgui_freq_sink_x_1.set_plot_pos_half(not True)

        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
                  "magenta", "yellow", "dark red", "dark green", "dark blue"]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]
        for i in xrange(1):
            if len(labels[i]) == 0:
                self.qtgui_freq_sink_x_1.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_freq_sink_x_1.set_line_label(i, labels[i])
            self.qtgui_freq_sink_x_1.set_line_width(i, widths[i])
            self.qtgui_freq_sink_x_1.set_line_color(i, colors[i])
            self.qtgui_freq_sink_x_1.set_line_alpha(i, alphas[i])

        self._qtgui_freq_sink_x_1_win = sip.wrapinstance(self.qtgui_freq_sink_x_1.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._qtgui_freq_sink_x_1_win)
        self._offset_range = Range(0, 10000, 50, 7500, 200)
        self._offset_win = RangeWidget(self._offset_range, self.set_offset, 'Center frequency offset (Hz)', "counter", int)
        self.top_grid_layout.addWidget(self._offset_win)
        self.blocks_file_sink_0_0 = blocks.file_sink(gr.sizeof_gr_complex*1, '/Users/Antonio/Desktop/antenna2.bin', True)
        self.blocks_file_sink_0_0.set_unbuffered(False)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_gr_complex*1, '/Users/Antonio/Desktop/antenna1.bin', True)
        self.blocks_file_sink_0.set_unbuffered(False)
        self.blocks_delay_0_0 = blocks.delay(gr.sizeof_gr_complex*1, delay_val_0)
        self.blocks_delay_0 = blocks.delay(gr.sizeof_gr_complex*1, delay_val)
        self.analog_sig_source_x_0 = analog.sig_source_c(samp_rate, analog.GR_SIN_WAVE, frequency, 1, 0)



        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_sig_source_x_0, 0), (self.blocks_delay_0, 0))
        self.connect((self.analog_sig_source_x_0, 0), (self.blocks_delay_0_0, 0))
        self.connect((self.analog_sig_source_x_0, 0), (self.qtgui_freq_sink_x_1, 0))
        self.connect((self.blocks_delay_0, 0), (self.blocks_file_sink_0, 0))
        self.connect((self.blocks_delay_0, 0), (self.uhd_usrp_sink_0, 0))
        self.connect((self.blocks_delay_0_0, 0), (self.blocks_file_sink_0_0, 0))
        self.connect((self.blocks_delay_0_0, 0), (self.uhd_usrp_sink_0, 1))

    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "top_block")
        self.settings.setValue("geometry", self.saveGeometry())
        event.accept()

    def get_frequency(self):
        return self.frequency

    def set_frequency(self, frequency):
        self.frequency = frequency
        self.set_trans_width(self.frequency/10)
        self.set_f_c2(1.5*self.frequency)
        self.set_f_c1(self.frequency*0.5)
        self.analog_sig_source_x_0.set_frequency(self.frequency)

    def get_tx_gain(self):
        return self.tx_gain

    def set_tx_gain(self, tx_gain):
        self.tx_gain = tx_gain
        self.uhd_usrp_sink_0.set_gain(self.tx_gain, 0)

        self.uhd_usrp_sink_0.set_gain(self.tx_gain, 1)


    def get_trans_width(self):
        return self.trans_width

    def set_trans_width(self, trans_width):
        self.trans_width = trans_width

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.uhd_usrp_sink_0.set_samp_rate(self.samp_rate)
        self.qtgui_freq_sink_x_1.set_frequency_range(0, self.samp_rate)
        self.analog_sig_source_x_0.set_sampling_freq(self.samp_rate)

    def get_rx_gain(self):
        return self.rx_gain

    def set_rx_gain(self, rx_gain):
        self.rx_gain = rx_gain

    def get_pi(self):
        return self.pi

    def set_pi(self, pi):
        self.pi = pi

    def get_offset(self):
        return self.offset

    def set_offset(self, offset):
        self.offset = offset

    def get_f_c2(self):
        return self.f_c2

    def set_f_c2(self, f_c2):
        self.f_c2 = f_c2

    def get_f_c1(self):
        return self.f_c1

    def set_f_c1(self, f_c1):
        self.f_c1 = f_c1

    def get_delay_val_0(self):
        return self.delay_val_0

    def set_delay_val_0(self, delay_val_0):
        self.delay_val_0 = delay_val_0
        self.blocks_delay_0_0.set_dly(self.delay_val_0)

    def get_delay_val(self):
        return self.delay_val

    def set_delay_val(self, delay_val):
        self.delay_val = delay_val
        self.blocks_delay_0.set_dly(self.delay_val)

    def get_d(self):
        return self.d

    def set_d(self, d):
        self.d = d

    def get_carrier_freq(self):
        return self.carrier_freq

    def set_carrier_freq(self, carrier_freq):
        self.carrier_freq = carrier_freq
        self.uhd_usrp_sink_0.set_center_freq(self.carrier_freq, 0)
        self.uhd_usrp_sink_0.set_center_freq(self.carrier_freq, 1)

    def get_c(self):
        return self.c

    def set_c(self, c):
        self.c = c


def main(top_block_cls=top_block, options=None):

    from distutils.version import StrictVersion
    if StrictVersion(Qt.qVersion()) >= StrictVersion("4.5.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()
    tb.start()
    tb.show()

    def quitting():
        tb.stop()
        tb.wait()
    qapp.connect(qapp, Qt.SIGNAL("aboutToQuit()"), quitting)
    qapp.exec_()


if __name__ == '__main__':
    main()
