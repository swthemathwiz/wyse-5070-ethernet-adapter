# wyse-5070-ethernet-adapter
This is a 3D-Printable Openscad model of a second ethernet port adapter for the Dell Wyse 5070
Thin Client and an aftermarket ethernet adapter using the existing port in the case.

## Ethernet Cards

The adapter is for the [Commell M2-210 A-/E-Key Gigabit Ethernet Card](http://www.commell.com.tw/Product/Peripheral/M.2%20%28NGFF%29%20card/M2-210.htm), which
is a Intel I210-AT 2230 M.2 A/E card that fits in the Wifi/2nd Ethernet slot of the 5070. The daughter board needs to be cut; it comes perforated about
half way along the length. I also filed down the solder tabs on the ethernet jack at the bottom of the PCB.

There is code for the [IOCREST O-M2F8111H-GLAN](http://www.iocrest.com/index.php?id=2178), which is a Realtek RTL-8111H 2230 M.2 A/E card, which
**did not work** on the 5070 for me. The card was not recognized in the BIOS or by the OS. I only had one sample, so perhaps this was
a product issue (it is a relatively new product). The other problem with this card is
**the cable & connector combination prevents the case from being closed**, so you would need to replace the connectors on
the daughter board with their right angle equivalents.

## Building

I used an Creality Ender 3 Pro to build with a layer height of 0.16mm. In Cura, you need _Support_ on, with the support placement
set to _Touching Buildplate_ only. Support should be used only under the wings that take screws for the computer; in particular, check that
no support is built under the latch tangs used to secure the daughter board PCB inside of the adapter.

## Installing

To install the card in the adapter, slid the daughter board PCB down and under the front latches (small horizontal bars at the front of the
adapter) and fit the top of the ethernet jack under the panel opening then pull back on the rear latch and push the PCB down. The
PCB should be seated firmly with minimal play.

I didn't put any screws in to the PCB; there doesn't seem to be enough space to apply both screws - space is that
tight. If there is no 3rd display port (I think J4105's have 2 DPs / J5005's have 3 DPs), then you can easily use one M3 screw with a thin head
and a nut inside the adapter. 

Install the cable connecting the daughter board before putting the adapter in the 5070.

Screw two reasonably-short M3 thin (_wafer_) head screws into the 5070 through the _wings_ of the adapter.

Check that you can close the case.
