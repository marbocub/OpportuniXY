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

function idler_type_y_bottom(type)      = type[0];  // p1
function idler_type_y_top(type)         = type[1];  // p3
function idler_type_motor_bottom(type)  = type[2];  // p2
function idler_type_motor_top(type)     = type[3];  // p2
function idler_type_xy_toothed(type)    = type[4];  // p0
function idler_type_xy_plain(type)      = type[5];  // p4

function valid(value1, value2) = is_undef(value1) ? value2 : value1;

function coreXYR_drive_pulley_alignment2(type1, type2) = pulley_pr(type1) - pulley_pr(type2);

module coreXYR_half(type, size, pos, separation_y = 0, x_gap = 0, plain_idler_offset = [0, 0], drive_pulley_offset = [0, 0], show_pulleys = false, lower_belt = false, hflip = false, idler_type = []) { //! Draw one belt of a coreXY setup
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
    p1_type = valid(idler_type_y_bottom(idler_type), coreXY_plain_idler(type));
    p1 = [
        -size.x / 2,
        -size.y / 2
    ];

    // top return idler pulley
    p3_type = valid(idler_type_y_top(idler_type), coreXY_plain_idler(type));
    p3 = [
        -p1.x + coreXYR_drive_pulley_alignment2(p1_type, p3_type),
        size.y / 2
    ];

    // y-carriage front toothed pulley
    p0_type = valid(idler_type_xy_toothed(idler_type), coreXY_toothed_idler(type));
    p0 = [
        p1.x + pulley_pr(p1_type) + pulley_pr(p0_type),
        start_p.y - pulley_pr(p0_type)
    ];

    // y-carriage back plain pulley
    p4_type = valid(idler_type_xy_plain(idler_type), coreXY_plain_idler(type));
    p4 = [
        p3.x + coreXYR_drive_pulley_alignment2(p3_type, p4_type),
        end_p.y + pulley_pr(p4_type)
    ];

    // stepper motor drive pulley
    p2d_type = coreXY_drive_pulley(type);
    p2d = [
        p1.x - coreXYR_drive_pulley_alignment2(p1_type, p2d_type) + drive_pulley_offset.x,
        p3.y + coreXYR_drive_pulley_alignment2(p3_type, p2d_type) + drive_pulley_offset.y
    ];

    // idler for offset stepper motor bottom
    p2b_type = valid(idler_type_motor_bottom(idler_type), coreXY_plain_idler(type));
    p2b = [ 
        p1.x - coreXYR_drive_pulley_alignment2(p1_type, p2b_type),
        p3.y + coreXYR_drive_pulley_alignment2(p3_type, p2b_type) + plain_idler_offset.y
    ];

    // idler for offset stepper motor top
    p2t_type = valid(idler_type_motor_top(idler_type), coreXY_plain_idler(type));
    p2t = [ 
        p1.x - coreXYR_drive_pulley_alignment2(p1_type, p2b_type) + plain_idler_offset.x,
        p3.y + coreXYR_drive_pulley_alignment2(p3_type, p2b_type)
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
        [ p0.x, p0.y, -pulley_od(p0_type) / 2 ],
        [ p1.x, p1.y, pulley_od(p1_type) / 2 ],
        [ p2b.x, p2b.y, pulley_od(p2b_type) / 2 ],
        [ p2d.x, p2d.y, -pulley_od(p2d_type) / 2 ],
        [ p2t.x, p2t.y, pulley_od(p2t_type) / 2 ],
        [ p3.x, p3.y, pulley_od(p3_type) / 2 ],
        [ p4.x, p4.y, pulley_od(p4_type) / 2 ]
    ];
    path = concat([start_p], path0, [end_p]);
    belt = coreXY_belt(type);

    belt(type = belt,
        points = path,
        open = true,
        belt_colour  = lower_belt ? coreXY_lower_belt_colour(type) : coreXY_upper_belt_colour(type),
        tooth_colour = lower_belt ? coreXY_lower_tooth_colour(type) : coreXY_upper_tooth_colour(type));
}

module coreXYR(type, size, pos, separation, x_gap = 0, plain_idler_offset = [0, 0], upper_drive_pulley_offset = [0, 0], lower_drive_pulley_offset = [0, 0], show_pulleys = false, left_lower = false, idler_type = []) { //! Wrapper module to draw both belts of a coreXY setup
    translate([size.x / 2 - separation.x / 2, size.y / 2, -separation.z / 2]) {
        // lower belt
        hflip(!left_lower)
            explode(25)
                coreXYR_half(type, size, [size.x - pos.x - separation.x/2 - (left_lower ? x_gap : 0), pos.y], separation.y, x_gap, plain_idler_offset, [-lower_drive_pulley_offset.x, lower_drive_pulley_offset.y], show_pulleys, lower_belt = true, hflip = true, idler_type = idler_type);

        // upper belt
        translate([separation.x, 0, separation.z])
            hflip(left_lower)
                explode(25)
                    coreXYR_half(type, size, [pos.x + separation.x/2 + (left_lower ? x_gap : 0), pos.y], separation.y, x_gap, plain_idler_offset, upper_drive_pulley_offset, show_pulleys, lower_belt = false, hflip = true, idler_type = idler_type);
    }
}

module coreXYR_belts(type, carriagePosition, coreXYPosBL, coreXYPosTR, separation, x_gap = 0, plain_idler_offset = [0, 0], upper_drive_pulley_offset = [0, 0], lower_drive_pulley_offset = [0, 0], show_pulleys = false, left_lower = false, idler_type = []) { //! Draw the coreXY belts
    assert(coreXYPosBL.z == coreXYPosTR.z);

    coreXYSize = coreXYPosTR - coreXYPosBL;
    translate(coreXYPosBL)
        coreXYR(type, coreXYSize, [carriagePosition.x - coreXYPosBL.x, carriagePosition.y - coreXYPosBL.y], separation, x_gap, plain_idler_offset, upper_drive_pulley_offset, lower_drive_pulley_offset, show_pulleys, left_lower, idler_type);
}
