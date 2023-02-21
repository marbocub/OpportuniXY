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
include <vitamins/ExtrusionMask.scad>

version = 1;
gap = 0.1;

/*
 * without tensioner
 */
module ABIdlerMountLeft(type, reverse)
{
    view = 0;

    if (view==1) {
        difference() {
            ab_idler_mount_body(type, reverse, BOTTOM);
            ab_idler_mount_mask(type, reverse, BOTTOM);
        }
    } else if (view==2) {
        intersection() {
            ab_idler_mount_body(type, reverse, BOTTOM);
            ab_idler_mount_mask(type, reverse, BOTTOM);
        }
    } else {
        ab_idler_mount_body(type, reverse, BOTTOM);
    }
}

module ABIdlerMountRight(type, reverse)
{
    mirror([1, 0, 0])
        ab_idler_mount_body(type, reverse, TOP);
}

module ABIdlerMountRender(type, reverse)
{
    thickness = 5.0;
    frame_height = motor_frame_height(type);
    height = frame_height + thickness*2;

    yspace = 50;
    xspace = 95;
    pspace = 30;

    part();
    mirror([1,0,0]) part();
    translate([0, pspace/2, 0]) ab_idler_spacer(type);
    translate([0,-pspace/2, 0]) ab_idler_spacer(type);

    module part() {
        translate([-xspace/2, 0, height/2]) {
            translate([0, -yspace/2]) difference() {
                ab_idler_mount_body(type, reverse, BOTTOM);
                ab_idler_mount_mask(type, reverse, BOTTOM);
            }

            translate([0, yspace/2]) rotate([180, 0, 0]) intersection() {
                ab_idler_mount_body(type, reverse, TOP);
                ab_idler_mount_mask(type, reverse, TOP);
            }
        }
    }
}

module ab_idler_spacer(type)
{
    corexy_type = corexy_type(type);
    p1_type = coreXYR_return_bottom_idler(corexy_type);
    id = pulley_bore(p1_type);
    er = pulley_extent(p1_type);
    h = pulley_height(p1_type);

    difference() {
        union() {
            translate([0, 0, (h+1)/2]) cylinder(r=er+0.75-gap*2, h=h+1, center=true);
            translate([0, 0,  h+1])    cylinder(d1=id+2, d2=id+1, h=1, center=true);
        }
        translate([0, 0, (h+2)/2])     cylinder(d=id, h=h+2, center=true);
        translate([0, 0, 1/2+gap*4])   cylinder(d1=id+2, d2=id, h=2, center=true);
    }
}

module ab_idler_mount_mask(type, reverse, side)
{
    p1 = idler_offset_bottom_left(type, reverse);
    fit1 = [5,  2.5, 0];
    fit2 = [5, 12.5, 0];

    translate([0, 0, 50]) cube([100, 100, 100], center=true);

    for (p=[fit1, fit2]) translate(p)
        cylinder(r=2.5/2, h=5, center=true);
}

module ab_idler_mount_body(type, reverse, side)
{
    thickness = 7.5;
    chamfer = 5.0;
    frame_height = motor_frame_height(type);
    height = frame_height + thickness*2;
    l = 100;

    p1 = idler_offset_bottom_left(type, reverse);
    screw1 = [-frame_height/2, (frame_height-chamfer)/2];
    screw2 = [p1.x + frame_height/2, -frame_height/2];
    screw3 = [p1.x - frame_height/2, -frame_height/2];
    fit1 = [5,  2.5, 0];
    fit2 = [5, 12.5, 0];

    p1_type = coreXYR_return_bottom_idler(corexy_type(type));
    p1_pr = pulley_pr(p1_type);
    p1_er = pulley_extent(p1_type);
    p1_ir = pulley_bore(p1_type) / 2;
    p1_height = pulley_height(p1_type);
    hole_height = belt_offsets(type).z + p1_height + 1;

    difference() {
        body();
        frame();
        yaxis();
        screws();
        pulley();
        fitting();
        idler_text();
        version_text();
    }

    module body()
    {
        hull() {
            body = [
                frame_height + thickness*2,
                frame_height - gap,
                height
            ];
            wing = [
                frame_height,
                frame_height + chamfer,
                height
            ];

            translate([p1.x, -frame_height/2])
                cuboid(body, chamfer=chamfer);
            translate([-wing.x/2 + gap, wing.y/2 - chamfer])
                cuboid(wing, chamfer=chamfer);
            translate(p1)
                cylinder(r=p1_pr+2, h=body.z, center=true);
            for (p=[screw1, screw2, screw3])
                translate(p) cylinder(r=6, h=body.z, center=true);
        }
    }

    module frame()
    {
        half = frame_height/2;
        g = 6;
        d = 2;
        translate([l/2-frame_height, -half, 0])
            rotate([0, 0, 90]) 
                extrusion_mask(frame_height, frame_height, l, groove=g, depth=d, edges=[TOP, BOTTOM]);
        translate([-half, l/2, 0]) 
            extrusion_mask(frame_height, frame_height, l, groove=g, depth=d, edges=[TOP]);
        rotate([-90, 0, 0]) {
            translate([-half, l/2, -half]) 
                extrusion_mask(frame_height, frame_height*1.5, l, groove=g, depth=d, edges=[RIGHT]);
            translate([-half, l/2,  half]) 
                extrusion_mask(frame_height, frame_height*1.5, l, groove=g, depth=d, edges=[RIGHT]);
        }
    }

    module yaxis()
    {
        carriage_type = carriage_types(type).y;
        carriage = [
            carriage_height(carriage_type) - carriage_clearance(carriage_type) + gap*2,
            l,
            carriage_width(carriage_type) + gap*2
        ];

        yrail_type = rail_types(type).y;
        yrail  = [
            rail_height(yrail_type)+gap*2,
            l,
            rail_width(yrail_type)
        ];

        translate([yrail.x/2, l/2+15])
            cube(yrail, center=true);
        translate([carriage.x/2 + carriage_clearance(carriage_type) - gap, l/2+18, 0])
            cube(carriage, center=true);
    }

    module screws()
    {
        t = 2.5;
        h = thickness - t;
        half = height/2 + gap;

        for (p=[screw1, screw2, screw3]) {
            d = 4;

            translate(p) {
                cylinder(d=d, h=height+gap, center=true);
                translate([0, 0, half]) rotate([0, 180, 0])
                    mid_air_cylinder(r=d, h=h*2, ir=d/2, center=true);
                translate([0, 0,-half])
                    mid_air_cylinder(r=d, h=h*2, ir=d/2, center=true);
            }
        }

        translate(p1) {
            cylinder(r=p1_ir*0.84, h=height+gap, center=true);
            translate([0, 0, half/2]) cylinder(r=p1_ir, h=half, center=true);
            translate([0, 0, half]) rotate([0, 180, 0])
                mid_air_cylinder(r=p1_ir*2, h=h*2, ir=p1_ir, center=true);
        }
    }

    module pulley()
    {
        translate(p1) {
            difference() {
                union() {
                    l = p1_er+4;
                    w = 4;
                    cylinder(r=p1_er+0.75, h=hole_height, center=true);
                    hull() {
                        translate([-p1_pr, l/2, 0])
                            cuboid([w, l, hole_height], chamfer=1);
                        translate([l/2, -p1_pr, 0])
                            cuboid([l, w, hole_height], chamfer=1);
                        translate([l/2,  p1_pr, 0])
                            cuboid([l, w, hole_height], chamfer=1);
                        translate([ p1_pr, l/2, 0])
                            cuboid([w, l, hole_height], chamfer=1);
                    }
                }
                translate([0, 0, hole_height/2]) cylinder(r1=p1_ir+1/2, r2=p1_ir+2/2, h=1, center=true);
                translate([0, 0,-hole_height/2]) cylinder(r1=p1_ir+2/2, r2=p1_ir+1/2, h=1, center=true);
            }
        }
    }

    module fitting() {
        for (p=[fit1, fit2]) {
            difference() {
                translate(p+[0,0,-2.5/2  ]) cylinder(r= 2.5/2,               h=2.5, center=true);
                translate(p+[0,0,-1.0/2  ]) cylinder(r =2.5/2-gap,           h=1.0, center=true);
                translate(p+[0,0,-1.0/2-1]) cylinder(r2=2.5/2-gap, r1=1.5/2, h=1.0, center=true);
            }
        }
    }

    module idler_text()
    {
        size=3;
        translate(p1 + [-2, 4, -(hole_height/2+0.5)])
            linear_extrude(1)
                text(str(pulley_od(p1_type)), size=size);
        translate(p1 + [ 2, 4,  (hole_height/2+0.5)]) rotate([0, 180, 0])
            linear_extrude(1)
                text(str(pulley_od(p1_type)), size=size);
    }

    module version_text()
    {
        size=3;
        translate(p1 + [-2, -7, -(hole_height/2+0.5)])
            linear_extrude(1)
                text(str("V", version), size=size);
        translate(p1 + [ 2, -7,  (hole_height/2+0.5)]) rotate([0, 180, 0])
            linear_extrude(1)
                text(str("V", version), size=size);
    }
}

/*
 * with tensioner
 */
module ABIdlerMountWithTensionerLeft(type, reverse)
{
    stroke = 5;
    p1 = idler_offset_bottom_left(type, reverse);

    ab_idler_mount_with_tensioner_body(type, reverse);
    translate([p1.x, -stroke/2]) rotate([0, 90, 0]) ab_idler_mount_slider(type, reverse);
}

module ABIdlerMountWithTensionerRight(type, reverse)
{
    stroke = 5;
    p1 = idler_offset_bottom_left(type, reverse);

    mirror([1, 0, 0])
        ab_idler_mount_with_tensioner_body(type, reverse);
    translate([-p1.x, -stroke/2]) rotate([0, 90, 0]) ab_idler_mount_slider(type, reverse);
}

module ABIdlerMountWithTensionerRender(type, reverse)
{
    space = 30;

    translate([-space/2, 0]) difference() {
        ab_idler_mount_with_tensioner_body(type, reverse);
        ab_idler_mount_with_tensioner_mask();
    }

    translate([space/2, 0]) rotate([0, 180, 0]) intersection() {
        ab_idler_mount_with_tensioner_body(type, reverse);
        ab_idler_mount_with_tensioner_mask();
    }
}

module ab_idler_mount_with_tensioner_mask()
{
    translate([0, 0, 50]) cube([100, 100, 100], center=true);
}

module ab_idler_mount_slider(type, reverse)
{
    chamfer = 5;
    thickness = 7.5;
    slider_thickness = 4.5;
    slider_width = 12;
    stroke = 5;
    frame_height = motor_frame_height(type);
    corexy_type = corexy_type(type);
    p1_type = coreXYR_return_bottom_idler(corexy_type);
    p1_er = pulley_extent(p1_type);
    p1_pr = pulley_pr(p1_type);
    p1_height = pulley_height(p1_type);
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
                translate([0, -l/2+gap]) threaded_rod(d=18, l=l, pitch=2.25, orient=BACK);
            }
            mask = [frame_height + slider_thickness*2, 100, slider_width];
            cube(mask, center=true);
        }
    }
}

module ab_idler_mount_nut(type, reverse)
{

}

module ab_idler_mount_with_tensioner_body(type, reverse)
{
    chamfer = 5;
    thickness = 7.5;
    slider_thickness = 4.5;
    slider_width = 12;
    stroke = 5;

    frame_height = motor_frame_height(type);
    corexy_type = corexy_type(type);
    p1_type = coreXYR_return_bottom_idler(corexy_type);
    p1_er = pulley_extent(p1_type);
    p1_pr = pulley_pr(p1_type);
    p1_height = pulley_height(p1_type);
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
                height = belt_offsets(type).z + pulley_height(p1_type) + 4;
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
