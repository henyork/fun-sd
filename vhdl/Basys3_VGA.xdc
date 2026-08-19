
##====================================================================
## Buttons
##====================================================================
## CENTER BUTTON
set_property PACKAGE_PIN U18 [get_ports reset_ext_port]
set_property IOSTANDARD LVCMOS33 [get_ports reset_ext_port]

##====================================================================
## VGA Connector
##====================================================================
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## VGA RED
set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]

set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]

##set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
##set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]

##set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
##set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]

##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## GREEN
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]

set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]

##set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
##set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]

##set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
##set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]

##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## BLUE
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]

set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]

##set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
##set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]

##set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
##set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]

##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## Timing
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set_property PACKAGE_PIN P19 [get_ports Hsync]
set_property IOSTANDARD LVCMOS33 [get_ports Hsync]

set_property PACKAGE_PIN R19 [get_ports Vsync]
set_property IOSTANDARD LVCMOS33 [get_ports Vsync]
