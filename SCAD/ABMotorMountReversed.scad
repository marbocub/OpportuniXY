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

upper_thickness = 5;
lower_thickness = 8;

module ABMotorMountReversedLeft(type, reverse)
{
    ab_motor_mount_reversed_body(type);
    motor();

    module motor()
    {
        position = ab_motor_pulley_position(type, reverse, -1);
        zoff = [0, 0, -extrusion_height(motor_extrusion_types(type).x)];
        p2d = position[P2D];

        translate(p2d+zoff) rotate([0,0, 90])
            NEMA(motor_type(type));
    }
}

module ABMotorMountReversedRight(type, reverse)
{
    rotate([0, 180, 0])
        ab_motor_mount_reversed_body(type);
    motor();

    module motor()
    {
        position = ab_motor_pulley_position(type, reverse, 1);
        zoff = [0, 0, -extrusion_height(motor_extrusion_types(type).x)];
        p2d = position[P2D];

        translate(p2d+zoff) rotate([0,0, -90])
            NEMA(motor_type(type));
    }
}

function ab_motor_pulley_position(type, reverse=false, direction = -1) = 
    let(corexy_type = corexy_type(type))
    let(TR = idler_offset_top_right(type, reverse))
    let(p3 = direction>0 ? TR : [-TR.x, TR.y, TR.z])
    let(ioff = plain_idler_offset(corexy_type))
    let(poff = concat(direction>0 ? lower_drive_pulley_offset(corexy_type):upper_drive_pulley_offset(corexy_type), [0]))
    [
        p3 + [0, ioff.y, 0],    // p2b
        p3 + poff,              // p2d
        p3 + [ioff.x, 0, 0],    // p2t
        p3                      // p3
    ];
P2B = 0;
P2D = 1;
P2T = 2;
P3  = 3;

module ab_motor_mount_reversed_body(type)
{

}