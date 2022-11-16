/*
 *  Assembly.scad
 *  Copyright (C) 2022 @marbocub <marbocub@gmail.com>
 *
 *  This file is part of Opportunity 3D printer.
 *
 *  This work is licensed under the CC-BY-NC-SA 4.0 International License.
 *  (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)
 */

include <Frame.scad>
include <AxisXY.scad>
include <AxisZ.scad>

reverse = true;

module PreviewAssembly(pos=[0, 0, 0])
{
    all=true;

    pos = pos + [0, reverse ? -20 : 0, 0];

    if (all) {
        Frame(X5SA_330);
        translate([0, 0, gantory_level(X5SA_330)])
            AxisXY(
                type=X5SA_330_Rail,
                size=frame_inner(X5SA_330),
                pos=pos,
                reverse=reverse
            );
        translate([0, 0, frame_outer(X5SA_330).z/2])
            AxisZ(
                rail_type=X5SA_330_Rail,
                table_type=X5SA_330_Table,
                size=frame_inner(X5SA_330),
                pos=[0, -30, -30-pos.z]
            );
    } else {
        RenderingAssembly();
    }
}

module RenderingAssembly()
{
    //$fs=0.01;
    //$fn=180;

    pos = [0, 0, 0];

    xy_carriage (
        type=X5SA_330_Rail,
        size=frame_inner(X5SA_330),
        pos=pos
    );
}
