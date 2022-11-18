/*
 *  ExtrusionMask.scad
 *  Copyright (C) 2022 @marbocub <marbocub@gmail.com>
 *
 *  This file is part of Opportunity 3D printer.
 *
 *  This work is licensed under the CC-BY-NC-SA 4.0 International License.
 *  (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)
 */
include <BOSL2/attachments.scad>

module extrusion_mask(width, height, length, groove=0, depth=2, edges=[TOP, BOTTOM])
{
    function sumv(v, i=0, s=0) = (i==s ? v[i] : v[i]+sumv(v, i-1, s));
    function mulv(v, s) = [for (i=v) i*s ];
    function absv(v) = [for (i=v) abs(i) ];
    function abssumv(v, i=0, s=0) = (i==s ? absv(v[i]) : absv(v[i])+abssumv(v, i-1, s));

    if (groove > 0) {
        pos = mulv(sumv(edges, len(edges)-1), -depth/2);
        core = [width, length, height] - mulv(abssumv(edges, len(edges)-1), depth);
        translate(pos) cube(core, center=true);

        w=(width-groove)/2;
        h=(height-groove)/2;
        x=(width-w)/2;
        y=(height-h)/2;
        translate([ x, 0,  y])
            cube([w, length, h], center=true);
        translate([-x, 0,  y])
            cube([w, length, h], center=true);
        translate([-x, 0, -y])
            cube([w, length, h], center=true);
        translate([ x, 0, -y])
            cube([w, length, h], center=true);
    } else {
        cube([width, length, height], center=true);
    }
}

