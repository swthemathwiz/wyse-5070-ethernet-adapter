//
// Copyright (c) Stewart H. Whitman, 2020-2021.
//
// File:    smidge.scad
// Project: General
// License: CC BY-NC-SA 4.0 (Attribution-NonCommercial-ShareAlike)
// Desc:    SMIDGE constant used in preview mode.
//

// Smidge constant for rendering only (to avoid Z-axis fighting, etc.)
SMIDGE = $preview ? 0.01 : 0;
