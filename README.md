# wyse-5070-ethernet-adapter

## Introduction

This is a 3D-Printable [OpenSCAD](https://openscad.org/) model of a second
ethernet port adapter for the [Dell Wyse 5070 Thin Client](https://www.dell.com/en-us/work/shop/wyse-endpoints-and-software/wyse-5070-thin-client/spd/wyse-5070-thin-client)
and various aftermarket M.2 A+E ethernet adapters using the existing option port
in the 5070 case.

## Models and Ethernet Adapter Variations

There is support for three different M.2 ethernet adapters (**N.B.**: I've only
gotten the first two to work):

<div class="model" data-name="Winyao Adapter" data-left="wyse-winyao-adapter.stl" data-left-icon="wyse-winyao-adapter.icon.png" data-right="winyao-view-interior.jpg"><!-- expanded by annotate-model --><table align="center" width="100%"><tbody><tr width="100%"><td align="center" width="128" height="128"><a href="../media/media/wyse-winyao-adapter.stl" target="_blank" title="View Winyao Adapter Model"><img src="../media/media/wyse-winyao-adapter.icon.png" alt="Winyao Adapter Model" width="96" height="96" /></a></td><td>

### :heavy\_check\_mark: **winyao**: Winyao 8111-M2-C & 8125-M2-C / [DFRobot FIT0798](https://www.dfrobot.com/product-2318.html) / Generic RTL8111F & RTL8125B

These are Realtek RTL8111F and RTL8125B 2230 M.2 A+E cards that fit the Wifi/2nd Ethernet
slot of the 5070. They come with a small metal shield (presumably designed to
allow mounting in a standard DE9 port - i.e., VGA or serial knock out). I found
it easier to adapt with the shield removed - just unscrew. The 1GbE version costs about $18 +
shipping direct from [DFRobot](https://www.dfrobot.com/product-2318.html) and is also
available from [Digi-Key](https://www.digikey.com/en/products/detail/dfrobot/FIT0798/14824986)
and [Mouser Electronics](https://www.mouser.com/ProductDetail/DFRobot/FIT0798?qs=%2Fha2pyFadui97DZ%2FSy%2FYrWNYjzbmGQYac80ChPKoMVC2EQ7OhLzBwA%3D%3D).
The Winyao (OEM) and "generic" versions are listed on several Chinese sites for less.
There are two choices: 1GbE vs. 2.5GbE, and vertical vs. horizontal pins on the M.2 card (all choices work).
With FreeBSD-based distributions (including pfSense, OPNsense, etc.) count on installing
the **realtek-re-kmod** [(google)](https://www.google.com/search?q=realtek-re-kmod) driver package instead of
using the OS' native driver.

</td><td align="center" width="128" height="128"><a href="../media/media/winyao-view-interior.jpg" target="_blank" title="View Winyao Adapter Installed"><img src="../media/media/winyao-view-interior.jpg" alt="Winyao Adapter Installed" width="96" height="96" /></a></td></tr></tbody></table></div>

<div class="model" data-name="Commell Adapter" data-left="wyse-commell-adapter.stl" data-left-icon="wyse-commell-adapter.icon.png" data-right="commell-view-interior.jpg"><!-- expanded by annotate-model --><table align="center" width="100%"><tbody><tr width="100%"><td align="center" width="128" height="128"><a href="../media/media/wyse-commell-adapter.stl" target="_blank" title="View Commell Adapter Model"><img src="../media/media/wyse-commell-adapter.icon.png" alt="Commell Adapter Model" width="96" height="96" /></a></td><td>

### :heavy\_check\_mark: **commell**: [Commell M2-210 A-/E-Key Gigabit Ethernet Card](http://www.commell.com.tw/Product/Peripheral/M.2%20%28NGFF%29%20card/M2-210.htm) (and probably their M2-225)

This is an Intel I210-AT 2230 M.2 A+E card that fits in the Wifi/2nd Ethernet
slot of the 5070. The daughter board needs to be cut; it comes perforated
about half way along the length. I also filed down the solder tabs on the
ethernet jack at the bottom of the PCB. Cost was about $45 + shipping from one
of their [distributors](http://www.commell.com.tw/distributor/Distributor.htm).

</td><td align="center" width="128" height="128"><a href="../media/media/commell-view-interior.jpg" target="_blank" title="View Commell Adapter Installed"><img src="../media/media/commell-view-interior.jpg" alt="Commell Adapter Installed" width="96" height="96" /></a></td></tr></tbody></table></div>

<div class="model" data-name="IOCREST Adapter" data-left="wyse-iocrest-adapter.stl" data-left-icon="wyse-iocrest-adapter.icon.png"><!-- expanded by annotate-model --><table align="center" width="100%"><tbody><tr width="100%"><td align="center" width="128" height="128"><a href="../media/media/wyse-iocrest-adapter.stl" target="_blank" title="View IOCREST Adapter Model"><img src="../media/media/wyse-iocrest-adapter.icon.png" alt="IOCREST Adapter Model" width="96" height="96" /></a></td><td>

### :x: **iocrest**: [IOCREST O-M2F8111H-GLAN](http://www.iocrest.com/index.php?id=2178)

This is a Realtek RTL8111H 2230 M.2 A+E card, which **did not work** on
the 5070 for me. The card was not recognized in the BIOS or by the OS. I
only had one sample, so perhaps this was a product issue (it was a
relatively new product when I got one). The other problem with this card
is **the cable & connector combination prevents the case from being
closed**. So you would need to replace the connectors on the daughter
board with their right-angle equivalents. Cost is about $17 to $21 from
various eBay or Aliexpress vendors.

</td></tr></tbody></table></div>

I would like to know if there are other working cards.

## Source

The model is built using OpenSCAD. *wyse-XXX-adapter.scad* is the main file for
each adapter, where *XXX* is the version of the NIC. It customizes an ethernet
adapter *wyse-ethernet.scad* using information from the appropriate
*XXX-nic.scad* NIC file.

If you find the fit too tight, or the dimensions of the PCB have changed, you
might try changing the *tolerance* settings in the adapter file, or the
corresponding dimensions in the appropriate *XXX-nic.scad* NIC file. Generally,
I had only one adapter to test against, so I don't know how measurements vary
from sample to sample. I even had to modify some measurements listed in manuals,
so there might be other versions of the product with different components.

If you need to debug the source, I suggest including the appropriate NIC file in
*wyse-ethernet.scad* and then working directly from that file. There doesn't
seem to be a great way to handle the NIC "classes" in OpenSCAD.

Finally, you can also build a simple blank that blocks off an empty I/O slot
from the *wyse-filler.scad*.

## Printing

I use a Creality Ender 3 Pro to build with a layer height of 0.16 mm. In Cura,
you need ***Generate Support*** checked, with ***Support Placement*** set to
***Touching Buildplate***. Support should be used only below the two *wings*
that are screwed to the computer; in particular, ensure that no support is added
under the various overhanging latch tangs used to secure the daughter board PCB
inside the adapter.

## Installation

To install the card in the adapter:

1. Slid the daughter board PCB down and under the front latches (small horizontal
   bars at the front of the adapter) and fit the top of the ethernet jack under
   the baffle opening then pull back on the rear latch and push the PCB down and
   release. The PCB should be seated firmly with minimal play.

2. I didn't put any screws through the **commell** PCB; there doesn't seem to be
   enough space to apply both screws - space is that tight below the adapter.
   In 5070's with no third display port (I think the J4105's have 2 DPs / J5005's
   have 3 DPs) you can easily use one screw on the lower side and a hex nut on
   the inside. With the **winyao**, which has a low-profile ethernet jack, I was
   able to put two M3x6mm thin (*wafer*) head machine screws from the bottom up
   with hex nuts inside the adapter.

3. Install the cable connecting the daughter board to the M.2 card (before
   putting the adapter into the 5070).

4. Screw two reasonably-short M3 thin (*wafer*) head machine screws into the 5070
   through the *wings* of the adapter.

5. Check that you can close the case.

## Also Available on Thingiverse

STLs are available on [Thingiverse](https://www.thingiverse.com/thing:4619323).
