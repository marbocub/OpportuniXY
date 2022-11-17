/*
 *  ABIdlerMount.scad
 *  Copyright (C) 2022 @marbocub <marbocub@gmail.com>
 *
 *  This file is part of Opportunity 3D printer.
 *
 *  This work is licensed under the CC-BY-NC-SA 4.0 International License.
 *  (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)
 */

include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <NopSCADlib/lib.scad>

include <AxisXY.scad>
include <vitamins/MidAirCylinder.scad>

module ABIdlerMountWithTensionerLeft(type, reverse)
{
    p1 = idler_offset_bottom_left(type, reverse);

    ab_idler_mount_body(type, reverse);
    translate([p1.x, -stroke/2]) rotate([0, 90, 0]) ab_idler_mount_slider(type, reverse);
}

module ABIdlerMountWithTensionerRight(type, reverse)
{
    p1 = idler_offset_bottom_left(type, reverse);

    mirror([1, 0, 0])
        ab_idler_mount_body(type, reverse);
    translate([-p1.x, -stroke/2]) rotate([0, 90, 0]) ab_idler_mount_slider(type, reverse);
}

module ABIdlerMountWithTensionerRender(type, reverse)
{
    space = 30;

    translate([-space/2, 0]) difference() {
        ab_idler_mount_body(type, reverse);
        ab_idler_mount_mask();
    }

    translate([space/2, 0]) rotate([0, 180, 0]) intersection() {
        ab_idler_mount_body(type, reverse);
        ab_idler_mount_mask();
    }
}

stroke = 5;
chamfer = 5;
thickness = 7.5;
slider_thickness = 4.5;
slider_width = 12;
gap = 0.1;

module ab_idler_mount_mask()
{
    translate([0, 0, 50]) cube([100, 100, 100], center=true);
}

module ab_idler_mount_slider(type, reverse)
{
    frame_height = motor_frame_height(type);
    corexy_type = corexy_type(type);
    p1_type = coreXYR_return_bottom_idler(corexy_type);
    p1_er = pulley_extent(p1_type);
    p1_pr = pulley_pr(p1_type);
    p1_height = pulley_width(p1_type);
    p1 = idler_offset_bottom_left(type, reverse);

    translate([0, -frame_height]) body();

    module body()
    {
        intersection() {
            union() {
                difference() {
                    body = [
                        frame_height + thickness*2,
                        frame_height + slider_thickness + p1_er + stroke,
                        slider_width
                    ];
                    translate([0, body.y/2-slider_thickness, 0]) {
                        cuboid(body, chamfer=chamfer, edges=[FRONT], except=[TOP, BOTTOM]);
                        translate([0, body.y/2]) rotate([0, 90, 0])
                            cylinder(r=slider_width/2, h=100, center=true);
                    }
                    mask = [
                        frame_height + gap*2,
                        body.y + gap + slider_width/2,
                        body.z + gap,
                    ];
                    translate([0, mask.y/2])
                        cube(mask, center=true);
                    translate([0, frame_height+p1_er+stroke])
                        rotate([0,90,0]) cylinder(r=5/2, h=100, center=true);
                }
                l = 17;
                translate([0, -l/2+gap]) threaded_rod(d=18, l=l, pitch=2, orient=BACK);
            }
            mask = [frame_height + slider_thickness*2, 100, slider_width];
            cube(mask, center=true);
        }
    }
}

module ab_idler_mount_nut(type, reverse)
{

}

module ab_idler_mount_body(type, reverse)
{
    frame_height = motor_frame_height(type);
    corexy_type = corexy_type(type);
    p1_type = coreXYR_return_bottom_idler(corexy_type);
    p1_er = pulley_extent(p1_type);
    p1_pr = pulley_pr(p1_type);
    p1_height = pulley_width(p1_type);
    p1 = idler_offset_bottom_left(type, reverse);

    body();

    module body()
    {
        corner = [p1.x + p1_er + stroke*2, stroke + p1_er*2];
        pulley = [p1.x, p1_er+stroke/2];
        rpulley= p1_er + stroke/2;
        screw1 = [-frame_height/2, (frame_height-chamfer)/2];
        rscrew1= 6;
        screw2 = [p1.x + frame_height/2, -frame_height/2];
        rscrew2= 6;
        screw3 = [p1.x - frame_height/2, -frame_height/2];
        rscrew3= 6;
        //screw4 = [p1.x+p1_er+5, p1_er+stroke/2];
        //rscrew4= 6;
        body = [
            frame_height + thickness*2,
            frame_height + (stroke + slider_thickness)*2,
            frame_height + thickness*2
        ];
        wing = [
            frame_height,
            frame_height + chamfer,
            body.z
        ];
        xframe = [100, frame_height + gap*2, frame_height];
        zframe = [100, 100, 100];
        slider = [slider_width + gap*2, 100, frame_height + slider_thickness*2];
        yrail_type = rail_types(type).y;
        yrail  = [rail_height(yrail_type)+gap*2, 100, rail_width(yrail_type)];
        carriage_type = carriage_types(type).y;
        carriage=[carriage_height(carriage_type) - carriage_clearance(carriage_type) + gap*2, 100, carriage_width(carriage_type) + gap*2];

        difference() {
            // body
            hull() {
                translate([p1.x, -frame_height/2])
                    cuboid(body, chamfer=chamfer);
                translate([-wing.x/2 + gap, wing.y/2 - chamfer])
                    cuboid(wing, chamfer=chamfer);
                translate(pulley) cylinder(r=rpulley, h=body.z, center=true);
                translate(screw1) cylinder(r=rscrew1, h=body.z, center=true);
                translate(screw2) cylinder(r=rscrew2, h=body.z, center=true);
                translate(screw3) cylinder(r=rscrew3, h=body.z, center=true);
            }

            // frame
            translate([0, -xframe.y/2]) cube(xframe, center=true);
            translate([-zframe.x/2, 0, -zframe.z/2+frame_height/2]) cube(zframe, center=true);

            // slider
            translate([p1.x, 0]) cube(slider, center=true);

            // pulley screw
            hull() {
                translate([p1.x, p1_er-1])        cylinder(r=5/2, h=body.z+gap, center=true);
                translate([p1.x, p1_er+stroke+1]) cylinder(r=5/2, h=body.z+gap, center=true);
            }
            hull() {
                height = belt_offsets(type).z + pulley_width(p1_type) + 4;
                translate([p1.x, p1_er-2])        cylinder(r=p1_er+2, h=height, center=true);
                translate([p1.x, p1_er+100])    cylinder(r=p1_er+2, h=height, center=true);
            }

            // yrail
            translate([yrail.x/2, 50+15]) cube(yrail, center=true);
            translate([carriage.x/2 + carriage_clearance(carriage_type) - gap, 50+15, 0])
                cube(carriage, center=true);

            // belt
            translate([50+p1.x, p1.y-p1_pr])
                cuboid([100, 4, belt_offsets(type).z + p1_height + 1], chamfer=1);

            // screws
            for (p=[screw1, screw2, screw3]) {
                d = 4;
                t = 2.5;
                h = thickness - t;
                b = body.z/2 + gap;
                translate(p) {
                    cylinder(r=d/2, h=body.z+gap, center=true);
                    translate([0,0,b]) rotate([0, 180, 0])
                        mid_air_cylinder(r=d, h=h*2, ir=d/2, center=true);
                    translate([0,0,-b])
                        mid_air_cylinder(r=d, h=h*2, ir=d/2, center=true);
                }
            }
        }
    }
}
