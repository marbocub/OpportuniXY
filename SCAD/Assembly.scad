/*
 *  Assembly.scad
 *  Copyright (C) 2022 @marbocub <marbocub@gmail.com>
 *
 *  This file is part of Opportunity 3D printer.
 *
 *  This work is licensed under the CC-BY-NC-SA 4.0 International License.
 *  (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)
 */

include <BOSL2/std.scad>
include <NopSCADlib/lib.scad>

include <Frame.scad>
include <AxisXY.scad>
include <AxisZ.scad>

reverse = true;
y_carriage_offset = 4.5;
additional_idler_type = [
    GT2x20_plain_idler,     // front return idler pulley
    F695_plain_idler,       // back  return idler pulley
    F695_plain_idler,       // front motor  idler pulley
    F695_plain_idler,       // back  motor  idler pulley
    GT2x20_toothed_idler,   // front y-carriage toothed pulley
    F684_plain_idler        // back  y-carriage plain pulley
];

// path type-1
plain_idler_offset        = reverse ? [ 25.4,   0] : [0, 0];
upper_drive_pulley_offset = reverse ? [ 12.7, -20] : [0, 0];
lower_drive_pulley_offset = reverse ? [-12.7, -20] : [0, 0];
// path type-2
//plain_idler_offset        = reverse ? [ 13.75*1.5, -(13.75/2+12.73)] : [0, 0];
//upper_drive_pulley_offset = reverse ? [ 12.73*3,   -(12.73/2+13.75/2)] : [0, 0];
//lower_drive_pulley_offset = reverse ? [-12.73*3,   -(12.73/2+13.75/2)] : [0, 0];
// path type-3
//plain_idler_offset        = reverse ? [ 13.75*2.5, -(0)] : [0, 0];
//upper_drive_pulley_offset = reverse ? [ 12.73*4,   -(12.73/2+13.75/2)] : [0, 0];
//lower_drive_pulley_offset = reverse ? [-12.73*4,   -(12.73/2+13.75/2)] : [0, 0];

module PreviewAssembly(pos=[0, 0, 0])
{
    all=true;

    pos = pos + [0, reverse ? -15 : -10, 0];

    if (all) {
        Frame(X5SA_330);
        up(gantory_level(X5SA_330))
            AxisXY(
                X5SA_330_Rail,
                size=frame_inner(X5SA_330),
                pos=pos,
                reverse=reverse,
                plain_idler_offset=plain_idler_offset,
                upper_drive_pulley_offset=upper_drive_pulley_offset,
                lower_drive_pulley_offset=lower_drive_pulley_offset,
                additional_idler_type=additional_idler_type
            );
        up(frame_outer(X5SA_330).z/2)
            AxisZ(
                X5SA_330_Rail,
                X5SA_330_Table,
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
        X5SA_330_Rail,
        size=frame_inner(X5SA_330),
        pos=pos,
        reverse=reverse,
        additional_idler_type=additional_idler_type,
        y_carriage_offset=y_carriage_offset
    );
}
