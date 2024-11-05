//
// Copyright (c) Stewart H. Whitman, 2024.
//
// File:    youyeetoo-nic.scad
// Project: Dell Wyse 5070 2nd Ethernet Adapter Adapter
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Mock-up of the Youyeetoo Intel i225V B3/i226 M.2 NIC
//

include <smidge.scad>;

// Youyeetoo Intel I225-V B3/I226 M.2 Daughter board layout
// Part #: IIO-ALAN4 (M.2 A+E Key 2230)
//
// N.B.: Based on various pictures, there are at least two
// different daughter boards associated with this NIC/Part:
//   - a Pulse chip + black shield /w small holes deeper on PCB
//   - a Fuwin chip + silver shield /w larger holes shallower on PCB
// This file matches the layout of the one with the Pulse chip.
//
// This NIC is an M.2 A+E 2230 with a Intel I225V/I226 2.5GB NIC
// and a daughter board connected by a small cable. The cable is
// available in various lengths from 10cm to 30cm; I used a 15cm
// cable for the Wyse 5070.
//
// It is available from the Youyeetoo store:
//   https://www.youyeetoo.com/products/25g-m2-ethernet-card?VariantsId=12274
// or Aliexpress:
//   https://www.aliexpress.com/item/3256807086898768.html
// And made for one of their SBCs.
//
// Most of values come from the measurements available
// on their site - missing items were measured. The
// components/holes are symmetric about the Y-axis (side<->side),
// so some values are calculated accordingly.
//
// The shield holes match the layout of DE-9/DE-15 (9-pin
// serial or 15-pin vga) connector, and in fact it can be
// mounted in a serial or VGA cutout with the supplied hardware.
//

// kind:
//
// Unique, for customization.
//
function nic_kind() = "youyeetoo";

// pcb thickness ~1.0mm
// pcb length (measured) X width (measured)
function nic_get_pcb_size() = [ 30, 33.2, 1.0 ];

// ethernet size [left<->right,front<->rear,top<->bottom]
// Close match: Kycon, Inc. GWLX-SMT-S988G/Y
//              https://www.digikey.com/en/products/detail/kycon-inc/GWLX-SMT-S988G-Y/10248051
// Height x Width: Drawing says 17.2x13.9 (maybe includes EMI fingers), measured about 16.5x13.5 (excluding EMI fingers)
function nic_get_ethernet_size() = [16.5,16,13.5];

// shield: thickness (including bend radius)
function nic_get_shield_thickness() = 1.8;
// shield: size
function nic_get_shield_size() = [ nic_get_pcb_size().x, nic_get_shield_thickness(), nic_get_ethernet_size().z ];
// shield hole position (25mm apart per DE-9 standard) [ left=0, bottom of pcb=0]
function _nic_get_shield_left_hole() = [ nic_get_shield_size().x/2-12.5, 7.0+nic_get_pcb_size().z ];
function _nic_get_shield_right_hole() = [ nic_get_shield_size().x/2+12.5, 7.0+nic_get_pcb_size().z ];
function nic_get_shield_holes() = [ _nic_get_shield_left_hole(), _nic_get_shield_right_hole() ];
// shield hole diameter (measures about 2.8mm)
function nic_get_shield_hole_diameter() = 2.8;
function nic_get_shield_z() = nic_get_pcb_size().z;
function nic_get_shield_center_pos() = [ nic_get_pcb_size().x/2, nic_get_shield_size().z/2+nic_get_shield_z() ];

// ethernet position is equidistant from left or right side
function _nic_get_ethernet_left_pos() = (nic_get_pcb_size().x - nic_get_ethernet_size().x)/2;
function _nic_get_ethernet_right_pos() = (nic_get_pcb_size().x + nic_get_ethernet_size().x)/2;
// N.B.... about 0.0mm between ethernet and PCB
function _nic_get_ethernet_bottom_pos() = nic_get_pcb_size().z + 0.0;
function nic_get_ethernet_center_pos() = [ (_nic_get_ethernet_left_pos()+_nic_get_ethernet_right_pos())/2, _nic_get_ethernet_bottom_pos() + nic_get_ethernet_size().z/2 ];
function nic_get_ethernet_projection() = 12.75-10.5;

// bottom hole positions [left=0, rear=0] - equidistant from both sides
function _nic_get_left_hole() = [ nic_get_pcb_size().x/2 - 24.2/2, nic_get_pcb_size().y - 10.8];
function _nic_get_right_hole() = [ nic_get_pcb_size().x/2 + 24.2/2, nic_get_pcb_size().y - 10.8];
function nic_get_bottom_holes() = [ _nic_get_left_hole(), _nic_get_right_hole() ];
// bottom hole diameter (measures about 2.5mm, diagram says 2mm - screw size)
function nic_get_bottom_hole_diameter() = 2.5;

// Layout of the nic board (PCB centered with NIC port hanging out)
module nic(transparency=1.0,center=true,with_shield=true) {
  shield_thickness = nic_get_shield_thickness();

  module hole(height,diameter) {
    translate( [0,0,-SMIDGE] ) cylinder( h = height+2*SMIDGE, d=diameter );
  } // end hole

  // pcb
  module pcb() {
    color( "green", transparency ) cube( nic_get_pcb_size() );
  } // end pcb

  // ethernet
  module ethernet() {
    // connector
    color( "silver", transparency )
      translate( [_nic_get_ethernet_left_pos(), nic_get_pcb_size().y-nic_get_ethernet_size().y+nic_get_ethernet_projection(), _nic_get_ethernet_bottom_pos()] )
        cube( nic_get_ethernet_size() );
    // nubs securing connector below bottom
    color( "black", transparency ) {
      h = _nic_get_ethernet_bottom_pos()+0.2;
      translate( [_nic_get_ethernet_left_pos()+1.8,nic_get_pcb_size().y-3.4,_nic_get_ethernet_bottom_pos()-h] ) cylinder( h=h, d=3.00 );
      translate( [_nic_get_ethernet_right_pos()-1.8,nic_get_pcb_size().y-3.4,_nic_get_ethernet_bottom_pos()-h] ) cylinder( h=h, d=3.00 );
    }
  } // end ethernet

  // shield
  module shield() {
    shield_holder    = [ 6.4, 0.2+nic_get_ethernet_size().y-nic_get_ethernet_projection(), shield_thickness ];
    shield_left_pos  = [ (nic_get_pcb_size().x-nic_get_shield_size().x)/2, nic_get_pcb_size().y, nic_get_shield_z() ];
    shield_right_pos = [ shield_left_pos.x+nic_get_shield_size().x, nic_get_pcb_size().y, nic_get_shield_z() ];
    color( "black", transparency )
      difference() {
	 union() {
	    translate( shield_left_pos ) cube( nic_get_shield_size() );
	    translate( shield_left_pos-[0,shield_holder.y,0] ) cube( shield_holder );
	    translate( shield_right_pos-[shield_holder.x,shield_holder.y,0] ) cube( shield_holder );
	  }
	// Cutout ethernet hole...
	o = 0.2;
	translate( [_nic_get_ethernet_left_pos()-o,nic_get_pcb_size().y-nic_get_ethernet_size().y+nic_get_ethernet_projection(),_nic_get_ethernet_bottom_pos()-o] )
	  cube( nic_get_ethernet_size() + 2*[o,o,o] );
      }
  } // end shield

  // header_ja: wiring connector
  module header_ja() {
    // 12-pin @ about 1mm pitch
    header_size = [ 14.4, 4.2, 2.8 ];
    color( "white", transparency )
      translate( [ nic_get_pcb_size().x/2 - header_size.x/2, 0, nic_get_pcb_size().z ] ) cube( header_size );
  } // end header_ja

  // mags: Pulse H5084NL chip
  module mags() {
    mag_size = [ 15.2, 7.6, 4.1+nic_get_pcb_size().z ];
    color( "black", transparency )
      translate( [ nic_get_pcb_size().x/2 - mag_size.x/2, 9, +0.2 ] ) cube( mag_size );
  } // end mags

  // entire nic
  translate( center ? -[nic_get_pcb_size().x,nic_get_pcb_size().y,0]/2 : [0,0,0] ) {
    difference() {
      union() {
	pcb();
	ethernet();
	header_ja();
	mags();

        if( with_shield )
	  shield();
      }

      // Bottom Holes (left and right)
      for( h = nic_get_bottom_holes() )
	translate( concat( h, -shield_thickness ) ) hole( nic_get_pcb_size().z + 2*shield_thickness, nic_get_bottom_hole_diameter() );

      // Vertical Holes (left and right)
      if( with_shield )
	for( h = nic_get_shield_holes() )
	  translate( [h.x, nic_get_pcb_size().y + shield_thickness, h.y] ) rotate( [90,0,0] ) hole( shield_thickness, nic_get_shield_hole_diameter() );
    }
  }
} // end nic

nic($fn=24);
