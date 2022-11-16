/*
 *  Main.scad
 *  Copyright (C) 2022 @marbocub <marbocub@gmail.com>
 *
 *  This file is part of Opportunity 3D printer.
 *
 *  This work is licensed under the CC-BY-NC-SA 4.0 International License.
 *  (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)
 */

use <Assembly.scad>

if ($preview) {
    PreviewAssembly(pos=[ 0,  0, 200]);
} else {
    RenderingAssembly();
}
