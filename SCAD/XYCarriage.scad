/*
 *  XYCarriage.scad
 *  Copyright (C) 2022 @marbocub <marbocub@gmail.com>
 *
 *  This file is part of Opportunity 3D printer.
 *
 *  This work is licensed under the CC-BY-NC-SA 4.0 International License.
 *  (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)
 */

include <BOSL2/std.scad>
include <NopSCADlib/lib.scad>

include <AxisXY.scad>
include <vitamins/MidAirCylinder.scad>

version = 3;

function y_carriage_offset(type) = carriage_total_heights(type).x+1.5 - carriage_pitch_x(carriage_types(type).y)/2;

module xy_carriage_left(type, size, pos)
{
    xy_carriage_base(type, size=size, pos=pos);
    //xy_carriage_lower(type=type, size=size, pos=pos);
    //xy_carriage_upper(type=type, size=size, pos=pos);
}

module xy_carriage_right(type, size, pos)
{
    rotate([0, 180, 0])
        xy_carriage_base(type, size=size, pos=pos);
}

module xy_carriage(type, size, pos)
{
    translate([-10, 0, 35/2]) rotate([0,180,0])
        xy_carriage_upper(type=type, size=size, pos=pos);
    translate([ 10, 0, 35/2])
        xy_carriage_lower(type=type, size=size, pos=pos);
}

module xy_carriage_upper(type, size, pos)
{
    intersection() {
        xy_carriage_base(type, size=size, pos=pos);
        xy_carriage_slice_mask(type);
    }
}

module xy_carriage_lower(type, size, pos)
{
    difference() {
        xy_carriage_base(type, size=size, pos=pos);
        xy_carriage_slice_mask(type);
    }
}

module xy_carriage_slice_mask(type)
{
    corexy_type = corexy_type(type);
    p1_pr = pulley_pr(coreXYR_return_bottom_idler(corexy_type));
    p0_pr = pulley_pr(coreXYR_gantory_bottom_idler(corexy_type));
    p4_pr = pulley_pr(coreXYR_gantory_top_idler(corexy_type));
    p0 = [p1_pr*2 + p0_pr + belt_offsets(type).x/2, -p0_pr, 0];
    p4 = [p4_pr + belt_offsets(type).x/2, p4_pr, 0];

    groove_width = 5;
    chamfer = 5;
    gantory_height = gantory_height(type);
    gantory_front  = carriage_total_heights(type).x + belt_back_thickness(type);

    pfit1  = [groove_width+chamfer+5, gantory_front+gantory_height+chamfer/2, 0];
    pfit2  = pfit1 + [12, 0, 0];
    pfit3  = [groove_width+3, -(-y_carriage_offset(type) + carriage_pitch_x(carriage_types(type).y)/2), 0];
    pfit4  = [carriage_total_heights(type).y+11, gantory_front/2 + groove_width/4, 0];
    pfit = [pfit1, pfit2, pfit3, pfit4];

    difference() {
        translate([30, 0, 25]) cube([100, 100, 50], center=true);
        translate(p4 + [0, 0, 1]) cylinder(r=p4_pr, h=2, center=true);
    }
    translate(p0 + [0, 0, -1]) cylinder(r=p0_pr, h=2, center=true);
    for (p=pfit) translate(p)
        cylinder(r=2.5/2, h=5, center=true);
}

module xy_carriage_base(type, size, pos)
{
    corexy_type = corexy_type(type);
    base_thickness = 10;
    r = 16 / 2;
    chamfer = 5;
    groove_width = 5;

    gantory_height = gantory_height(type);
    gantory_front  = carriage_total_heights(type).x + belt_back_thickness(type);
    height = gantory_height + base_thickness*2;

    p1_pr = pulley_pr(coreXYR_return_bottom_idler(corexy_type));
    p0_type = coreXYR_gantory_bottom_idler(corexy_type);
    p0_pr = pulley_pr(p0_type);
    p0_bore = pulley_bore(p0_type);
    p0_extent = pulley_extent(p0_type);
    p0_height = pulley_height(p0_type);
    p4_type = coreXYR_gantory_top_idler(corexy_type);
    p4_pr = pulley_pr(p4_type);
    p4_bore = pulley_bore(p4_type);
    p4_extent = pulley_extent(p4_type);
    p4_height = pulley_height(p4_type);
    p0 = [p1_pr*2 + p0_pr + belt_offsets(type).x/2, -p0_pr, 0];
    p4 = [p4_pr + belt_offsets(type).x/2, p4_pr, 0];

    pscrew1 = [(size.x-gantory(type)[2][0])/2-carriage_total_heights(type).y, gantory_front + gantory_height/2, 0, 3];
    pscrew2 = pscrew1 + [(gantory(type)[2][0] - gantory(type)[2][1])/2, 0, 0, 0];
    pscrew3 = [carriage_total_heights(type).y+5, gantory_front/2+groove_width/4, 0, 5];

    pfit1  = [groove_width+chamfer+5, gantory_front+gantory_height+chamfer/2, 0];
    pfit2  = pfit1 + [12, 0, 0];
    pfit3  = [groove_width+3, -(-y_carriage_offset(type) + carriage_pitch_x(carriage_types(type).y)/2), 0];
    pfit4  = [carriage_total_heights(type).y+11, gantory_front/2 + groove_width/4, 0];
    pfit = [pfit1, pfit2, pfit3, pfit4];

    difference() {
        xy_carriage_body();
        xy_carriage_hole_y_carriage();
        xy_carriage_hole_gantory();
        xy_carriage_hole_beltpath();
        xy_carriage_hole_screw();
        xy_carriage_hole_fitting();
        xy_carriage_hole_tooth_text();
        xy_carriage_hole_gantory_text();
        xy_carriage_hole_version_text();
    }


    module xy_carriage_body() {
        hull() {
            // gantory support
            box = [gantory_height*1.5, gantory_height + carriage_total_heights(type).x + belt_back_thickness(type), height];
            translate([(size.x - gantory_length(type))/2, box.y/2, 0])
                cuboid([box.x+chamfer*2, box.y+chamfer*2, box.z], chamfer=chamfer);

            // carriage support
            difference() {
                translate([base_thickness/2, y_carriage_offset(type), 0])
                    cuboid([base_thickness, carriage_block_length(carriage_types(type).y)+chamfer*2, height], chamfer=chamfer);
                translate([50, -5-r-p0_pr, 0])
                    cube([100, 10, height+2], center=true);
            }

            // pulley support
            for(p=[p0, p4]) translate(p)
                cylinder(r=r, h=height, center=true);
        }
    }

    module xy_carriage_hole_beltpath() {
        l = 100;
        difference() {
            // pulley
            union() {
                // pulley
                for (p=[
                    [p0, p0_extent, p0_height, -1], 
                    [p4, p4_extent, p4_height, 1]
                ]) translate(p[0] + [0, 0, p[3]*belt_offsets(type).z/2])
                    cylinder(r=p[1]+2, h=p[2]+1, center=true);

                // p0 support
                translate(p0 + [l/2, 0, -belt_offsets(type).z/2]) 
                    cube([l, p0_pr*2, p0_height+1], center=true);

                // belt: head-p0, p0-p1, p4-head
                for (p=[
                    [p1_pr*2+p0_pr+l/2, 0,           -belt_offsets(type).z/2], 
                    [p1_pr*2,          -(p0_pr+l/2), -belt_offsets(type).z/2], 
                    [p4_pr+l/2,         0,            belt_offsets(type).z/2]
                ]) translate(p + [belt_offsets(type).x/2, 0, 0])
                    cuboid([p[1] ? groove_width : l, p[1] ? l : groove_width, p0_height+1], chamfer=1, edges=[p[2]>0?TOP:BOT]);
            }

            // pulley bearing support
            for (p=[
                [p0, p0_bore, p0_height, -1], 
                [p4, p4_bore, p4_height, 1]
            ]) translate(p[0] + [0, 0, p[3]*belt_offsets(type).z/2])
                for (i=[0, 1]) rotate([i*180, 0, 0]) translate([0, 0, belt_offsets(type).z/2])
                    cylinder(r1=(p[1]+1)/2, r2=(p[1]+2)/2, h=1, center=true);
        }

        // belt: carriage side
        h = 16.4;
        w = 4;
        for (p=[[w/2, 0, -h/4], [w/2, l/2+p4.y,  h/4]]) translate(p)
            cube([w, l, h/2], center=true);
    }

    module xy_carriage_hole_screw() {
        head_depth = 5;
        print_thick = 0.2;
        //screw_length = height - head_depth*2 - print_thick*2;
        screw_length = height - head_depth*2 + print_thick*2;
        for (p=[
            [p0, p0_bore, -1], 
            [p4, p4_bore,  1], 
            [pscrew1, pscrew1[3], [-1,1]], 
            [pscrew2, pscrew2[3], [-1,1]],
            [pscrew3, pscrew3[3],    1  ]
        ]) translate(select(p[0], [0,1,2])) {
            cylinder(r=0.84*p[1]/2, h=screw_length, center=true);
            for (i=p[2]) {
                translate([0,0, i*height/2]) rotate([0, i>0?180:0, 0])
                    mid_air_cylinder(r=p[1], h=head_depth*2, ir=p[1]/2, center=true);
                translate([0,0, i*screw_length/4])
                    cylinder(r=p[1]/2, h=screw_length/2, center=true);
            }
        }

        carriage  = carriage_types(type).y;
        translate([0, y_carriage_offset(type), 0]) rotate([0, 90, 0])
            for (p=square([carriage_pitch_x(carriage), carriage_pitch_y(carriage)], center=true)) move(p) {
                translate([0, 0,-1]) cylinder(r=3/2, h=9+2);
                if (p.y>0) {
                    translate([0, 0, 6]) cylinder(r=6/2, 12);
                    hull() {
                        translate([0, 0, 17]) cylinder(r=6/2, h=2);
                        translate([p.x>0 ? -8 : 8, 3, 13]) cylinder(r=6/2, h=12);
                    }
                    translate([0, 0, 7]) rotate([8, 0, 0]) cylinder(r=3.5/2, 100);
                } else {
                    if (p.x>0) {
                        translate([0, 0, 6]) cylinder(r=6/2, 4);
                        hull() {
                            translate([ 0, 0,  6]) cylinder(r=6/2, h=4);
                            translate([-3.5, 0, 14]) cylinder(r=6/2, h=4);
                        }
                    } else {
                        translate([0, 0, 6]) cylinder(r=6/2, 12);
                        difference() {
                            rotate([0, 0, -27]) {
                                    hull() {
                                        translate([ 0, 0, 7]) cylinder(r=3/2, h=9);
                                        translate([14, 0, 7]) cylinder(r=3/2, h=2);
                                    }
                                    hull() {
                                        translate([ 0, 0, 14]) cylinder(r=6/2, h=3);
                                        translate([14, 0,  7]) cylinder(r=6/2, h=3);
                                    }
                            }
                            translate([15.001, 0, 0]) cube([10, 50, 50], center=true);
                        }
                        //translate([0, 0, 7]) rotate([-21, 0, 0]) cylinder(r=3.5/2, 100);
                        translate([0, 0, 7]) rotate([5.5, 0, 0]) cylinder(r=3.5/2, 100);
                    }
                }
            }
    }

    module xy_carriage_hole_gantory() {
        translate([
            (size.x - gantory_length(type))/2 - carriage_total_heights(type).y, 
            carriage_total_heights(type).x + belt_back_thickness(type)
        ]) {
            len = 100;
            gap = 0.1;
            hg = gantory_height(type);
            wg = gantory_height(type);
            hr = rail_width(rail_types(type).x);
            wr = rail_height(rail_types(type).x);
            for (p = [
                [len+2 , wg, hg,  1],   // gantory
                [len-40, wr, hr, -1]    // rail
            ]) {
                translate([len/2,  p.y/2 * p[3]])
                    cube(p + [0, gap*2, gap*2], center=true);
            }
        }
    }

    module xy_carriage_hole_y_carriage() {
        gap=0.1;
        translate([-10, 0, 0])
            cuboid([20, 100, carriage_width(carriage_types(type).y)+gap*2], chamfer=sqrt(2)/2);
    }

    module xy_carriage_hole_fitting() {
        gap=0.1;
        for (p=pfit) {
            difference() {
                translate(p+[0,0,-2.5/2  ]) cylinder(r= 2.5/2,               h=2.5, center=true);
                translate(p+[0,0,-1.0/2  ]) cylinder(r =2.5/2-gap,           h=1.0, center=true);
                translate(p+[0,0,-1.0/2-1]) cylinder(r2=2.5/2-gap, r1=1.5/2, h=1.0, center=true);
            }
        }
    }

    module xy_carriage_hole_tooth_text() {
        size=3;
        translate(p0 + [0,0, -belt_offsets(type).z/2]) rotate([0, 90, 0])
            for (i=[-90, 90]) rotate([0, i, 0]) translate([p0_bore/2+0.5, -size/2, -(p0_height+1)/2-0.5])
                linear_extrude(1)
                    text(str(pulley_teeth(p0_type)), size=size);
    }

    module xy_carriage_hole_gantory_text() {
        size=3;
        gantory_back = carriage_total_heights(type).x + gantory_height(type) + belt_back_thickness(type);
        translate([20, gantory_back-size-1]) rotate([0, 90, 0])
            for (i=[-90, 90]) rotate([0, i, 0]) translate([-5.5, 0, -gantory_height(type)/2-0.5])
                linear_extrude(1)
                    text(str(gantory_extrusion(type)[0]), size=size);
    }

    module xy_carriage_hole_version_text() {
        size=3;
        gantory_back = carriage_total_heights(type).x + gantory_height(type) + belt_back_thickness(type);
        translate([31, gantory_back-size-1]) rotate([0, 90, 0])
            for (i=[-90, 90]) rotate([0, i, 0]) translate([-2, 0, -gantory_height(type)/2-0.5])
                linear_extrude(1)
                    text(str("V", version), size=size);
    }
}
