//
// Copyright (c) Stewart H. Whitman, 2020.
//
// File:    wyse-ethernet.scad
// Project: Dell Wyse 5070 2nd Ethernet Adapter Adapter
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Adapter that holds NIC Daughter-board
//

use <wyse-blank.scad>
//use <realtek-nic.scad>
use <commell-nic.scad>
include <smidge.scad>

// Show the NIC inserted in the adapter
show_nic = false;

// Mounting height above top (in mm) (Failed: unnecessary)
mount_height = 0.0; // [0:0.2:2]

// Mounting hole radius (in mm)
mount_hole_radius = nic_get_hole_diameter()/2 + 0.2;

// Mounting surround radius (in mm)
mount_radius = mount_hole_radius*1.75;

// Mounting countersink (Failed: amount of space too small for screws)
mount_countersink = false;

// Mount use nubs instead of holes (Failed: print as a mess, so somewhat useless)
mount_use_nubs = false;

// Support thickness
support_thickness = (nic_kind() == "realtek") ? 0.8 : 1.6;

// Baffle thickness
baffle_thickness = 1.6;

// Extra depth (behind the end of the wings)
extra_depth = max( 0, (nic_get_pcb_size().y+6.8)-(Wyse_Get_Raw_Depth()-baffle_thickness) );

// Space at front-bottom of baffle
front_cut = [ baffle_thickness/2, Wyse_Get_Floor_Thickness([]) + nic_get_pcb_size().z*0.8 ];

// Config hash
config = [
  ["extra_depth", extra_depth],
  ["baffle_thickness", baffle_thickness],
  ["support_thickness", support_thickness],
  ["front_cut", front_cut ],
];

// Trough indent from sides [front,rear,left,right]
trough_indent_size = (nic_kind() == "realtek") ? [1.5, 7.5, 1.5, 1.5] : [1.6, 7.2, 4.4, 4.4];

// Rear snap length
rear_snap_length = 16;

// Side guide width
side_guide_width = 1;

// Use side guides when PCB smaller than interior width
use_side_guides = (nic_get_pcb_size().x < (Wyse_Get_Interior_Width(config) - side_guide_width*2));

// midfront_of:
//
// Translate NIC's X-/Y-coordinates from model to origin centered at mid-width (X-mirrored) and PCB-front (Y) 
//
function midfront_of(v) = (len(v) == 2) ? [-(v.x-nic_get_pcb_size().x/2),nic_get_pcb_size().y-v.y] : [-(v.x-nic_get_pcb_size().x/2),nic_get_pcb_size().y-v.y,v.z];

// Mounting hole positions
mount_holes = [ midfront_of( nic_get_left_hole() ), midfront_of( nic_get_right_hole() ) ];

// Ethernet cutout position from middle of baffle and bottom of floor
ethernet_pos_yz = [ midfront_of( [nic_get_ethernet_center_pos(),0] ).x, mount_height + nic_get_pcb_size().z ];

// Ethernet cutout size (raw)
ethernet_size_yz = [ nic_get_ethernet_size().x, nic_get_ethernet_size().z ];

// Tolerance: side<->side, front<->back, top<->bottom
tolerance = [0.25, 0.25, 0.3];

module ethernet(pos,size) {
  // Use the same tolerance all the way around
  port_tolerance = max(tolerance.x,tolerance.z); 

  // Cutout a rectangular port space with tolerance
  Wyse_Baffle_Cutout( config, pos )
    translate( [0, +port_tolerance*0.75 ] ) // Most tolerance at top of Z (PCB thickness is fixed)
      offset( delta=port_tolerance ) // Tolerance all around
        translate( [-size[0]/2,0] ) // Center horizontally
          square( size );
} // end ethernet

module mount(pos,simple=false) {
  Wyse_Mount(config,pos,mount_radius,mount_height,simple);
} // end mount

module hole(pos) {
  Wyse_Hole(config,pos,mount_hole_radius,mount_height,mount_countersink);
} // end hole

module nub(pos) {
  // Nubs are 75% of mounting hole diameter and are tapered to a cone
  // at 50% of their height to allow the PCB to slide below latches.
  //
  Wyse_Nub(config,pos,nic_get_hole_diameter()/2*0.66,nic_get_pcb_size().z*.75,percent=50);
} // end nub

module latches() {
  // Z-height of latches is the space below the bottom of the protruding tongue
  z_height = nic_get_pcb_size().z + mount_height + 1.5*tolerance.z;

  // Rear (snap-fit)
  //
  // Just behind the PCB board, in the center.
  //
  if( rear_snap_length != 0 ) {
    rear_pos = midfront_of( [ nic_get_pcb_size().x/2, -tolerance.y, z_height ] );

    Wyse_Latch( config, rear_pos, rear_snap_length, 1.00, style="tang2" );
  }

  // Front (non-moving)
  //
  // These are the bars at the front of the adapter. They start
  // right from the corner of the PCB to just past the corresponding
  // mounting hole.
  //
  {
    left_len    = (nic_get_left_hole().x - 0) + nic_get_hole_diameter()*.75;
    left_mid    = (0 + left_len)/2;
    left_center = midfront_of( [ left_mid, nic_get_pcb_size().y, z_height ] );

    right_len    = (nic_get_pcb_size().x - nic_get_right_hole().x) + nic_get_hole_diameter()*.75;
    right_mid    = (nic_get_pcb_size().x + (nic_get_pcb_size().x-right_len))/2;
    right_center = midfront_of( [ right_mid, nic_get_pcb_size().y, z_height ] );

    Wyse_Latch( config, left_center, left_len, 1.0, style="square" );
    Wyse_Latch( config, right_center, right_len, 1.0, style="square" );
  }

  // Side "guides"
  //
  // Rails around sides of PCB if needed.
  //
  if( use_side_guides ) {
    corner_position = nic_get_pcb_size().x/2+tolerance.x;
    guide_size      = [ side_guide_width, nic_get_pcb_size().y*0.75, mount_height+nic_get_pcb_size().z+2*tolerance.z ]; 

    Wyse_Guide( config, [ -corner_position, nic_get_pcb_size().y*0.125 ], guide_size );
    Wyse_Guide( config, [ +corner_position, nic_get_pcb_size().y*0.125 ], guide_size );
  }
} // end latches

module trough() {
  Wyse_Trough( config, trough_indent_size ); 
} // end trough

module holder() {
  difference() {
    union() {

      difference() {
	// Blank
	Wyse_Blank(config);

	// trough below board
	trough();
      }

      // Mount for PCBs...
      for( m = mount_holes ) mount(m);

      // Nubs for holes
      if( mount_use_nubs )
	for( m = mount_holes ) nub(m);

      latches();
    }

    // Ethernet cut out of baffle
    ethernet(ethernet_pos_yz, ethernet_size_yz);

    // Holes in mount for PCBs cut out
    if( !mount_use_nubs )
      for( m = mount_holes ) hole(m);
  };
} // end holder

Wyse_Blank_Center(config) {
  intersection() {
    holder($fn=64);
    //cube( [100,100,2*5.5], center=true );
  }

  // Show the nic in place
  if( show_nic ) {
    translate( [nic_get_pcb_size().x/2,nic_get_pcb_size().y,Wyse_Get_Floor_Thickness(config)+mount_height+tolerance.z/2] )
      rotate( [0,0,180] )
        nic( transparency=0.5, center=false, $fn=16 );
  }
}
