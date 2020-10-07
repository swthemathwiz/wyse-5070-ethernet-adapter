//
// Copyright (c) Stewart H. Whitman, 2020.
//
// File:    realtek-nic.scad
// Project: Dell Wyse 5070 2nd Ethernet Adapter Adapter
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Mock-up of the very common Realtek RTL8111 Daughter Board
//

include <smidge.scad>;

// Common Realtek Mini PCI-Express Daughter board layout
//
// An example would be: IOCREST IO-M2F8111H-GLAN
//
// The problem with these boards are that the cables are
// large and bulk, so the connectors may need changing out to
// right-angle ones.
//

//
// All these values where measured.
//

// kind:
//
// Unique, for customization.
//
function nic_kind() = "realtek";

// pcb thickness ~1.57mm (nominal 4-layer PCB thickness)
// pcb width X length as measured (about 1.5" x 1")
function nic_get_pcb_size() = [ 39.75, 26.1, 1.57 ];

// hole positions [left=0, rear=0]
function nic_get_left_hole() = [ 3.75, nic_get_pcb_size().y - 5.25];
function nic_get_right_hole() = [ 33.25, nic_get_pcb_size().y - 5.25];

// ethernet size [left<->right,front<->rear,top<->bottom]
function nic_get_ethernet_size() = [16.30,15.75,13.25];

// ethernet measures 8.25mm from left side
function nic_get_ethernet_left_pos() = 8.25;
function nic_get_ethernet_right_pos() = nic_get_ethernet_left_pos()+nic_get_ethernet_size().x;
function nic_get_ethernet_center_pos() = (nic_get_ethernet_left_pos()+nic_get_ethernet_right_pos())/2;
function nic_get_ethernet_projection() = 12.0 + nic_get_ethernet_size().y - nic_get_pcb_size().y;

// hole diameter
function nic_get_hole_diameter() = 3.6;

// Layout of the nic board (PCB centered with NIC port hanging out)
module nic(transparency=1.0,center=true) {

  module hole() {
    translate( [0,0,-SMIDGE] ) cylinder( h = nic_get_pcb_size().z+2*SMIDGE, d=nic_get_hole_diameter() );
  } // end hole

  // pcb with notch and hole
  module pcb() {
    color( "green", transparency )
      difference() {
	// board
	cube( nic_get_pcb_size() );
	// notch
	translate( [-SMIDGE,-SMIDGE,-SMIDGE] ) cube( nic_get_pcb_size() - [29.5-SMIDGE, 14.25-SMIDGE, -2*SMIDGE] );
	// left hole
	translate( concat( nic_get_left_hole(), 0 ) ) hole();
	// right hole
	translate( concat( nic_get_right_hole(),0 ) ) hole();
      }
  } // end pcb

  module ethernet() {
    color( "silver", transparency )
      translate( [nic_get_ethernet_left_pos(),12.0,nic_get_pcb_size().z] ) cube( nic_get_ethernet_size() );
    color( "black", transparency ) {
      h = 3.25;
      translate( [nic_get_ethernet_left_pos()+1.8,nic_get_pcb_size().y-3.5,nic_get_pcb_size().z-h] ) cylinder( h=h, d=3.00 );
      translate( [nic_get_ethernet_right_pos()-1.8,nic_get_pcb_size().y-3.5,nic_get_pcb_size().z-h] ) cylinder( h=h, d=3.00 );
    }
  } // end ethernet

  module header1() {
    color( "black", transparency )
      translate( [ 11.5, 4, -0.5 ] ) cube( [ 12.7, 5, 11] );
  } // end header1

  module header2() {
    color( "black", transparency )
      translate( [ 28, 4, -0.5 ] ) cube( [ 5.1, 5, 11] );
  } // end header2

  // entire nic
  translate( center ? -[nic_get_pcb_size().x,nic_get_pcb_size().y,0]/2 : [0,0,0] ) {
    pcb();
    ethernet();
    header1();
    header2();
  }
} // end nic

nic($fn=24);
