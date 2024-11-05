//
// Copyright (c) Stewart H. Whitman, 2020-2024.
//
// File:    wyse-ethernet.scad
// Project: Dell Wyse 5070 2nd Ethernet Adapter Adapter
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Adapter that holds NIC Daughter-board
//

use <wyse-blank.scad>
//use <iocrest-nic.scad>
//use <commell-nic.scad>
//use <winyao-nic.scad>
//use <youyeetoo-nic.scad>
include <smidge.scad>

// Show the NIC inserted in the adapter (debugging)
show_nic = false;

// Tolerance: side<->side, front<->back, top<->bottom
tolerance = [0.25, 0.25, 0.3];

// Use shield (if supplied with NIC)
use_shield = false;

// Use shield mounting if requested and if the NIC has a shield with holes
use_shield_mounting = use_shield && len( nic_get_shield_holes() ) > 0;

// Mounting hole radius (in mm)
mount_hole_radius = nic_get_bottom_hole_diameter()/2 + 0.2;

// Mounting surround radius (in mm)
mount_radius = mount_hole_radius*1.75;

// Support thickness
support_thickness = (nic_kind() == "iocrest") ? 0.8 : 1.6;

// Baffle thickness (extra for shield indent)
baffle_thickness = !use_shield_mounting ? 1.6 : 1.6 + nic_get_shield_thickness();

// Baffle height (can decrease for lower profile ethernet jacks/pcb thickness)
baffle_height = (nic_kind() == "winyao") ? 16.2 :
                  (nic_kind() == "youyeetoo") ? 17.6 :
                    18.0;

// Extra depth (behind the end of the wings)
extra_depth = max( 0, (nic_get_pcb_size().y+6.8)-(Wyse_Get_Raw_Depth()-baffle_thickness) );

// Notch at front-bottom of baffle
front_cut = [ 0.8, Wyse_Get_Floor_Thickness([]) + nic_get_pcb_size().z*0.8 ];

// Rear snap width (positive for center, negative for dual sides, zero for none)
rear_snap_width = (nic_kind() == "winyao") ? 20 : (nic_kind() == "youyeetoo") ? -5 : 16;

function is_center_rear_snap() = rear_snap_width > 0;
function is_side_rear_snap() = rear_snap_width < 0;

// Width of handle at rear
handle_percentage = is_side_rear_snap() ? 33 : is_center_rear_snap() ? 25 : 0;

// Trough round over
trough_round_over = is_side_rear_snap() ? 1 : 6;

// Config hash
config = [
  ["extra_depth", extra_depth],
  ["baffle_thickness", baffle_thickness],
  ["baffle_height", baffle_height],
  ["support_thickness", support_thickness],
  ["front_cut", front_cut ],
  ["handle_percentage", handle_percentage ],
  ["trough_round_over", trough_round_over ],
];

// Trough indent from sides [front,rear,left,right] to support PCB w/o touching solder points
trough_indent_sizes = (nic_kind() == "iocrest") ? [ [1.5, 7.5, 1.5, 1.5] ] :
                       (nic_kind() == "commell") ? [ [1.6, 7.2, 4.4, 4.4] ] :
                        (nic_kind() == "youyeetoo") ? [ [1.4, 7.5, 5.4, 5.4], [ 29, 7.5, 3, 3 ] ] :
                         (nic_kind() == "winyao")  ? (use_shield_mounting ? [ [ 0.0, 11.0, 3.9, 3.9], [ 0.0, 7.0, 9.0, 9.0] ] :
                                                                            [ [ 1.6, 11.0, 4.2, 4.2], [ 1.6, 7.0, 9.0, 9.0] ] )
                                                  : undef; // customized per NIC PCB/mounting

// Side guide width
side_guide_width = 1;

// Percentage of side to guide
side_guide_percentage = is_side_rear_snap() ? 60 : 75;

// Has side guides when configured and PCB smaller than interior width
function has_side_guides() = side_guide_width > 0 &&
                               side_guide_percentage > 0 &&
                                 (nic_get_pcb_size().x < (Wyse_Get_Interior_Width(config) - side_guide_width*2));

// midfront_of:
//
// Translate NIC's X-/Y-coordinates from model to origin centered at mid-width (X-mirrored) and PCB-front (Y)
//
function midfront_of(v) = (len(v) == 2) ? [-(v.x-nic_get_pcb_size().x/2),nic_get_pcb_size().y-v.y] : [-(v.x-nic_get_pcb_size().x/2),nic_get_pcb_size().y-v.y,v.z];

// Mounting hole positions
mount_holes = [ for( h = nic_get_bottom_holes() ) midfront_of( h ) ];

// Baffle hole positions
baffle_holes_yz = [ for( h = nic_get_shield_holes() ) [ midfront_of( [h.x,0] ).x, h.y ] ];

// Baffle hole radius (in mm)
baffle_hole_radius = nic_get_shield_hole_diameter()/2 + 0.2;

// Ethernet cutout position from middle of baffle and bottom of adapter floor
ethernet_pos_yz = [ midfront_of( nic_get_ethernet_center_pos() ).x, _nic_get_ethernet_bottom_pos() ];

// Ethernet cutout size (raw)
ethernet_size_yz = [ nic_get_ethernet_size().x, nic_get_ethernet_size().z ];

// Shield position (assumes centered left<->right on ethernet port) from middle of baffle and bottom of adapter floor
shield_pos_yz = [ midfront_of( nic_get_shield_center_pos() ).x, nic_get_shield_z() ];

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

module baffle_hole(pos,radius) {
  Wyse_Baffle_Cutout(config, pos)
    circle( radius+norm([tolerance.x,tolerance.z]) );
} // end baffle_hole

module expand_shield_cutout(size,tolerance) {
  assert( len(size) == 3 );

  w = max(tolerance,size.y+tolerance/2);

  intersection() {
    translate( [-tolerance, 0, -tolerance] )
      cube( [size.x+2*tolerance,size.y+tolerance,size.z+tolerance+w] );
    translate( [0,-(w-tolerance),0] )
      minkowski() {
        cube( size );
        rotate( [-90,0,0] ) cylinder( h=w, r1=w, r2=0 );
      }
  }
} // end expand_shield_cutout

module shield_cutout(pos,size) {
  Wyse_Baffle_Indent(config, pos)
  translate( [-size.x/2, 0, 0] )
    expand_shield_cutout( size, max(tolerance)/2 );
} // end shield_cutout

module mount(pos,simple=false) {
  Wyse_Mount(config,pos,mount_radius,0,simple);
} // end mount

module hole(pos) {
  Wyse_Hole(config,pos,mount_hole_radius,0);
} // end hole

module latches() {
  // Z-height of latches is the space below the bottom of the protruding tongue
  z_height = nic_get_pcb_size().z + 1.5*tolerance.z;

  // Rear (snap-fit)
  //
  // For center snap, positioned in center just behind PCB.
  //
  if( is_center_rear_snap() ) {
    rear_pos = midfront_of( [ nic_get_pcb_size().x/2, use_shield_mounting ? -tolerance.y/2 : -tolerance.y, z_height ] );

    Wyse_Latch( config, rear_pos, rear_snap_width, 1.00, style="tang2" );
  }
  //
  // For dual side snaps (negative value width), positioned
  // 1 mm from left/right sides just behind PCB.
  //
  else if( is_side_rear_snap() ) {
    snap_width  = abs( rear_snap_width );
    snap_offset = 1+snap_width/2;

    rear_pos1 = midfront_of( [ snap_offset, use_shield_mounting ? -tolerance.y : -2*tolerance.y, z_height ] );
    rear_pos2 = midfront_of( [ nic_get_pcb_size().x-snap_offset, use_shield_mounting ? -tolerance.y : -2*tolerance.y, z_height ] );

    Wyse_Latch( config, rear_pos1, snap_width, 1.00, style="tang2" );
    Wyse_Latch( config, rear_pos2, snap_width, 1.00, style="tang2" );
  }

  // Front (non-moving)
  //
  // These are the bars at the front of the adapter. They start
  // right from the corner of the PCB to just past the corresponding
  // mounting hole.
  //
  if( !use_shield_mounting ) {
    bottom_hole_xs = [ for( h = nic_get_bottom_holes() ) h.x ];

    {
      left_hole_x = min( bottom_hole_xs );
      left_len    = (left_hole_x - 0) + nic_get_bottom_hole_diameter()*.75;
      left_mid    = (0 + left_len)/2;
      left_center = midfront_of( [ left_mid, nic_get_pcb_size().y, z_height ] );

      Wyse_Latch( config, left_center, left_len, 1.0, style="square" );
    }

    {
      right_hole_x = max( bottom_hole_xs );
      right_len    = (nic_get_pcb_size().x - right_hole_x) + nic_get_bottom_hole_diameter()*.75;
      right_mid    = (nic_get_pcb_size().x + (nic_get_pcb_size().x-right_len))/2;
      right_center = midfront_of( [ right_mid, nic_get_pcb_size().y, z_height ] );

      Wyse_Latch( config, right_center, right_len, 1.0, style="square" );
    }
  }

  // Side "guides"
  //
  // Rails around sides of PCB if needed.
  //
  if( has_side_guides() ) {
    corner_distance = use_shield_mounting ? max( nic_get_shield_size().x, nic_get_pcb_size().x ) : nic_get_pcb_size().x;
    corner_position = (corner_distance+tolerance.x)/2;
    guide_size      = [ side_guide_width, nic_get_pcb_size().y*side_guide_percentage/100, nic_get_pcb_size().z+2*tolerance.z ];

    Wyse_Guide( config, [ -corner_position, nic_get_pcb_size().y*(use_shield_mounting ? 0 : 0.125) ], guide_size );
    Wyse_Guide( config, [ +corner_position, nic_get_pcb_size().y*(use_shield_mounting ? 0 : 0.125) ], guide_size );
  }
} // end latches

module trough(size) {
  Wyse_Trough( config, size );
} // end trough

module holder() {
  difference() {
    union() {

      difference() {
	// Blank
	Wyse_Blank(config);

	// trough below board
        for( size = trough_indent_sizes )
	  trough( size );
      }

      // Mounts below PCB holes
      if( !use_shield_mounting )
	for( m = mount_holes ) mount(m);

      // Latches
      latches();
    }

    // Ethernet cut out of baffle
    ethernet(ethernet_pos_yz, ethernet_size_yz);

    // Holes in mounts below PCBs cut out
    if( !use_shield_mounting )
      for( h = mount_holes ) hole(h);

    // Holes cut out of baffle
    if( use_shield_mounting )
      for( h = baffle_holes_yz ) baffle_hole(h,baffle_hole_radius);

    if( use_shield_mounting )
      shield_cutout( shield_pos_yz, nic_get_shield_size() );
  };
} // end holder

Wyse_Blank_Center(config) {
  intersection() {
    holder($fn=32);
    // Adding this cube lets you build only the bottom portion of
    // the adapter, which is the really the measurement critical
    // part for fitting.
    //cube( [100,100,2*5.5], center=true );
  }

  // Show the nic in place
  if( show_nic ) {
    translate( [nic_get_pcb_size().x/2,nic_get_pcb_size().y,Wyse_Get_Floor_Thickness(config)+tolerance.z/2] )
      rotate( [0,0,180] )
        nic( transparency=0.5, center=false, with_shield=use_shield, $fn=16 );
  }
}
