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

include <Config.scad>

reverse = true;

module PreviewAssembly(pos=[0, 0, 0])
{
    all=true;

    pos = pos + [0, reverse ? -20 : 0, 0];

    if (all) {
        Frame(FrameType);
        translate([0, 0, gantory_level(FrameType)])
            AxisXY(
                type=RailType,
                size=frame_inner(FrameType),
                pos=pos,
                reverse=reverse
            );
        translate([0, 0, frame_outer(FrameType).z/2])
            AxisZ(
                rail_type=RailType,
                table_type=TableType,
                size=frame_inner(FrameType),
                pos=[0, -45, -30-pos.z]
            );
    } else {
        RenderingAssembly();
    }
}

module RenderingAssembly()
{
    //$fs=0.01;
    //$fn=180;

    /*
    XYCarriageRender (
        type=RailType,
        size=frame_inner(FrameType)
    );
    */
    ABIdlerMountRender(
        type=RailType,
        reverse=reverse
    );
}
