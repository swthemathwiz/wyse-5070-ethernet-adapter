//
// Copyright (c) Stewart H. Whitman, 2020.
//
// File:    primitives.scad
// Project: Dell Wyse 5070 2nd Ethernet Adapter Adapter
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    Shape primitives
//
// $Header$
//

include <smidge.scad>;

// Creates a right triangle with <height> and <base> and extrudes it
// to <thickness>.
//
module right_triangle(height, base, thickness) {
  translate( [+thickness,0,0] ) rotate( [0,-90,0] ) linear_extrude( height=thickness ) polygon( [[0,0], [0,height], [base,0]] );
} // end right_triangle

// Create a half cylinder
module half_cylinder(r,h,center=false) {
  translate( [center ? -h/2 : 0, 0, 0] )
    rotate( [90,0,0] ) rotate( [0,90,0] )
    difference() {
      cylinder( r=r, h=h );
      translate( [-2*r,-r, -SMIDGE ] ) cube( [ 2*r,2*r,h+2*SMIDGE] );
    }
} // end half_cylinder

// Create a triangle with 2 sides the same
module equi_triangle(height_and_base, thickness,center=false) {
  translate( [ center ? -thickness/2 : 0, 0, 0 ] ) {
    right_triangle(height_and_base, height_and_base, thickness);
    mirror( [0,0,1] ) right_triangle(height_and_base, height_and_base, thickness);
  }
} // end equi_triangle

// Create a somewhat complex tang (a right triangle over a cube)
module tang(l,h,w,percent=25,center=false) {
  assert( percent > 0 && percent < 100 );
  //echo( ["tang",l,w,h,percent] );

  p = percent/100;

  translate( [-w/2,0,center?-h/2 : 0] ) {
    translate( [0,0,p*h] )
      right_triangle(l,(1-p)*h,w);
    cube( [w,l,p*h] );
  }
} // end tang

// Create a somewhat complex tang (a right triangle over another triangle)
module tang2(l,h,w,percent=25,center=false) {
  assert( percent > 0 && percent < 100 );
  //echo( ["tang2",l,h,w,percent] );

  p = percent/100;

  translate( [-w/2,0,center?-h/2 : 0] ) {
    translate( [0,0,p*h] )
      right_triangle(l,(1-p)*h,w);
    translate( [0,0,p*h] )
      mirror( [0,0,1] ) right_triangle(l,p*h,w);
  }
} // end tang2

// Create a gusset (pyramid that fits in corner)
module gusset(width,height=0,center=true) {
  w = width;
  h = height == 0 ? w : height;
  translate( [0,0,center?-h/2:0] )
    polyhedron( points=[[0,0,0], [w,0,h], [0,0,h], [0,w,h]],
                faces=[[1,2,3],[0,1,3],[0,2,1],[0,3,2]] );
} // end gusset

// A corner rounding shape for a designated corner (on the XY plane)...
module round_corner_xy(radius,v,direction) {
  assert( direction >= 0 && direction <= 3 );

  if( radius > 0 ) {
    // Additional amount on Z
    z_multiplier = 2;
    z_translate  = [ [-1, -1, 0], [+1, -1, 0], [+1, +1, 0], [-1, +1, 0] ];

    // Get an inverted quarter pie slice
    color( "purple" )
    translate( [v.x,v.y,0] )
      translate( z_translate[direction]*radius )
	rotate( [0,0,90*direction] )
	  difference() {
	    translate( [0,0,-v.z*z_multiplier/4] ) cube( [radius+SMIDGE,radius+SMIDGE,v.z*z_multiplier] );
	    translate( [0,0,v.z*z_multiplier/4] ) cylinder( v.z*z_multiplier+SMIDGE, r=radius, center=true );
	  }
  }
} // end round_corner_xy

// A corner rounding shape for a designated corner (on the YZ plane)...
module round_corner_yz(radius,v,direction) {
  assert( direction >= 0 && direction <= 3 );

  if( radius > 0 ) {
    // Additional amount on X
    x_multiplier = 2;
    x_translate  = [ [0, -1, +1], [0, -1, -1], [0, +1, -1], [0, +1, +1] ];

    // Get an inverted quarter pie slice
    color( "purple" )
      translate( [0,v.y,v.z] )
	translate( x_translate[direction]*radius )
	  rotate( [90*direction,0,0] )
	  rotate( [0,90,0] )
	    difference() {
	      translate( [0,0,-v.x*x_multiplier/4] ) cube( [radius+SMIDGE,radius+SMIDGE,v.x*x_multiplier] );
	      translate( [0,0,v.x*x_multiplier/4] ) cylinder( v.x*x_multiplier+SMIDGE, r=radius, center=true );
	    }
  }
} // end round_corner_yz

// A corner rounding shape for a designated corner (on the XZ plane)...
module round_corner_xz(radius,v,direction) {
  assert( direction >= 0 && direction <= 3 );

  if( radius > 0 ) {
    // Additional amount on Y
    y_multiplier = 2;
    y_translate  = [ [-1, 0, -1], [-1, 0, +1], [+1, 0, +1], [+1, 0, -1] ];

    // Get an inverted quarter pie slice
    color( "purple" )
      translate( [v.x,0,v.z] )
	translate( y_translate[direction]*radius )
	  rotate( [0,90*direction,0] )
	  rotate( [90,0,0] )
	    difference() {
	      translate( [0,0,-v.y*y_multiplier/4] ) cube( [radius+SMIDGE,radius+SMIDGE,v.y*y_multiplier] );
	      translate( [0,0,v.y*y_multiplier/4] ) cylinder( v.y*y_multiplier+SMIDGE, r=radius, center=true );
	    }
  }
} // end round_corner_xz
