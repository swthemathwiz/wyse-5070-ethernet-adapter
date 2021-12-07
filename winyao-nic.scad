//
// Copyright (c) Stewart H. Whitman, 2021.
//
// File:    winyao-nic.scad
// Project: Dell Wyse 5070 2nd Ethernet Adapter Adapter
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Mock-up of the Winyao (DF Robot) Realtek 8111 NIC
//

include <smidge.scad>;

// Winyao Realtek 8111 M.2 Daughter board layout
// Part #: 8111-M2-C
//
// This NIC is an M.2 A+E 2230 with a Realtek Gigabit NIC
// and a tiny daughter board and tiny ~6" ribbon cable.
//
// It is available from DFRobot:
//   https://www.dfrobot.com/product-2318.html
// Distributed in the United States by both Digi-Key and
// Mouser Electronics. Also available from various
// Aliexpress vendors.
//
// All these values were measured. The components/holes
// are symmetric about the Y-axis (side<->side), so some
// values are calculated accordingly.
//
// The shield holes match the layout of DE-9/DE-15 (9-pin
// serial or 15-pin vga) connector, and in fact it can be
// mounted in a serial or VGA cutout with the supplied hardware.
//

// kind:
//
// Unique, for customization.
//
function nic_kind() = "winyao";

// pcb thickness ~1.57mm (nominal 4-layer PCB thickness)
// pcb width X length as measured
function nic_get_pcb_size() = [ 30.2, 19.2, 1.57 ];

// ethernet size [left<->right,front<->rear,top<->bottom]
// Close match: Link-PP LPJE4717-2DNL
//              https://www.rj45-modularjack.com/photo/pl26614204-634108150321_rj45_smt_connector_low_profile_ethernet_port_lpje4717_2dnl.jpg
function nic_get_ethernet_size() = [16.2,15.0,11.2];

// shield: thickness
function nic_get_shield_thickness() = 1.0;
// shield: size
function nic_get_shield_size() = [ 30.8, nic_get_shield_thickness(), 14.0 ];
// shield hole position (25mm apart per DE-9 standard) [ left=0, bottom of pcb=0]
function _nic_get_shield_left_hole() = [ nic_get_shield_size().x/2-12.5, 8.5-nic_get_shield_thickness() ];
function _nic_get_shield_right_hole() = [ nic_get_shield_size().x/2+12.5, 8.5-nic_get_shield_thickness() ];
function nic_get_shield_holes() = [ _nic_get_shield_left_hole(), _nic_get_shield_right_hole() ];
// shield hole diameter (measures about 2.8mm)
function nic_get_shield_hole_diameter() = 2.8;
function nic_get_shield_center_pos() = [ nic_get_pcb_size().x/2, nic_get_shield_size().z/2-nic_get_shield_thickness() ];

// ethernet position is equidistant from left or right side (about 7.5mm)
function _nic_get_ethernet_left_pos() = (nic_get_pcb_size().x - nic_get_ethernet_size().x)/2;
function _nic_get_ethernet_right_pos() = (nic_get_pcb_size().x + nic_get_ethernet_size().x)/2;
// N.B.... about 0.3mm between ethernet and PCB
function _nic_get_ethernet_bottom_pos() = nic_get_pcb_size().z + 0.3;
function nic_get_ethernet_center_pos() = [ (_nic_get_ethernet_left_pos()+_nic_get_ethernet_right_pos())/2, _nic_get_ethernet_bottom_pos() + nic_get_ethernet_size().z/2 ];
function nic_get_ethernet_projection() = nic_get_shield_thickness();

// bottom hole positions [left=0, rear=0] - equidistant from both sides
function _nic_get_left_hole() = [ 2.5, nic_get_pcb_size().y - 5];
function _nic_get_right_hole() = [ nic_get_pcb_size().x-2.5, nic_get_pcb_size().y - 5];
function nic_get_bottom_holes() = [ _nic_get_left_hole(), _nic_get_right_hole() ];
// bottom hole diameter (measures about 3mm)
function nic_get_bottom_hole_diameter() = 3.0;

// Layout of the nic board (PCB centered with NIC port hanging out)
module nic(transparency=1.0,center=true,with_shield=true) {
  pcb_cutout = [ (nic_get_pcb_size().x-20.9)/2, nic_get_pcb_size().y-7.9, nic_get_pcb_size().z ];
  shield_thickness = nic_get_shield_thickness();

  module hole(height,diameter) {
    translate( [0,0,-SMIDGE] ) cylinder( h = height+2*SMIDGE, d=diameter );
  } // end hole

  // pcb with notch and hole
  module pcb() {
    color( "green", transparency )
      difference() {
	// board
	cube( nic_get_pcb_size() );
	// notch left
	translate( +[-SMIDGE,-SMIDGE,-SMIDGE] ) cube( pcb_cutout + [SMIDGE, SMIDGE, 2*SMIDGE] );
	// notch right
	translate( [nic_get_pcb_size().x-pcb_cutout.x,0,0]+[+SMIDGE,-SMIDGE,-SMIDGE] ) cube( pcb_cutout + [SMIDGE, SMIDGE, 2*SMIDGE] );
      }
  } // end pcb

  module ethernet() {
    color( "silver", transparency )
      translate( [_nic_get_ethernet_left_pos(), nic_get_pcb_size().y-nic_get_ethernet_size().y+nic_get_ethernet_projection(), _nic_get_ethernet_bottom_pos()] )
        cube( nic_get_ethernet_size() );
    color( "black", transparency ) {
      h = _nic_get_ethernet_bottom_pos()+0.2;
      translate( [_nic_get_ethernet_left_pos()+1.8,nic_get_pcb_size().y-3.5,_nic_get_ethernet_bottom_pos()-h] ) cylinder( h=h, d=3.00 );
      translate( [_nic_get_ethernet_right_pos()-1.8,nic_get_pcb_size().y-3.5,_nic_get_ethernet_bottom_pos()-h] ) cylinder( h=h, d=3.00 );
    }
  } // end ethernet

  module shield() {
    shield_holder    = [ pcb_cutout.x, nic_get_pcb_size().y-pcb_cutout.y, shield_thickness ];
    shield_left_pos  = [ (nic_get_pcb_size().x-nic_get_shield_size().x)/2, nic_get_pcb_size().y, -shield_thickness ];
    shield_right_pos = [ shield_left_pos.x+nic_get_shield_size().x, nic_get_pcb_size().y, -shield_thickness ];
    difference() {
      color( "silver", transparency )
        {
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

  module header_jp1() {
    // 7x2 @ about 1mm pitch
    header_size = [ 8.75, 2.75, 5+nic_get_pcb_size().z ];
    color( "black", transparency )
      translate( [ nic_get_pcb_size().x/2 - header_size.x/2, 1, -0.2 ] ) cube( header_size );
  } // end header_jp1

  // entire nic
  translate( center ? -[nic_get_pcb_size().x,nic_get_pcb_size().y,0]/2 : [0,0,0] ) {
    difference() {
      union() {
	pcb();
	ethernet();
	header_jp1();

        if( with_shield )
	  shield();
      }

      // Bottom Holes (left and right)
      for( h = nic_get_bottom_holes() )
	translate( concat( h, -shield_thickness ) ) hole( nic_get_pcb_size().z + shield_thickness, nic_get_bottom_hole_diameter() );

      // Vertical Holes (left and right)
      if( with_shield )
	for( h = nic_get_shield_holes() )
	  translate( [h.x, nic_get_pcb_size().y + shield_thickness, h.y] ) rotate( [90,0,0] ) hole( shield_thickness, nic_get_shield_hole_diameter() );
    }
  }
} // end nic

nic($fn=24);
