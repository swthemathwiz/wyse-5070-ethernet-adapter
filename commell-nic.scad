//
// Copyright (c) Stewart H. Whitman, 2020.
//
// File:    commell-nic.scad
// Project: Dell Wyse 5070 2nd Ethernet Adapter Adapter
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Mock-up of the common Commell M2-210 M.2 Ethernet Daughter Board
//

include <smidge.scad>;

// Commell M2-210 M.2 A/E-type Ethernet:
// Ref: http://www.commell.com.tw/Product/Peripheral/M.2%20(NGFF)%20card/M2-210.htm
//
// Most values come from manual (direct or calculated). Missing
// values (e.g. width of board after splitting at perforation), were
// measured and are noted as such.
//
// A few measurements were corrected for better fit (or perhaps
// documentation errors) and are noted.
//

function inches_to_mm(n) = 25.4*n;

// kind:
//
// Unique, for customization.
//
function nic_kind() = "commell";

// PCB size [width,depth,thickness]
//
// Measured thickness is ~1.57mm (nominal 4-layer PCB thickness). This board
// seems a little thicker. Width is measured to perforation.
//
// The manual says 0.8331 inches depth, but it measures around 0.855, so I
// have changed that.
//
function nic_get_pcb_size() = [ inches_to_mm(1.24), inches_to_mm(0.855), 1.60 ];

// hole positions [from left=0, rear=0]
function nic_get_left_hole() = [ inches_to_mm(0.1873), nic_get_pcb_size().y - inches_to_mm(0.1770)];
function nic_get_right_hole() = [ inches_to_mm(1.0993), nic_get_pcb_size().y - inches_to_mm(0.1770)];

// ethernet size [left<->right,front<->rear,top<->bottom]
//
// N.B.: Manual says the ethernet port measures: 0.5185" (13.2mm) x 0.6614" (16.8mm), but
//       mine measured at 0.541" (13.8mm) x 0.650" (16.5mm).
//
// Depth as measured.
//
function nic_get_ethernet_size() = [ inches_to_mm(0.650), 16.00, inches_to_mm(0.541) ];

// bracket hole sizes specified: 17.5mm W x 13.9mm V
// ethernet size in mm: 16.5mm x 13.8mm
//  implies spacing of ~0.35 around sides of the port cut out
//

// ethernet measures 8.25mm from left side
function nic_get_ethernet_left_pos() = inches_to_mm(0.3126) ;
function nic_get_ethernet_right_pos() = nic_get_ethernet_left_pos()+nic_get_ethernet_size().x;
function nic_get_ethernet_center_pos() = (nic_get_ethernet_left_pos()+nic_get_ethernet_right_pos())/2;
function nic_get_ethernet_projection() = 7.25 + nic_get_ethernet_size().y - nic_get_pcb_size().y; // Measured Overhang ~2mm

// hole diameter (M3x0.5)
function nic_get_hole_diameter() = 3.0;

// Layout of the nic board (PCB centered with NIC port hanging out)
module nic(transparency=1.0,center=true) {

  module hole() {
    translate( [0,0,-SMIDGE] ) cylinder( h = nic_get_pcb_size().z+2*SMIDGE, d=nic_get_hole_diameter() );
  } // end hole

  // PCB with notch and hole
  module pcb() {
    color( "green", transparency )
      difference() {
	// board
	cube( nic_get_pcb_size() );
	// left hole
	translate( concat( nic_get_left_hole(), 0 ) ) hole();
	// right hole
	translate( concat( nic_get_right_hole(),0 ) ) hole();
      }
  } // end pcb

  module ethernet() {
    color( "silver", transparency )
      translate( [nic_get_ethernet_left_pos(),7.0,nic_get_pcb_size().z] ) cube( nic_get_ethernet_size() );
    color( "black", transparency ) {
      h = 3.30;
      translate( [nic_get_ethernet_left_pos()+1.8,nic_get_pcb_size().y-3.75,nic_get_pcb_size().z-h] ) cylinder( h=h, d=3.00 );
      translate( [nic_get_ethernet_right_pos()-1.8,nic_get_pcb_size().y-3.75,nic_get_pcb_size().z-h] ) cylinder( h=h, d=3.00 );
    }
  } // end ethernet

  module header() {
    color( "black", transparency )
      translate( [ 8.5, 1.25, -0.1 ] ) cube( [ 16, 4, 7+nic_get_pcb_size().z] );
  } // end header

  // entire nic
  translate( center ? -[nic_get_pcb_size().x,nic_get_pcb_size().y,0]/2 : [0,0,0] ) {
    pcb();
    ethernet();
    header();
  }
} // end nic

nic($fn=24);
