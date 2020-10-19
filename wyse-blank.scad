//
// Copyright (c) Stewart H. Whitman, 2020.
//
// File:    wyse-blank.scad
// Project: Dell Wyse 5070 2nd Ethernet Adapter Adapter
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:
//
// $Header$
//

include <primitives.scad>
include <smidge.scad>
include <hash.scad>

// Layout...
//  all sizes in mm

// Depth in front of the back of the ears (minimal)
raw_depth = 24;

// Inner width
raw_width = 42;

// Thickness of base
default_thickness = 1.6;

// Extra depth is entirely dependent on the thing put inside
default_extra_depth = 10;

// Default round over radius for trough (does provide corner support)
default_trough_round_over = 6;

// Default round over radius for main body (mainly decorative)
default_round_over = 3;

// Support thickness
default_support_thickness = 1.6;

// Baffle Height (below the top of the "ears")
default_baffle_height = 18;

// Baffle thickness
default_baffle_thickness = 1.6;

// Front cut size
default_front_cut = [ default_baffle_thickness/2, default_thickness ];

// Hash
default_config = [
  ["thickness", default_thickness],
  ["extra_depth", default_extra_depth],
  ["baffle_height", default_baffle_height],
  ["baffle_thickness", default_baffle_thickness],
  ["support_thickness", default_support_thickness],
  ["round_over", default_round_over],
  ["trough_round_over", default_trough_round_over],
  ["front_cut", default_front_cut],
];
function GV_(config,var) = hash_get_default_hash( config, var, default_config );

function Wyse_Get_Raw_Depth() = raw_depth;

function Wyse_Get_Raw_Width() = raw_width;

function Wyse_Get_Interior_Depth(config) = raw_depth + GV_(config,"extra_depth") - GV_(config,"baffle_thickness");

function Wyse_Get_Interior_Width(config) = raw_width - 2*GV_(config,"support_thickness");

function Wyse_Get_Interior_Size(config) = [ Wyse_Get_Interior_Width(config), Wyse_Get_Interior_Depth(config) ];

function Wyse_Get_Floor_Thickness(config) = GV_(config,"thickness");

// Center the blank (N.B. does not include the handle)...
module Wyse_Blank_Center(config) {
  translate( [ 0, -Wyse_Get_Interior_Depth(config)/2, 0 ] ) children();
} // end Wyse_Blank_Center

// Cutout the 2-dimensional children from the baffle
module Wyse_Baffle_Cutout( config, pos ) {
  baffle_thickness = GV_(config,"baffle_thickness");
  thickness = GV_(config,"thickness");

  SMIDGE=0.001;
  color("yellow" )
    translate( [pos.x, -baffle_thickness-SMIDGE, thickness+pos.y] )
      rotate( [90,0,180] )
        linear_extrude( baffle_thickness+2*SMIDGE ) children();
} // end Wyse_Baffle_Cutout

// Position a mount
module Wyse_Mount( config, pos, radius, extra_height=0, simple=false ) {
  thickness = GV_(config,"thickness");
  interior_size = Wyse_Get_Interior_Size( config );

  p = concat( pos, 0 );
  h = thickness+extra_height;
  translate( p ) {
    color("orange")
      union() {
	// Mount tapered downward for strength/hold
	cylinder( h, r=radius );

        // Fill-in support area to left/right with 2 rectangles
        if( !simple && p.y != 0 ) {
	  translate( [ ((p.x < 0) ? -interior_size.x/2+abs(p.x) : 0), -p.y, 0 ] ) cube( [ interior_size.x/2-abs(p.x), p.y+radius, h ] );
	  translate( [ ((p.x < 0) ? -interior_size.x/2+abs(p.x) : -radius), -p.y, 0 ] ) cube( [ interior_size.x/2-abs(p.x)+radius, p.y, h ] );
        }
      }
  }
} // end Wyse_Mount

// Position a hole
module Wyse_Hole( config, pos, radius, extra_height=0, countersink=false) {
  thickness = GV_(config,"thickness");

  p = concat( pos, -SMIDGE );
  h = thickness+extra_height;

  translate( p ) cylinder( h+2*SMIDGE, r=radius );

  if( countersink ) {
    m_radius = min( radius+h, radius*2 );
    translate( p ) cylinder( h=m_radius, r1=m_radius, r2=0 );
  }
} // end Wyse_Hole

// Position a nub
module Wyse_Nub( config, pos, radius, height, percent=50) {
  assert( percent >= 0 && percent <= 100 );

  thickness = GV_(config,"thickness");

  p = concat( pos, 0 );

  h_per   = percent/100;
  h_cyl   = thickness+h_per*height;
  h_cone  = (1-h_per)*height;

  translate( p ) cylinder( h_cyl, r=radius );
  if( h_cone > 0 )
    translate( p + [0,0,h_cyl] ) cylinder( h_cone, r1=radius, r2=0 );
} // end Wyse_Nub

// Position a latch
module Wyse_Latch( config, pos, width, latch_size=1, style="tang" ) {
  assert( style == "cylinder" || style == "triangle" || style == "square" || style == "tang" || style == "tang2" );

  thickness = GV_(config,"thickness");

  p = [ pos.x, pos.y, thickness ];
  latch_height = pos.z;

  // If a rear latch, build support attachment
  if( p.y > 0 ) {
    s = latch_height + (style == "square" ? latch_size : 2*latch_size);

    translate( p + [-width/2, 0, 0] ) color( "silver" )
      cube( [width, s/4, s] );

    translate( p + [-width/2, s/4, 0] ) color( "silver" )
      right_triangle( s/2, s, width );
  }

  translate( p + [ 0, 0, latch_height+latch_size] )
    rotate( [0, 0, p.y > 0 ? 180 : 0] ) {
      // Tang - Top triangle with cube below
      if( style == "tang" )
	tang( latch_size, 2*latch_size, width, center=true );
      // Tang - Two triangles of different sizes
      else if( style == "tang2" )
	tang2( latch_size, 2*latch_size, width, center=true );
      // Tang - half-round cylinder
      else if( style == "cylinder" )
	half_cylinder( latch_size, width, center=true );
      // Tang - like >
      else if( style == "triangle" )
	equi_triangle( latch_size, width, center=true );
      // Tang - 1/2 square
      else if( style == "square" )
	translate( [0, (p.y > 0 ? -1 : +1) * latch_size/2, -latch_size/2] ) cube( [ width, latch_size, latch_size ], center=true );
    }
} // end Wyse_Latch

// Position a guide parallel to the edge of the board
module Wyse_Guide( config, pos, size ) {
  thickness = GV_(config,"thickness");
  p = concat( pos, thickness );
  translate( p + [p.x < 0 ? -size.x : 0, 0, 0] ) cube( size );
} // end Wyse_Guide

// Cut a trough in the floor. Indent size is [front,rear,left,right]
module Wyse_Trough( config, indent_size, round_over=undef, trough_thickness=undef ) {
  assert( is_list(indent_size) && len(indent_size) == 4 );

  thickness      = GV_(config,"thickness");
  cut_thickness  = is_undef(trough_thickness) ? thickness : trough_thickness;
  cut_round_over = is_undef(round_over) ? GV_(config,"trough_round_over") : round_over;

  if( cut_thickness ) {
    interior_size = Wyse_Get_Interior_Size(config);

    indent_depth = indent_size[0]+indent_size[1]; // Front + Rear
    indent_width = indent_size[2]+indent_size[3]; // Left + Right

    v = concat( interior_size - [indent_width, indent_depth], cut_thickness+2*SMIDGE );

    color( "silver" )
      translate( [-interior_size.x/2+indent_size[2], indent_size[0], thickness - cut_thickness - SMIDGE ] )
	difference () {
	  cube( v );
	  round_corner_xy( cut_round_over, [0,v.y,v.z], 1 );
	  round_corner_xy( cut_round_over, [v.x,v.y,v.z], 0 );
	}
  }
} // end Wyse_Trough

// Extra depth (Completely depends on adapter)
module Wyse_Blank( config=[], filler_only=false ) {

  function V_(key) = hash_get_default_hash( config, key, default_config );

  extra_depth = V_("extra_depth");
  baffle_height = V_("baffle_height");
  baffle_thickness = V_("baffle_thickness");
  support_thickness = V_("support_thickness");
  round_over = V_("round_over");
  thickness = V_("thickness");
  front_cut = V_("front_cut");

  // Total depth
  inner_depth = raw_depth + extra_depth;

  // Total width
  inner_width = raw_width;

  // Upside down build
  upside_down = filler_only;

  // Ear parameters:
  //
  // The bigger ear (fka. "right") is colored "green". It is closer to the
  // base of the computer.
  //
  // The smaller ear (fka. "left") is colored "blue". It is closer to the
  // top of the computer.
  //
  // The screws used are M3 and you want slim heads (sometimes called "wafer"
  // heads). The screw holes are over-sized, with the computer providing
  // metal threads. The M3 screw parameters are: diameter 3mm, head diameter
  // about 6.25mm, head thickness a little less than 1mm.
  //
  // The hole positions are relative to the center of the ear. The holes
  // are slightly off-center and at different positions.
  //

  // Ear thickness
  ear_thickness = filler_only ? 1.4 : 2;

  // Ear right width
  ear_big_width = 14.5;
  ear_big_hole = [-1.9, -2];

  // Ear left width
  ear_small_width = 9.5;
  ear_small_hole = [-0.75, +1.5];

  // Ear depth (the length of the ears is the same on both sides)
  ear_depth = 16.5;

  // Ear lobe (provides a locking and aligning mechanism)
  // This is really unused, since we build right-side up and 3d printing
  // with support is more of a pain than it's worth.
  ear_lobe_depth = ear_depth;
  ear_lobe_width = 1;
  ear_lobe_height = upside_down ? ear_thickness+0.75 : ear_thickness;

  // Hole radius for sized for M3 mounting screws
  // Diameter is about 3mm, head size is about 6.25mm
  ear_hole_radius = 3.6/2;
  ear_hole_recess_radius = 4;
  // Recess thickness is based on there needing at least 1mm to clamp, or recess of 1mm to conceal screw head
  ear_hole_recess_thickness = upside_down ? 0 : ((ear_thickness > 2) ? 1 : ear_thickness-1);

  module base() {
    color("gray") cube( [inner_width,inner_depth,thickness] );
  } // end base

  module handle() {
    color("gray") translate( [inner_width/2,inner_depth-inner_width/8,0] ) cylinder( r=inner_width/4, h=thickness );
  } // end handle

  module baffle() {
    color("red") translate( [ 0, 0, thickness ] ) cube( [inner_width,baffle_thickness,baffle_height] );
  } // end baffle

  module support() {
    if( support_thickness ) {
      if( filler_only )
	color("brown") right_triangle( inner_depth-baffle_thickness, baffle_height, support_thickness );
      else {
	color("brown") cube( [support_thickness, raw_depth-baffle_thickness, baffle_height] );
        if( inner_depth-raw_depth > round_over )
	  translate( [0,raw_depth-baffle_thickness,0] ) color("brown") right_triangle( inner_depth-raw_depth-round_over, baffle_height, support_thickness );
      }
    }
  } // end support

  module lobe() {
    color("red") cube( [ear_lobe_width,ear_lobe_depth,ear_lobe_height] );
  } // end lobe

  module hole(c,d,r=ear_hole_radius) {
    translate( c/2 + concat( d, 0 ) ) cylinder( c.z+2*SMIDGE, r=r, center = true );
  } // end hole

  module hole_with_recess(c,d,r=ear_hole_radius,recess_thickness=ear_hole_recess_thickness,r_recess=ear_hole_recess_radius) {
    hole( c, d, r );
    if( recess_thickness >= 0 )
      translate( [ c.x/2, c.y/2, c.z-recess_thickness/2 ] + concat(d,0) ) cylinder( recess_thickness+SMIDGE, r=ear_hole_recess_radius, center=true );
  } // end hole_with_recess

  module small_ear() { // fka. left
    c = [ear_small_width,ear_depth,ear_thickness];
    difference() {
      union() {
	color("blue") difference() { cube( c ); hole_with_recess( c, ear_small_hole ); }
	translate( [-ear_lobe_width,ear_depth-ear_lobe_depth,upside_down?0:-ear_lobe_height+ear_thickness] ) lobe();
      }
      round_corner_xy( round_over, [-ear_lobe_width,0,ear_lobe_height], 2 );
      round_corner_xy( round_over, [-ear_lobe_width,ear_depth,ear_lobe_height], 1 );
    }
  } // end small_ear

  module big_ear() { // fka. right
    c = [ear_big_width,ear_depth,ear_thickness];
    difference() {
      union() {
	color("green") difference() { cube( c ); hole_with_recess( c, ear_big_hole ); }
	translate( [ear_big_width,ear_depth-ear_lobe_depth,upside_down?0:-ear_lobe_height+ear_thickness] ) lobe();
      }
      round_corner_xy( round_over, [ear_big_width+ear_lobe_width,0,ear_lobe_height], 3 );
      round_corner_xy( round_over, [ear_big_width+ear_lobe_width,ear_depth,ear_lobe_height], 0 );
    }
  } // end big_ear

  module gusset_up(percent, width, multiplier=1.5) {
    assert(percent >= 0 && percent <= 100);

    gusset_height = multiplier * width;

    pos = [0, baffle_thickness, thickness + baffle_height*percent/100 - gusset_height ];

    translate( [ support_thickness, 0, 0 ] + pos ) gusset(width,gusset_height,center=false);
    translate( [ inner_width-support_thickness, 0, 0 ] + pos ) rotate([0,0,90]) gusset(width,gusset_height,center=false);
  } // end gusset_up

  module frontcut() {
    h = front_cut[1];
    w = front_cut[0];
    translate( [-SMIDGE, -SMIDGE, -SMIDGE ] ) {
      translate( [0,0,h-w] ) right_triangle( w, w, inner_width+2*SMIDGE );
      cube( [ inner_width+2*SMIDGE, w+2*SMIDGE, (h-w)+2*SMIDGE ] );
    }
  } // end frontcut

  translate( [-inner_width/2,-baffle_thickness,0] ) {
    if( !filler_only ) {
      union() {
	difference() {
	  union() {
	    base();
	    handle();
	    baffle();
	    gusset_up( 100, 3, 1.5 );
	    translate( [ 0, baffle_thickness, thickness ] ) support();
	    translate( [ inner_width-support_thickness, baffle_thickness, thickness ] ) support();
	    translate( [ inner_width, raw_depth-ear_depth, baffle_height+thickness-ear_thickness ] ) big_ear();
	    translate( [ -ear_small_width, raw_depth-ear_depth, baffle_height+thickness-ear_thickness ] ) small_ear();
	  };
          frontcut();
	  round_corner_xy( min(round_over,baffle_height), [0, inner_depth, thickness+baffle_height], 1 );
	  round_corner_xy( min(round_over,baffle_height), [inner_width, inner_depth,thickness+baffle_height], 0 );
	}
      }
    }
    else {
      union() {
	difference() {
	  union() {
	    base();
	    baffle();
	    translate( [ 0, baffle_thickness, thickness ] ) support();
	    translate( [ inner_width-support_thickness, baffle_thickness, thickness ] ) support();
	    translate( [ inner_width, 0, 0 ] ) mirror( [1,0,0] ) {
	      translate( [ inner_width, raw_depth-ear_depth, 0 ] ) big_ear();
	      translate( [ -ear_small_width, raw_depth-ear_depth, 0 ] ) small_ear();
	    }
	  };
	  round_corner_xy( min(round_over,baffle_height), [0, inner_depth, thickness+baffle_height], 1 );
	  round_corner_xy( min(round_over,baffle_height), [inner_width, inner_depth, thickness+baffle_height], 0 );
	  round_corner_xz( round_over, [0, inner_depth, baffle_height+thickness], 3 );
	  round_corner_xz( round_over, [inner_width, inner_depth, baffle_height+thickness], 0 );
	}
      }
    }
  }
} // end Wyse_Blank

// Wyse_Filler:
//
// Generates a replacement blank to fill hole.
//
module Wyse_Filler() {
  config = [
    ["extra_depth", default_round_over],
    ["thickness", 1.6],
    ["baffle_height", 14],
    ["baffle_thickness", 1.6],
    ["support_thickness", 2],
  ];
  Wyse_Blank(config,filler_only=true);
} // end Wyse_Filler

Wyse_Blank($fn=48);
