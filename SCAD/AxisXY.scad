/*
 *  AxisXY.scad
 *  Copyright (C) 2022 @marbocub <marbocub@gmail.com>
 *
 *  This file is part of Opportunity 3D printer.
 *
 *  This work is licensed under the CC-BY-NC-SA 4.0 International License.
 *  (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)
 */

include <BOSL2/std.scad>
include <NopSCADlib/lib.scad>

include <NopSCADlib/utils/core_xy.scad>
include <utils/CoreXYReversedSpecial.scad>

use <XYCarriage.scad>

// custom pulleys
GT2x22_toothed_idler = ["GT2x22_toothed_idler", "GT2",22, 13.50, GT2x6, 6.5, 18.00, 0, 5, 18.00, 1.0, 0, 0, false, 0];
F695_toothed_idler   = ["F695_toothed_idler",   "GT2", 0, 14.50, GT2x6, 6.5, 15.00, 0, 5, 15.00, 1.0, 0, 0, false, 0];
F695_plain_idler     = ["F695_plain_idler",     "GT2", 0, 13.00, GT2x6, 6.5, 15.00, 0, 5, 15.00, 1.0, 0, 0, false, 0];
F684_toothed_idler   = ["F684_toothed_idler",   "GT2", 0, 10.50, GT2x6, 6.5, 10.30, 0, 4, 10.30, 1.0, 0, 0, false, 0];
F684_plain_idler     = ["F684_plain_idler",     "GT2", 0,  9.00, GT2x6, 6.5, 10.30, 0, 4, 10.30, 1.0, 0, 0, false, 0];
X5SA_toothed_idler   = ["X5SA_toothed_idler",   "GT2", 0, 15.65, GT2x6, 6.0, 17.15, 0, 5, 17.15, 2.0, 0, 0, false, 0];
X5SA_plain_idler     = ["X5SA_plain_idler",     "GT2", 0, 14.15, GT2x6, 6.0, 17.15, 0, 5, 17.15, 2.0, 0, 0, false, 0];

/*
 * [0]: rail size [x,y,z]
 * [1]: rail type [x,y,z]
 * [2]: belt path offset both side [x,y,z]
 * [3]: gantory [length, extrusion, [screws]]
 * [4]: corexy type
 */
X5SA_330_Rail = [
    [400, 400, 500], 
    [MGN12H_carriage, MGN12H_carriage, MGN12H_carriage], 
    [4, 10, 9.5],
    [450, E2020, [431.2, 418.4]],
    coreXY_GT2_20_20
];

function rail_length(type) = type[0];
function rail_carriage(type) = type[1];
function rail_type(type) = [
    carriage_rail(rail_carriage(type).x),
    carriage_rail(rail_carriage(type).y),
    carriage_rail(rail_carriage(type).z),
];
function rail_carriage_height(type) = [
    carriage_height(rail_carriage(type).x),
    carriage_height(rail_carriage(type).y),
    carriage_height(rail_carriage(type).z)
];
function belt_offset(type) = type[2];
function gantory(type) = type[3];
function gantory_length(type) = gantory(type)[0];
function gantory_extrusion(type) = gantory(type)[1];
function gantory_height(type) = extrusion_height(gantory_extrusion(type));
function corexy_type(type) = type[4];
function belt_type(type) = coreXY_belt(corexy_type(type));
function belt_back_thickness(type) = belt_thickness(belt_type(type)) - belt_tooth_height(belt_type(type));


module AxisXY(type=X5SA_330_Rail, size=[490,460,530], pos=[0,0,0], reverse=false, plain_idler_offset=[0, 0], upper_drive_pulley_offset=[0, 0], lower_drive_pulley_offset=[0, 0], additional_idler_type=[])
{
    //y_carriage_offset = carriage_pitch_x(rail_carriage(type).x)/2 -2.5;
    y_carriage_offset = 4.5;

    // fixed
    YRails(type, size=size);
    CoreXY(
        type, 
        size=size, 
        pos=pos, 
        reverse=reverse, 
        plain_idler_offset=plain_idler_offset, 
        upper_drive_pulley_offset=upper_drive_pulley_offset, 
        lower_drive_pulley_offset=lower_drive_pulley_offset, 
        additional_idler_type=additional_idler_type
    );

    // moving
    back(pos.y) {
        XGantory(type, size=size, pos=pos, reverse=reverse, y_carriage_offset=y_carriage_offset);
        left(size.x/2 - rail_carriage_height(type).y)
            xy_carriage_left(type, size=size, pos=pos, reverse=reverse, y_carriage_offset=y_carriage_offset, additional_idler_type=additional_idler_type);
        right(size.x/2 - rail_carriage_height(type).y) yrot(180)
            xy_carriage_left(type, size=size, pos=pos, reverse=reverse, y_carriage_offset=y_carriage_offset, additional_idler_type=additional_idler_type);
    }
}

module XGantory(type, size=[490,460,530], pos=[0,0,0], reverse=true, y_carriage_offset=0)
{
    xrot(reverse ? 90 : -90) {
        // x
        down(rail_carriage_height(type).y + belt_back_thickness(type)) {
            down(gantory_height(type) / 2)
                yrot(90)
                    extrusion(gantory_extrusion(type), gantory_length(type));
            rail(rail_type(type).x, rail_length(type).x);
            right(pos.x) carriage(rail_carriage(type).x);
        }
        // y
        down(y_carriage_offset) for(i=[-1, 1]) yrot(90*i) down(size.x/2) {
            carriage(rail_carriage(type).y);
            carriage  = rail_carriage(type).y;
            up(19) for (p=square([carriage_pitch_x(carriage), carriage_pitch_y(carriage)], center=true)) move(p)
                screw(M3_dome_screw, 10);
        }
    }
}

module YRails(type, size=[490,460,530])
{
    for (i=[-1, 1]) left(i*size.x/2) yrot(i*90) zrot(90)
        rail(carriage_rail(rail_carriage(type).y), rail_length(type).y);
}

module CoreXY(type, size=[490,460,530], pos=[0,0,0], reverse=true, plain_idler_offset=[0,0], upper_drive_pulley_offset=[0,0], lower_drive_pulley_offset=[0,0], additional_idler_type=[])
{
    corexy_type = corexy_type(type);
    pos = [-pos.x, pos.y, pos.z];

    belt_path = [
        size.x
            - belt_offset(type).x
            - rail_carriage_height(type).x * 2
            - pulley_pr(reverse ?
                valid(
                    idler_type_y_bottom(additional_idler_type), 
                    coreXY_plain_idler(corexy_type)
                )
                : coreXY_drive_pulley(corexy_type)
            ) * 2,
        size.y
            - belt_offset(type).y
            - pulley_pr(reverse ?
                valid(
                    idler_type_y_top(additional_idler_type), 
                    coreXY_plain_idler(corexy_type)
                )
                : coreXY_plain_idler(corexy_type)
            ) * 2
    ];

    coreXYPosBL = [-belt_path.x/2, -belt_path.y/2, 0];
    coreXYPosTR = [ belt_path.x/2,  belt_path.y/2, 0];

    separation = [0, 0, belt_offset(type).z];
    x_gap = 10;

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
            show_pulleys = true,
            left_lower = true,
            idler_type = additional_idler_type);
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
            show_pulleys = true,
            left_lower = true);
    }
}

