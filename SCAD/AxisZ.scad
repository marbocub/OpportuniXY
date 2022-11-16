/*
 *  AxisZ.scad
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

/*
 * [0]: table size
 */
X5SA_330_Table = [
    [330, 330, 6]
];

function table_size(type) = type[0];

module AxisZ(rail_type=X5SA_330_Rail, table_type=X5SA_330_Table, size=[490,460,530], pos=[0,0,0])
{
    ZRails(rail_type, size=size);
    Bed(rail_type, table_type, size=size, pos=pos);
}

module ZRails(rail_type, size=[490,460,530])
{
    for (i=[-1, 1]) fwd(size.y/2-10) left(i*size.x/2) yrot(i*90)
        rail(carriage_rail(carriage_types(rail_type).z), rail_lengths(rail_type).z);

    back(size.y/2) xrot(90) zrot(90)
        rail(carriage_rail(carriage_types(rail_type).z), rail_lengths(rail_type).z);
}

module Bed(rail_type, table_type, size=[490,460,530], pos=[0,0,0])
{
    table = table_size(table_type);
    z = pos.z+size.z/2-table.z/2;

    move(pos + [0, 0, size.z/2-table.z/2]) {
        color("silver") down(0.5) cube(table+[0,0,-1], center=true);
        color("DarkKhaki") up(table.z/2-0.5) cube([table.x, table.y, 1], center=true);
    }

    move([0, -size.y/2+10, z])
        for (i=[-1, 1]) yrot(90*i) down(size.x/2)
            carriage(carriage_types(rail_type).z);

    move([0, size.y/2, z]) xrot(90) zrot(90)
            carriage(carriage_types(rail_type).z);
}
