/*
 *  CoreXYReversedSpecial.scad
 *  Copyright (C) 2022 @marbocub <marbocub@gmail.com>
 *
 *  Based on core_xy.scad of NopSCADlib.
 *  Copyright Chris Palmer 2020 nop.head@gmail.com
 *
 *  This program is free software/hardware: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

include <NopSCADlib/utils/core/core.scad>
include <NopSCADlib/utils/core_xy.scad>

/*
 * [0]: description
 * [1]: belt type
 * [2]: drive plley type
 * [3]: toothed idler type
 * [4]: plain idler type
 * [5]: colour of the upper belt
 * [6]: colour of the upper belt's teeth
 * [7]: colour of the lower belt
 * [8]: colour of the lower belt's teeth
 * [9]: position of motor idlers (optional)
 * [9][0]: plain_idler_offset
 * [9][1]: upper_drive_pulley_offset
 * [9][2]: lower_drive_pulley_offset
 * [10]: detail of mixed idlers (optional)
 * [10][0]: gantory bottom idler type
 * [10][1]: gantory top idler type
 * [10][2]: bottom return idler type
 * [10][3]: top return idler type
 * [10][4]: motor inner idler type
 * [10][5]: motor outer idler type
 */
coreXY_2GT_20_20 = [
    "coreXY_20_20",
    GT2x6,
    GT2x20ob_pulley,
    GT2x20_toothed_idler,
    GT2x20_plain_idler,
    "LightSteelBlue",
    "SteelBlue",
    "DarkSeaGreen",
    "SeaGreen",
    [
        [  0, -(pulley_pr(GT2x20_plain_idler)+pulley_pr(GT2x20ob_pulley))*2],
        [ 42, -(pulley_pr(GT2x20_plain_idler)+pulley_pr(GT2x20ob_pulley))],
        [-42, -(pulley_pr(GT2x20_plain_idler)+pulley_pr(GT2x20ob_pulley))]
    ],
    [
        GT2x20_toothed_idler,
        GT2x20_plain_idler,
        GT2x20_plain_idler,
        GT2x20_plain_idler,
        GT2x20_plain_idler,
        GT2x20_plain_idler
    ]
];

TOOTHED_IDLER   = 3;
PLAIN_IDLER     = 4;
MOTOR_POSITION  = 9;
PLAIN_IDLER_OFFSET        = 0;
UPPER_DRIVE_PULLEY_OFFSET = 1;
LOWER_DRIVE_PULLEY_OFFSET = 2;
MIXED_IDLERS    = 10;
GANTORY_BOTTOM  = 0;
GANTORY_TOP     = 1;
RETURN_BOTTOM   = 2;
RETURN_TOP      = 3;
MOTOR_INNER     = 4;
MOTOR_OUTER     = 5;

function coreXYR_gantory_bottom_idler(type)  = is_undef(type[MIXED_IDLERS]) ? type[TOOTHED_IDLER] : type[MIXED_IDLERS][GANTORY_BOTTOM];
function coreXYR_gantory_top_idler(type)     = is_undef(type[MIXED_IDLERS]) ? type[PLAIN_IDLER]   : type[MIXED_IDLERS][GANTORY_TOP];
function coreXYR_return_bottom_idler(type)   = is_undef(type[MIXED_IDLERS]) ? type[PLAIN_IDLER]   : type[MIXED_IDLERS][RETURN_BOTTOM];
function coreXYR_return_top_idler(type)      = is_undef(type[MIXED_IDLERS]) ? type[PLAIN_IDLER]   : type[MIXED_IDLERS][RETURN_TOP];
function coreXYR_motor_inner_idler(type)     = is_undef(type[MIXED_IDLERS]) ? type[PLAIN_IDLER]   : type[MIXED_IDLERS][MOTOR_INNER];
function coreXYR_motor_outer_idler(type)     = is_undef(type[MIXED_IDLERS]) ? type[PLAIN_IDLER]   : type[MIXED_IDLERS][MOTOR_OUTER];

function plain_idler_offset(type)           = type[MOTOR_POSITION][PLAIN_IDLER_OFFSET];
function upper_drive_pulley_offset(type)    = type[MOTOR_POSITION][UPPER_DRIVE_PULLEY_OFFSET];
function lower_drive_pulley_offset(type)    = type[MOTOR_POSITION][LOWER_DRIVE_PULLEY_OFFSET];

function coreXYR_drive_pulley_alignment2(type1, type2) = pulley_pr(type1) - pulley_pr(type2);

module coreXYR_half(
    type, 
    size, 
    pos, 
    separation_y = 0, 
    x_gap = 0, 
    plain_idler_offset = [0, 0], 
    drive_pulley_offset = [0, 0], 
    show_pulleys = false, 
    lower_belt = false, 
    hflip = false) 
{
    // Start and end points
    start_p = [
        -size.x / 2 + pos.x - x_gap / 2,
        -size.y / 2 + pos.y - separation_y / 2,
        0
    ];
    end_p   = [
        -size.x / 2 + pos.x + x_gap / 2,
        -size.y / 2 + pos.y + separation_y / 2,
        0
    ];

    // bottom return idler pulley
    p1_type = coreXYR_return_bottom_idler(type);
    p1 = [
        -size.x / 2,
        -size.y / 2
    ];

    // top return idler pulley
    p3_type = coreXYR_return_top_idler(type);
    p3 = [
        -p1.x + coreXYR_drive_pulley_alignment2(p1_type, p3_type),
        size.y / 2
    ];

    // y-carriage bottom toothed pulley
    p0_type = coreXYR_gantory_bottom_idler(type);
    p0 = [
        p1.x + pulley_pr(p1_type) + pulley_pr(p0_type),
        start_p.y - pulley_pr(p0_type)
    ];

    // y-carriage top plain pulley
    p4_type = coreXYR_gantory_top_idler(type);
    p4 = [
        p3.x + coreXYR_drive_pulley_alignment2(p3_type, p4_type),
        end_p.y + pulley_pr(p4_type)
    ];

    // idler for offset stepper motor bottom
    p2b_type = coreXYR_motor_inner_idler(type);
    p2b = [ 
        p1.x - coreXYR_drive_pulley_alignment2(p1_type, p2b_type),
        p3.y + coreXYR_drive_pulley_alignment2(p3_type, p2b_type) + plain_idler_offset.y
    ];

    // idler for offset stepper motor top
    p2t_type = coreXYR_motor_outer_idler(type);
    p2t = [ 
        p1.x - coreXYR_drive_pulley_alignment2(p1_type, p2b_type) + plain_idler_offset.x,
        p3.y + coreXYR_drive_pulley_alignment2(p3_type, p2b_type)
    ];

    // stepper motor drive pulley
    p2d_type = coreXY_drive_pulley(type);
    p2d = [
        -p3.x + drive_pulley_offset.x,
         p3.y + drive_pulley_offset.y
    ];

    module show_pulleys(show_pulleys) {// Allows the pulley colour to be set for debugging
        if (is_list(show_pulleys))
            color(show_pulleys)
                children();
        else if (show_pulleys)
            children();
    }

    show_pulleys(show_pulleys) {
        translate(p0)
            pulley_assembly(p0_type); // y-carriage toothed pulley

        translate(p1)
            pulley_assembly(p1_type); // bottom return plain idler pulley

        translate(p2b)
            pulley_assembly(p2b_type); // top stepper motor idler pulley bottom

        translate(p2d)
            hflip(hflip)
                pulley_assembly(p2d_type); // top stepper motor drive pulley

        translate(p2t)
            pulley_assembly(p2t_type); // top stepper motor idler pulley top

        translate(p3)
            pulley_assembly(p3_type); // top return plain idler pulley

        translate(p4)
            pulley_assembly(p4_type); // y-carriage plain pulley
    }

    path0 = [
        concat(p0,  [-pulley_pr(p0_type)]),
        concat(p1,  [ pulley_pr(p1_type)]),
        concat(p2b, [ pulley_pr(p2b_type)]),
        concat(p2d, [-pulley_pr(p2d_type)]),
        concat(p2t, [ pulley_pr(p2t_type)]),
        concat(p3,  [ pulley_pr(p3_type)]),
        concat(p4,  [ pulley_pr(p4_type)])
    ];
    path = concat([start_p], path0, [end_p]);
    belt = coreXY_belt(type);

    belt(type = belt,
        points = path,
        open = true,
        belt_colour  = lower_belt ? coreXY_lower_belt_colour(type)  : coreXY_upper_belt_colour(type),
        tooth_colour = lower_belt ? coreXY_lower_tooth_colour(type) : coreXY_upper_tooth_colour(type));
}

module coreXYR(
    type, 
    size, 
    pos, 
    separation, 
    x_gap = 0, 
    plain_idler_offset = [0, 0], 
    upper_drive_pulley_offset = [0, 0], 
    lower_drive_pulley_offset = [0, 0], 
    show_pulleys = false, 
    left_lower = false) 
{
    translate([size.x / 2 - separation.x / 2, size.y / 2, -separation.z / 2]) {
        // lower belt
        hflip(!left_lower)
            explode(25)
                coreXYR_half(
                    type, 
                    size, 
                    [size.x - pos.x - separation.x/2 - (left_lower ? x_gap : 0), pos.y], 
                    separation.y, 
                    x_gap, 
                    plain_idler_offset, 
                    [-lower_drive_pulley_offset.x, lower_drive_pulley_offset.y], 
                    show_pulleys, 
                    lower_belt = true, 
                    hflip = true
                );

        // upper belt
        translate([separation.x, 0, separation.z])
            hflip(left_lower)
                explode(25)
                    coreXYR_half(
                        type, 
                        size, 
                        [pos.x + separation.x/2 + (left_lower ? x_gap : 0), pos.y], 
                        separation.y, 
                        x_gap, 
                        plain_idler_offset, 
                        upper_drive_pulley_offset, 
                        show_pulleys, 
                        lower_belt = false, 
                        hflip = true
                    );
    }
}

module coreXYR_belts(
    type, 
    carriagePosition, 
    coreXYPosBL, 
    coreXYPosTR, 
    separation, 
    x_gap = 0, 
    plain_idler_offset = [0, 0], 
    upper_drive_pulley_offset = [0, 0], 
    lower_drive_pulley_offset = [0, 0], 
    show_pulleys = false, 
    left_lower = false)
{
    assert(coreXYPosBL.z == coreXYPosTR.z);

    coreXYSize = coreXYPosTR - coreXYPosBL;
    translate(coreXYPosBL)
        coreXYR(
            type, 
            coreXYSize, 
            [carriagePosition.x - coreXYPosBL.x, carriagePosition.y - coreXYPosBL.y], 
            separation, 
            x_gap, 
            plain_idler_offset, 
            upper_drive_pulley_offset, 
            lower_drive_pulley_offset, 
            show_pulleys, 
            left_lower
        );
}
