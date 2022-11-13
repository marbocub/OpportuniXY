/*
 *  MidAirCylinder.scad
 *  Copyright (C) 2022 @marbocub <marbocub@gmail.com>
 *
 *  This file is part of Opportunity 3D printer.
 *
 *  This work is licensed under the CC-BY-NC-SA 4.0 International License.
 *  (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)
 */

module mid_air_cylinder(r, h, ir=0, step=0.2, center=false)
{
    translate([0, 0, center ? -h/2 : 0])
        difference() {
            cylinder(r=r, h=h, center=false);
            let (dr = r + (ir>0 ? ir : r/2)) {
                translate([ dr, 0, h]) cube([r*2, r*2, step*2], center=true);
                translate([-dr, 0, h]) cube([r*2, r*2, step*2], center=true);
                translate([0,  dr, h]) cube([r*2, r*2, step*4], center=true);
                translate([0, -dr, h]) cube([r*2, r*2, step*4], center=true);
            }
        }
}