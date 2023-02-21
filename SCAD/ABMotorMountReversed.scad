/*
 *  ABMotorMount.scad
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

thickness = 7.5;
motor_mount_thickness = 5;

gap = 0.1;

P2B = 0;
P2D = 1;
P2T = 2;
P3  = 3;

module ABMotorMountReversedLeft(type, reverse)
{
    ab_motor_mount_reversed_body(type);
    ab_motor_mount_tensioner(type);
    ab_motor_mount_nut(type);

    //ab_motor_mount_compact_tensioner(type);

    motor();

    module motor()
    {
        position = ab_motor_pulley_position(type, reverse, LEFT);
        zoff = [0, 0, -motor_frame_height(type)/2 - motor_mount_thickness];

        translate(position[P2D] + zoff) rotate([0,0, 90]) NEMA(motor_type(type));
    }
}

module ABMotorMountReversedRight(type, reverse)
{
    mirror([1, 0, 0]) {
        ab_motor_mount_reversed_body(type);
        ab_motor_mount_tensioner(type);
        ab_motor_mount_nut(type);
    }

    motor();

    module motor()
    {
        position = ab_motor_pulley_position(type, reverse, RIGHT);
        zoff = [0, 0, -motor_frame_height(type)/2 - motor_mount_thickness];

        translate(position[P2D] + zoff) rotate([0,0, -90])
            NEMA(motor_type(type));
    }
}

function ab_motor_pulley_position(type, reverse=false, direction = LEFT) = 
    let(corexy_type = corexy_type(type))
    let(TR = idler_offset_top_right(type, reverse))
    let(p3 = direction.x>0 ? TR : [-TR.x, TR.y, TR.z])
    let(ioff = plain_idler_offset(corexy_type))
    let(poff = concat(direction.x>0 ? lower_drive_pulley_offset(corexy_type):upper_drive_pulley_offset(corexy_type), [0]))
    [
        p3 + [0, ioff.y, 0],    // p2b
        p3 + poff,              // p2d
        p3 + [ioff.x, 0, 0],    // p2t
        p3                      // p3
    ];

module ab_motor_mount_compact(type)
{

}

module ab_motor_mount_compact_tensioner(type)
{
    frame_height = motor_frame_height(type);
    full_height = frame_height + thickness*2;
    pulleys = ab_motor_pulley_position(type, reverse=true);
    hole_pitch = NEMA_hole_pitch(motor_type(type));

    difference() {
        body();
        idler();
        hole();
    }

    module body() {
        hull() {
            translate(pulleys[P2D] + [-hole_pitch/2, -hole_pitch/2, -pulleys[P2D].z])
                cylinder(r=6, h=25, center=true);
            translate(pulleys[P2T])
                cylinder(r=6, h=25, center=true);
        }
    }

    module idler() {
        translate(pulleys[P2D] + [0, 0, -5])
            cube([100, 20, 10], center=true);
        translate(pulleys[P2T] + [0, 0, -5])
            cube([100, 20, 10], center=true);
    }

    module hole() {
        translate(pulleys[P2T] + [0,0,-pulleys[P2T].z])
            cylinder(r=2.5, h=full_height, center=true);
        translate(pulleys[P2D] + [-hole_pitch/2, -hole_pitch/2, -pulleys[P2D].z])
            cylinder(r=1.5, h=full_height, center=true);
    }
}

module ab_motor_mount_reversed_body(type)
{
    frame_height = motor_frame_height(type);
    full_height = frame_height + thickness*2;
    full_offset = 0;
    width = NEMA_width(motor_type(type));
    hole_pitch = NEMA_hole_pitch(motor_type(type));

    pulleys = ab_motor_pulley_position(type, reverse=true);

    screws = [
        [-frame_height/2, pulleys[P2B].y, 0],
        [-frame_height/2, pulleys[P2T].y, 0],
        [pulleys[P2B].x, frame_height/2, 0],
        [pulleys[P2D].x + NEMA_width(motor_type(type))/2, frame_height/2, 0]
    ];

    p2b_type = coreXYR_motor_inner_idler(corexy_type(type));
    p2t_type = coreXYR_motor_outer_idler(corexy_type(type));
    p3_type  = coreXYR_return_top_idler(corexy_type(type));

    difference() {
        body();
        frame();
        rail();
        belt();
        idler();
        motor();
        void();
        debug();
    }

    module body() {
        chamfer = 5.0;
        side_wing = [
            frame_height - gap,
            -pulleys[P2B].y + chamfer,
            full_height
        ];
        rear_wing = [
            pulleys[P2D].x + NEMA_width(motor_type(type))/2,
            frame_height - gap,
            full_height
        ];
        hull() {
            for (p = pulleys)
                translate([p.x, p.y, full_offset]) cylinder(r=pulley_pr(p2t_type)+2, h=full_height, center=true);
            for (p = screws)
                translate([p.x, p.y, full_offset]) cylinder(r=6, h=full_height, center=true);
            translate([-side_wing.x/2, -side_wing.y/2, 0])
                cuboid(side_wing, chamfer=chamfer);
            translate([rear_wing.x/2, rear_wing.y/2, 0])
                cuboid(rear_wing, chamfer=chamfer);
            w = 10;
            translate([pulleys[P2D].x, pulleys[P2D].y, full_offset])
                cuboid([NEMA_width(motor_type(type))+w*2, NEMA_width(motor_type(type)), full_height], chamfer=chamfer, edges=[TOP, BACK, LEFT, RIGHT]);
        }
    }

    module frame() {
        half = frame_height/2;
        g = 6;
        d = 2;
        l = 150;
        translate([l/2-frame_height, half, 0])
            rotate([0, 0, 90]) 
                extrusion_mask(frame_height, frame_height, l, groove=g, depth=d, edges=[TOP, BOTTOM]);
        translate([-half, -l/2, 0]) 
            extrusion_mask(frame_height, frame_height, l, groove=g, depth=d, edges=[TOP, BOTTOM]);
        rotate([-90, 0, 0]) {
            translate([-half, l/2, -half]) 
                extrusion_mask(frame_height, frame_height, l, groove=g, depth=d, edges=[RIGHT]);
            translate([-half, l/2,  half]) 
                extrusion_mask(frame_height, frame_height, l, groove=g, depth=d, edges=[RIGHT, FRONT]);
        }
    }

    module rail() {
        yrail_type = rail_types(type).y;
        yrail  = [rail_height(yrail_type)+gap*2, 100, rail_width(yrail_type)];
        translate([yrail.x/2, -(yrail.y/2+15)]) cube(yrail, center=true);

    }

    module belt() {
        l = 100;
        w = 5;
        // rear
        translate([l/2 + pulleys[P3].x, -belt_offsets(type).y/2, 0])
            cube([l, w, frame_height], center=true);
        // side
        translate([carriage_total_heights(type).y + belt_offsets(type).x/2, -l/2 + pulleys[P3].y, 0])
            cube([w, l, frame_height], center=true);
    }

    module idler() {
        idlers = [p2b_type, p2t_type, p3_type];
        idler_pos = [ pulleys[P2B], pulleys[P2T], pulleys[P3]];
        for (i=[0,1,2]) translate(idler_pos[i])
            cylinder(r=pulley_extent(idlers[i])+2, h=frame_height, center=true);
    }

    module motor() {
        translate(pulleys[P2D] + [-5, 0, -pulleys[P2D].z - frame_height])
            cuboid([width + 10, width + 2, motor_mount_thickness*2], chamfer=-motor_mount_thickness*2, edges=[BOTTOM]);
    }

    module void() {
        left = carriage_total_heights(type).y + belt_offsets(type).x/2;
        right = pulleys[P2D].x + width/2;
        w = right - left;
        d = hole_pitch + 6 + gap;
        translate([left + w/2, pulleys[P2D].y, 0])
            cube([w, d, frame_height + gap*2], center=true);
    }

    module debug() {
        translate([0,0,15]) cube([200,100,20+gap], center=true);
    }
}

module ab_motor_mount_tensioner(type)
{
    frame_height = motor_frame_height(type);
    pulleys = ab_motor_pulley_position(type, reverse=true);
    body = [
        NEMA_width(motor_type(type)),
        NEMA_hole_pitch(motor_type(type)) + NEMA_thread_d(motor_type(type)) + 3,
        frame_height
    ];
    slit = [
        frame_height + gap,
        pulley_pr(GT2x20ob_pulley) * 2 + 6,
        NEMA_width(motor_type(type))/2 + gap
    ];
    translate(pulleys[P2D]) {
        difference() {
            cuboid(body, rounding=3, edges=[LEFT+FRONT, LEFT+BACK, RIGHT+FRONT, RIGHT+BACK]);
            cylinder(r=NEMA_boss_radius(motor_type(type))+2, h=frame_height+gap, center=true);
            translate([-slit.z/2, 0, 0]) rotate([0, 90, 0]) cuboid(slit, rounding=-3, $fn=24);
            for (p=rect(NEMA_hole_pitch(motor_type(type)))) translate(p)
                cylinder(d=NEMA_thread_d(motor_type(type))+gap*2, h=frame_height+gap, center=true);
        }
        l=24;
        d=18;
        h=12;
        pitch=2.25;
        translate([(body.x+l)/2-gap, 0, -(frame_height-h)/2]) intersection() {
            threaded_rod(d=d, l=l, pitch=pitch, orient=LEFT);
            cube([l+gap, d+gap, h], center=true);
        }
    }
}

module ab_motor_mount_nut(type)
{

}