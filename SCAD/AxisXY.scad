/*
 *  AxisXY.scad
 *  Copyright (C) 2022 @marbocub <marbocub@gmail.com>
 *
 *  This file is part of Opportunity 3D printer.
 *
 *  This work is licensed under the CC-BY-NC-SA 4.0 International License.
 *  (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)
 */

include <NopSCADlib/lib.scad>

include <NopSCADlib/utils/core_xy.scad>
include <utils/CoreXYReversedSpecial.scad>

use <XYCarriage.scad>
use <ABMotorMountReversed.scad>
use <ABIdlerMount.scad>

// custom pulleys
GT2x22_toothed_idler = ["GT2x22_toothed_idler", "GT2",22, 13.50, GT2x6, 6.5, 18.00, 0, 5, 18.00, 1.0, 0, 0, false, 0];
F695_toothed_idler   = ["F695_toothed_idler",   "GT2", 0, 14.50, GT2x6, 6.5, 15.00, 0, 5, 15.00, 1.0, 0, 0, false, 0];
F695_plain_idler     = ["F695_plain_idler",     "GT2", 0, 13.00, GT2x6, 6.5, 15.00, 0, 5, 15.00, 1.0, 0, 0, false, 0];
F684_toothed_idler   = ["F684_toothed_idler",   "GT2", 0, 10.50, GT2x6, 6.5, 10.30, 0, 4, 10.30, 1.0, 0, 0, false, 0];
F684_plain_idler     = ["F684_plain_idler",     "GT2", 0,  9.00, GT2x6, 6.5, 10.30, 0, 4, 10.30, 1.0, 0, 0, false, 0];
X5SA_toothed_idler   = ["X5SA_toothed_idler",   "GT2", 0, 15.65, GT2x6, 6.0, 17.15, 0, 5, 17.15, 2.0, 0, 0, false, 0];
X5SA_plain_idler     = ["X5SA_plain_idler",     "GT2", 0, 14.15, GT2x6, 6.0, 17.15, 0, 5, 17.15, 2.0, 0, 0, false, 0];

// custom coreXY
coreXY_2GT_mixed_idler = list_set(list_set(
    coreXY_2GT_20_20,
    MIXED_IDLERS,
    [
        GT2x20x5_toothed_idler, // gantory bottom
        F684_plain_idler,       // gantory top
        GT2x20x5_plain_idler,   // return bottom
        GT2x20x5_plain_idler,   // return top
        GT2x20x5_plain_idler,   // motor bottom
        GT2x20x5_plain_idler    // motor top
    ]),
    MOTOR_POSITION,
    [
        [  0, -(pulley_pr(GT2x20_plain_idler)+pulley_pr(GT2x20ob_pulley)*2+pulley_pr(GT2x20_plain_idler))],
        [ 36, -(pulley_pr(GT2x20_plain_idler)+pulley_pr(GT2x20ob_pulley)+6)],
        [-36, -(pulley_pr(GT2x20_plain_idler)+pulley_pr(GT2x20ob_pulley)+6)]
    ]
);

/*
 * [0]: rail length [x,y,z]
 * [1]: carriage type [x,y,z]
 * [2]: belt path offset both side [x,y,z]
 * [3]: gantory [length, extrusion, [screws]]
 * [4]: corexy type
 * [5]: AB motor [motortype, frametype]
 */
X5SA_330_Rail = [
    [400, 400, 500], 
    [MGN12H_carriage, MGN12H_carriage, MGN12H_carriage], 
    [4, 10, 9.5],
    [450, E2020, [431.2, 418.4]],
    coreXY_2GT_mixed_idler,
    [NEMA17_34, E2020]
];

function rail_lengths(type) = type[0];
function carriage_types(type) = type[1];
function rail_types(type) = 
    let(carriage_types = carriage_types(type))
    [
        carriage_rail(carriage_types.x),
        carriage_rail(carriage_types.y),
        carriage_rail(carriage_types.z),
    ];
function carriage_total_heights(type) = 
    let(carriage_types = carriage_types(type))
    [
        carriage_height(carriage_types.x),
        carriage_height(carriage_types.y),
        carriage_height(carriage_types.z)
    ];
function belt_offsets(type) = type[2];
function gantory(type) = type[3];
function gantory_length(type) = gantory(type)[0];
function gantory_extrusion(type) = gantory(type)[1];
function gantory_height(type) = extrusion_height(gantory_extrusion(type));
function gantory_width(type) = extrusion_width(gantory_extrusion(type));
function corexy_type(type) = type[4];
function idler_offset_bottom_left(type, reverse=false) = 
    let(corexy_type = corexy_type(type))
    let(pulley_pr = pulley_pr(reverse 
        ? coreXYR_return_bottom_idler(corexy_type) 
        : coreXY_toothed_idler(corexy_type)))
    [
        belt_offsets(type).x/2 + pulley_pr + carriage_total_heights(type).y,
        belt_offsets(type).y/2 + pulley_pr,
        0
    ];
function idler_offset_top_right(type, reverse=false) = 
    let(corexy_type = corexy_type(type))
    let(pulley_pr = pulley_pr(reverse 
        ? coreXYR_return_top_idler(corexy_type) 
        : coreXY_drive_pulley(corexy_type)))
    [
        -(belt_offsets(type).x/2 + pulley_pr + carriage_total_heights(type).y),
        -(belt_offsets(type).y/2 + pulley_pr),
        0
    ];
function belt_type(type) = coreXY_belt(corexy_type(type));
function belt_back_thickness(type) = belt_thickness(belt_type(type)) - belt_tooth_height(belt_type(type));
function motor_type(type) = type[5][0];
function motor_frame_height(type) = extrusion_height(type[5][1]);


module AxisXY(type=X5SA_330_Rail, size=[490,460,530], pos=[0,0,0], reverse=false)
{
    // fixed
    YRails(type, size=size);
    CoreXY(type, size=size, pos=pos, reverse=reverse);
    if (reverse) {
        color("DarkKhaki") {
            translate([-size.x/2, -size.y/2]) ABIdlerMountLeft(type, reverse=reverse);
            translate([ size.x/2, -size.y/2]) ABIdlerMountRight(type, reverse=reverse);
        }
        translate([-size.x/2,  size.y/2]) ABMotorMountReversedLeft(type, reverse=reverse);
        translate([ size.x/2,  size.y/2]) ABMotorMountReversedRight(type, reverse=reverse);
    } else {
        // wip
    }

    // moving
    translate([0, pos.y, 0]) {
        rotate([reverse ? 90 : -90, 0, 0]) XGantory(type, size=size, pos=pos);
        color("DarkKhaki") {
            translate([-(size.x/2 - carriage_total_heights(type).y), 0, 0]) rotate([reverse?0:180, 0, 0]) {
                XYCarriage(type, size=size);
            }
            translate([ (size.x/2 - carriage_total_heights(type).y), 0, 0]) rotate([reverse?0:180, 180, 0])
                XYCarriage(type, size=size);
        }
    }
}

module XGantory(type, size=[490,460,530], pos=[0,0,0])
{
    // x
    translate([0, 0, -(carriage_total_heights(type).y + belt_back_thickness(type))]) {
        translate([0, 0, -(gantory_height(type) / 2)])
            rotate([0, 90, 0])
                extrusion(gantory_extrusion(type), gantory_length(type));
        rail(rail_types(type).x, rail_lengths(type).x);
        translate([pos.x, 0, 0]) carriage(carriage_types(type).x);
    }
    // y
    translate([0, 0, -y_carriage_offset(type)]) for(i=[-1, 1]) rotate([0, 90*i, 0]) translate([0, 0, -(size.x/2)]) {
        carriage(carriage_types(type).y);
        carriage  = carriage_types(type).y;
        translate([0, 0, 19]) for (p=square([carriage_pitch_x(carriage), carriage_pitch_y(carriage)], center=true)) translate(p)
            screw(M3_dome_screw, 10);
    }
}

module YRails(type, size=[490,460,530])
{
    for (i=[-1, 1]) translate([-(i*size.x/2), 0, 0]) rotate([0, i*90, 0]) rotate([0, 0, 90])
        rail(carriage_rail(carriage_types(type).y), rail_lengths(type).y);
}

module CoreXY(type, size=[490,460,530], pos=[0,0,0], reverse=true)
{
    corexy_type = corexy_type(type);
    pos = [-pos.x, pos.y, pos.z];
    coreXYPosBL = [-size.x/2, -size.y/2] + idler_offset_bottom_left(type, reverse);
    coreXYPosTR = [ size.x/2,  size.y/2] + idler_offset_top_right(type, reverse);
    separation = [0, 0, belt_offsets(type).z];
    x_gap = 10;
    plain_idler_offset = plain_idler_offset(corexy_type);
    upper_drive_pulley_offset = upper_drive_pulley_offset(corexy_type);
    lower_drive_pulley_offset = lower_drive_pulley_offset(corexy_type);
    show_pulleys = true;
    left_lower = true;

    if (reverse) {
        coreXYR_belts(
            type = corexy_type,
            carriagePosition = pos,
            coreXYPosBL = coreXYPosBL,
            coreXYPosTR = coreXYPosTR,
            separation = separation,
            x_gap = x_gap,
            plain_idler_offset = plain_idler_offset,
            upper_drive_pulley_offset = upper_drive_pulley_offset,
            lower_drive_pulley_offset = lower_drive_pulley_offset,
            show_pulleys = show_pulleys,
            left_lower = left_lower
        );

    } else {
        coreXY_belts(
            type = corexy_type,
            carriagePosition = pos,
            coreXYPosBL = coreXYPosBL,
            coreXYPosTR = coreXYPosTR,
            separation = separation,
            x_gap = x_gap,
            plain_idler_offset = plain_idler_offset,
            upper_drive_pulley_offset = upper_drive_pulley_offset,
            lower_drive_pulley_offset = lower_drive_pulley_offset,
            show_pulleys = show_pulleys,
            left_lower = left_lower
        );
    }
}
