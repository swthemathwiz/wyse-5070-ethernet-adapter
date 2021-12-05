# wyse-5070-ethernet-adapter
This is a 3D-Printable [Openscad](https://openscad.org/) model of a second ethernet port adapter for the [Dell Wyse 5070 Thin Client](https://www.dell.com/en-us/work/shop/wyse-endpoints-and-software/wyse-5070-thin-client/spd/wyse-5070-thin-client) and various aftermarket M.2 A+E ethernet adapters using the existing option port in the 5070 case.

## Ethernet Adapters

There is support for three different M.2 ethernet adapters (**N.B.**: I've only gotten the first two to work):

- **commell**: [Commell M2-210 A-/E-Key Gigabit Ethernet Card](http://www.commell.com.tw/Product/Peripheral/M.2%20%28NGFF%29%20card/M2-210.htm): This is an Intel I210-AT 2230 M.2 A+E card that fits in the Wifi/2nd Ethernet slot of the 5070. The daughter board needs to be cut; it comes perforated about half way along the length. I also filed down the solder tabs on the ethernet jack at the bottom of the PCB. Cost was about $45 + shipping from one of their [distributors](http://www.commell.com.tw/distributor/Distributor.htm).

![Image of Commell Mount](../media/media/commell-view-interior.jpg?raw=true "Commell Adapter mounted in 5070")

- **winyao**: Winyao 8111-M2-C / [DFRobot FIT0798](https://www.dfrobot.com/product-2318.html): This is a Realtek RTL-8111F 2230 M.2 A+E card that fits the Wifi/2nd Ethernet slot of the 5070. It comes with a small metal shield (presumably designed to allow mounting in a standard DE9 port - i.e., VGA or serial knock out). I found it easier to adapt with the shield removed - just unscrew. Cost was about $18 + shipping direct from [DFRobot](https://www.dfrobot.com/product-2318.html). They sell this for their LattePanda products and it is also available from [Digi-Key](https://www.digikey.com/en/products/detail/dfrobot/FIT0798/14824986) and [Mouser Electronics](https://www.mouser.com/ProductDetail/DFRobot/FIT0798?qs=%2Fha2pyFadui97DZ%2FSy%2FYrWNYjzbmGQYac80ChPKoMVC2EQ7OhLzBwA%3D%3D). The Winyao (OEM) product is listed on several Chinese parts sites too.

![Image of Winyao Mount](../media/media/winyao-view-interior.jpg?raw=true "Winyao/DFRobot Adapter mounted in 5070")

- **realtek**: [IOCREST O-M2F8111H-GLAN](http://www.iocrest.com/index.php?id=2178): This is a Realtek RTL-8111H 2230 M.2 A/E card, which **did not work** on the 5070 for me. The card was not recognized in the BIOS or by the OS. I only had one sample, so perhaps this was a product issue (it was a relatively new product when I got one). The other problem with this card is **the cable & connector combination prevents the case from being closed**. So you would need to replace the connectors on the daughter board with their right-angle equivalents. Cost is about $17 to $21 from various eBay or Aliexpress vendors.

I would like to know if there are other working cards.

## Source

The model is built using Openscad. _wyse-XXX-adapter.scad_ is the main file for each adapter, where _XXX_ is the version of the NIC. It customizes a ethernet adapter _wyse-ethernet.scad_ using information from the appropriate _XXX-nic.scad_ NIC file.

If you find the fit too tight, or the dimensions of the PCB have changed, you might wish to change the _tolerance_ settings in the adapter file, or the corresponding dimensions in the appropriate _XXX-nic.scad_ NIC file. Generally, I had only one adapter to test against, so I don't know how measurements vary from sample to sample. I even had to modify some measurements listed in manuals, so there might be other versions of the product with different components.

If you need to debug the source, I suggest including the appropriate NIC file in _wyse-ethernet.scad_ and then working directly from that file. There doesn't seem to be a great way to handle the NIC "classes" in Openscad.

Finally, you can also build a simple blank that blocks off an empty I/O slot from the _wyse-filler.scad_.

## 3D Printing

I use a Creality Ender 3 Pro to build with a layer height of 0.16mm. In Cura, you need **_Generate Support_** checked, with **_Support Placement_** set to **_Touching Buildplate_**. Support should be used only below the two _wings_ that are screwed to the computer; in particular, ensure that no support is added under the various overhanging latch tangs used to secure the daughter board PCB inside the adapter.

## Installing

To install the card in the adapter:

- Slid the daughter board PCB down and under the front latches (small horizontal bars at the front of the adapter) and fit the top of the ethernet jack under the baffle opening then pull back on the rear latch and push the PCB down and release. The PCB should be seated firmly with minimal play.

- I didn't put any screws through the **commell** PCB; there doesn't seem to be enough space to apply both screws - space is that tight below the adapter. In 5070's with no third display port (I think the J4105's have 2 DPs / J5005's have 3 DPs) you can easily use one screw on the lower side and a hex nut on the inside. With the **winyao**, which has a low-profile ethernet jack, I was able to put two M3x6mm thin (_wafer_) head machine screws from the bottom up with hex nuts inside the adapter. 

- Install the cable connecting the daughter board to the M.2 card (before putting the adapter into the 5070).

- Screw two reasonably-short M3 thin (_wafer_) head machine screws into the 5070 through the _wings_ of the adapter.

- Check that you can close the case.

## Also Available on Thingiverse

STL's are available on [Thingiverse](https://www.thingiverse.com/thing:4619323).
