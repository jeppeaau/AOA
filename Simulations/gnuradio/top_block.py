#!/usr/bin/env python2
# -*- coding: utf-8 -*-
##################################################
# GNU Radio Python Flow Graph
# Title: Top Block
# Generated: Tue Dec 11 10:57:39 2018
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

import os
import sys
sys.path.append(os.environ.get('GRC_HIER_PATH', os.path.expanduser('~/.grc_gnuradio')))

from PyQt4 import Qt
from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio import qtgui
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from gnuradio.qtgui import Range, RangeWidget
from optparse import OptionParser
from polar_plot import polar_plot  # grc-generated hier_block
from real_source import real_source  # grc-generated hier_block
import epy_block_0
import sip
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
        self.trans_width = trans_width = frequency/10
        self.samp_rate = samp_rate = 256e3
        self.pi = pi = 3.1416
        self.f_c2 = f_c2 = 1.5*frequency
        self.f_c1 = f_c1 = frequency*0.5
        self.delay_value = delay_value = 0
        self.d = d = 0.0619
        self.carrier_freq = carrier_freq = 2.421e9
        self.c = c = 299792458
        self.SNR = SNR = 20

        ##################################################
        # Blocks
        ##################################################
        self._delay_value_range = Range(-63, 63, 1, 0, 200)
        self._delay_value_win = RangeWidget(self._delay_value_range, self.set_delay_value, 'Sample delay', "counter", int)
        self.top_grid_layout.addWidget(self._delay_value_win)
        self.real_source_0 = real_source(
            SNR=SNR,
            frequency=frequency,
            samp_rate=samp_rate,
        )
        self.qtgui_waterfall_sink_x_0 = qtgui.waterfall_sink_c(
        	1024, #size
        	firdes.WIN_BLACKMAN_hARRIS, #wintype
        	0, #fc
        	samp_rate, #bw
        	"Input frequency response", #name
                2 #number of inputs
        )
        self.qtgui_waterfall_sink_x_0.set_update_time(0.10)
        self.qtgui_waterfall_sink_x_0.enable_grid(False)
        self.qtgui_waterfall_sink_x_0.enable_axis_labels(True)

        if not True:
          self.qtgui_waterfall_sink_x_0.disable_legend()

        if "complex" == "float" or "complex" == "msg_float":
          self.qtgui_waterfall_sink_x_0.set_plot_pos_half(not True)

        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        colors = [0, 0, 0, 0, 0,
                  0, 0, 0, 0, 0]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]
        for i in xrange(2):
            if len(labels[i]) == 0:
                self.qtgui_waterfall_sink_x_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_waterfall_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_waterfall_sink_x_0.set_color_map(i, colors[i])
            self.qtgui_waterfall_sink_x_0.set_line_alpha(i, alphas[i])

        self.qtgui_waterfall_sink_x_0.set_intensity_range(-140, 10)

        self._qtgui_waterfall_sink_x_0_win = sip.wrapinstance(self.qtgui_waterfall_sink_x_0.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._qtgui_waterfall_sink_x_0_win)
        self.qtgui_time_sink_x_0_0 = qtgui.time_sink_f(
        	1024, #size
        	samp_rate, #samp_rate
        	"Angle of arrival", #name
        	1 #number of inputs
        )
        self.qtgui_time_sink_x_0_0.set_update_time(0.10)
        self.qtgui_time_sink_x_0_0.set_y_axis(0, pi)

        self.qtgui_time_sink_x_0_0.set_y_label('Amplitude', "rad")

        self.qtgui_time_sink_x_0_0.enable_tags(-1, True)
        self.qtgui_time_sink_x_0_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, qtgui.TRIG_SLOPE_POS, 0.0, 0, 0, "")
        self.qtgui_time_sink_x_0_0.enable_autoscale(False)
        self.qtgui_time_sink_x_0_0.enable_grid(True)
        self.qtgui_time_sink_x_0_0.enable_axis_labels(True)
        self.qtgui_time_sink_x_0_0.enable_control_panel(False)
        self.qtgui_time_sink_x_0_0.enable_stem_plot(False)

        if not False:
          self.qtgui_time_sink_x_0_0.disable_legend()

        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
                  "magenta", "yellow", "dark red", "dark green", "blue"]
        styles = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        markers = [-1, -1, -1, -1, -1,
                   -1, -1, -1, -1, -1]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]

        for i in xrange(1):
            if len(labels[i]) == 0:
                self.qtgui_time_sink_x_0_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_time_sink_x_0_0.set_line_label(i, labels[i])
            self.qtgui_time_sink_x_0_0.set_line_width(i, widths[i])
            self.qtgui_time_sink_x_0_0.set_line_color(i, colors[i])
            self.qtgui_time_sink_x_0_0.set_line_style(i, styles[i])
            self.qtgui_time_sink_x_0_0.set_line_marker(i, markers[i])
            self.qtgui_time_sink_x_0_0.set_line_alpha(i, alphas[i])

        self._qtgui_time_sink_x_0_0_win = sip.wrapinstance(self.qtgui_time_sink_x_0_0.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._qtgui_time_sink_x_0_0_win)
        self.qtgui_time_sink_x_0 = qtgui.time_sink_f(
        	1024, #size
        	samp_rate, #samp_rate
        	"Phase difference", #name
        	1 #number of inputs
        )
        self.qtgui_time_sink_x_0.set_update_time(0.10)
        self.qtgui_time_sink_x_0.set_y_axis(-pi, +pi)

        self.qtgui_time_sink_x_0.set_y_label('Amplitude', "rad")

        self.qtgui_time_sink_x_0.enable_tags(-1, True)
        self.qtgui_time_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, qtgui.TRIG_SLOPE_POS, 0.0, 0, 0, "")
        self.qtgui_time_sink_x_0.enable_autoscale(False)
        self.qtgui_time_sink_x_0.enable_grid(True)
        self.qtgui_time_sink_x_0.enable_axis_labels(True)
        self.qtgui_time_sink_x_0.enable_control_panel(False)
        self.qtgui_time_sink_x_0.enable_stem_plot(False)

        if not False:
          self.qtgui_time_sink_x_0.disable_legend()

        labels = ['', '', '', '', '',
                  '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
                  "magenta", "yellow", "dark red", "dark green", "blue"]
        styles = [1, 1, 1, 1, 1,
                  1, 1, 1, 1, 1]
        markers = [-1, -1, -1, -1, -1,
                   -1, -1, -1, -1, -1]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
                  1.0, 1.0, 1.0, 1.0, 1.0]

        for i in xrange(1):
            if len(labels[i]) == 0:
                self.qtgui_time_sink_x_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_time_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_time_sink_x_0.set_line_width(i, widths[i])
            self.qtgui_time_sink_x_0.set_line_color(i, colors[i])
            self.qtgui_time_sink_x_0.set_line_style(i, styles[i])
            self.qtgui_time_sink_x_0.set_line_marker(i, markers[i])
            self.qtgui_time_sink_x_0.set_line_alpha(i, alphas[i])

        self._qtgui_time_sink_x_0_win = sip.wrapinstance(self.qtgui_time_sink_x_0.pyqwidget(), Qt.QWidget)
        self.top_grid_layout.addWidget(self._qtgui_time_sink_x_0_win)
        self.polar_plot_1 = polar_plot()
        self.top_grid_layout.addWidget(self.polar_plot_1)
        self.epy_block_0 = epy_block_0.blk(baud_rate=250000, port_name='/dev/cu.usbmodem1421', period=0.1)
        self.blocks_transcendental_1_0 = blocks.transcendental('asin', "float")
        self.blocks_transcendental_1 = blocks.transcendental('acos', "float")
        self.blocks_null_sink_0 = blocks.null_sink(gr.sizeof_float*1)
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_vff((c/(2*pi*carrier_freq*d), ))
        self.blocks_multiply_conjugate_cc_0 = blocks.multiply_conjugate_cc(1)
        self.blocks_delay_0 = blocks.delay(gr.sizeof_gr_complex*1, delay_value)
        self.blocks_complex_to_arg_0 = blocks.complex_to_arg(1)
        self.band_pass_filter_0_0 = filter.fir_filter_ccf(1, firdes.band_pass(
        	1, samp_rate, f_c1, f_c2, trans_width, firdes.WIN_HAMMING, 6.76))
        self.band_pass_filter_0 = filter.fir_filter_ccf(1, firdes.band_pass(
        	1, samp_rate, f_c1, f_c2, trans_width, firdes.WIN_HAMMING, 6.76))



        ##################################################
        # Connections
        ##################################################
        self.connect((self.band_pass_filter_0, 0), (self.blocks_multiply_conjugate_cc_0, 0))
        self.connect((self.band_pass_filter_0, 0), (self.qtgui_waterfall_sink_x_0, 0))
        self.connect((self.band_pass_filter_0_0, 0), (self.blocks_multiply_conjugate_cc_0, 1))
        self.connect((self.band_pass_filter_0_0, 0), (self.qtgui_waterfall_sink_x_0, 1))
        self.connect((self.blocks_complex_to_arg_0, 0), (self.blocks_multiply_const_vxx_0, 0))
        self.connect((self.blocks_complex_to_arg_0, 0), (self.qtgui_time_sink_x_0, 0))
        self.connect((self.blocks_delay_0, 0), (self.band_pass_filter_0_0, 0))
        self.connect((self.blocks_multiply_conjugate_cc_0, 0), (self.blocks_complex_to_arg_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_transcendental_1, 0))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_transcendental_1_0, 0))
        self.connect((self.blocks_transcendental_1, 0), (self.polar_plot_1, 0))
        self.connect((self.blocks_transcendental_1, 0), (self.qtgui_time_sink_x_0_0, 0))
        self.connect((self.blocks_transcendental_1_0, 0), (self.epy_block_0, 0))
        self.connect((self.epy_block_0, 0), (self.blocks_null_sink_0, 0))
        self.connect((self.real_source_0, 0), (self.band_pass_filter_0, 0))
        self.connect((self.real_source_0, 1), (self.blocks_delay_0, 0))

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
        self.real_source_0.set_frequency(self.frequency)

    def get_trans_width(self):
        return self.trans_width

    def set_trans_width(self, trans_width):
        self.trans_width = trans_width
        self.band_pass_filter_0_0.set_taps(firdes.band_pass(1, self.samp_rate, self.f_c1, self.f_c2, self.trans_width, firdes.WIN_HAMMING, 6.76))
        self.band_pass_filter_0.set_taps(firdes.band_pass(1, self.samp_rate, self.f_c1, self.f_c2, self.trans_width, firdes.WIN_HAMMING, 6.76))

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.real_source_0.set_samp_rate(self.samp_rate)
        self.qtgui_waterfall_sink_x_0.set_frequency_range(0, self.samp_rate)
        self.qtgui_time_sink_x_0_0.set_samp_rate(self.samp_rate)
        self.qtgui_time_sink_x_0.set_samp_rate(self.samp_rate)
        self.band_pass_filter_0_0.set_taps(firdes.band_pass(1, self.samp_rate, self.f_c1, self.f_c2, self.trans_width, firdes.WIN_HAMMING, 6.76))
        self.band_pass_filter_0.set_taps(firdes.band_pass(1, self.samp_rate, self.f_c1, self.f_c2, self.trans_width, firdes.WIN_HAMMING, 6.76))

    def get_pi(self):
        return self.pi

    def set_pi(self, pi):
        self.pi = pi
        self.qtgui_time_sink_x_0_0.set_y_axis(0, self.pi)
        self.qtgui_time_sink_x_0.set_y_axis(-self.pi, +self.pi)
        self.blocks_multiply_const_vxx_0.set_k((self.c/(2*self.pi*self.carrier_freq*self.d), ))

    def get_f_c2(self):
        return self.f_c2

    def set_f_c2(self, f_c2):
        self.f_c2 = f_c2
        self.band_pass_filter_0_0.set_taps(firdes.band_pass(1, self.samp_rate, self.f_c1, self.f_c2, self.trans_width, firdes.WIN_HAMMING, 6.76))
        self.band_pass_filter_0.set_taps(firdes.band_pass(1, self.samp_rate, self.f_c1, self.f_c2, self.trans_width, firdes.WIN_HAMMING, 6.76))

    def get_f_c1(self):
        return self.f_c1

    def set_f_c1(self, f_c1):
        self.f_c1 = f_c1
        self.band_pass_filter_0_0.set_taps(firdes.band_pass(1, self.samp_rate, self.f_c1, self.f_c2, self.trans_width, firdes.WIN_HAMMING, 6.76))
        self.band_pass_filter_0.set_taps(firdes.band_pass(1, self.samp_rate, self.f_c1, self.f_c2, self.trans_width, firdes.WIN_HAMMING, 6.76))

    def get_delay_value(self):
        return self.delay_value

    def set_delay_value(self, delay_value):
        self.delay_value = delay_value
        self.blocks_delay_0.set_dly(self.delay_value)

    def get_d(self):
        return self.d

    def set_d(self, d):
        self.d = d
        self.blocks_multiply_const_vxx_0.set_k((self.c/(2*self.pi*self.carrier_freq*self.d), ))

    def get_carrier_freq(self):
        return self.carrier_freq

    def set_carrier_freq(self, carrier_freq):
        self.carrier_freq = carrier_freq
        self.blocks_multiply_const_vxx_0.set_k((self.c/(2*self.pi*self.carrier_freq*self.d), ))

    def get_c(self):
        return self.c

    def set_c(self, c):
        self.c = c
        self.blocks_multiply_const_vxx_0.set_k((self.c/(2*self.pi*self.carrier_freq*self.d), ))

    def get_SNR(self):
        return self.SNR

    def set_SNR(self, SNR):
        self.SNR = SNR
        self.real_source_0.set_SNR(self.SNR)


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
