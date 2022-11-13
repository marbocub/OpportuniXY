/*
 *  Frame.scad
 *  Copyright (C) 2022 @marbocub <marbocub@gmail.com>
 *
 *  This file is part of Opportunity 3D printer.
 *
 *  This work is licensed under the CC-BY-NC-SA 4.0 International License.
 *  (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)
 */

include <BOSL2/std.scad>
include <NopSCADlib/lib.scad>

/*
 * [0]: extrusion length [x,y,z,z2]
 * [1]: extrusion type   [x,y,z,z2]
 */
X5SA_330 = [
    [530, 460, 530, 530],
    [E2020, E2020, E2040, E2020]
];

function frame_dimension(type) = type[0];
function frame_extrusion(type) = type[1];
function gantory_level(type) = frame_dimension(type).z + extrusion_height(frame_extrusion(type).x)*1.5;
function frame_outer(type) = [
    frame_dimension(type).x, 
    frame_dimension(type).y+extrusion_height(frame_extrusion(type).x)*2, 
    frame_dimension(type).z+extrusion_height(frame_extrusion(type).x)*2
];
function frame_inner(type) = [
    frame_dimension(type).x-extrusion_height(frame_extrusion(type).x)*2, 
    frame_dimension(type).y, 
    frame_dimension(type).z
];

module Frame(frame_type = X5SA_330)
{
    dimension = frame_dimension(frame_type);
    x = dimension.x;
    y = dimension.y;
    z = dimension.z;
    extrusion = frame_extrusion(frame_type);
    h = extrusion_width(extrusion.x);

    color("dimgrey") {
        up(z/2+h) {
            // X beam
            yrot(90) for (p=square([z+h, y+h], center=true)) move(p)
                extrusion(extrusion.x, x);
            // Y beam
            xrot(90) for (p=square([x-h, z+h], center=true)) move(p)
                extrusion(extrusion.y, y);

            // Z column
            for (p=square([x-h, y], center=true)) move(p)
                extrusion(extrusion.z, z);

            // Z2 column
            if (! is_undef(dimension[3])) {
                back((y+h)/2) extrusion(extrusion[3], z);
            }
        }
    }
}
