ghdl -a my_functions.vhdl

ghdl -a mac.vhdl
ghdl -e mac

ghdl -a mac_tb.vhdl
ghdl -e mac_tb

ghdl -r mac_tb --vcd=mac_tb.vcd --stop-time=1us

gtkwave mac_tb.vcd signals
