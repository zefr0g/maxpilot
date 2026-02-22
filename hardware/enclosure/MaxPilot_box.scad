/* ================================================================
   MaxPilot PCB Enclosure — v2.4
   PCB: 99.06 × 38.1 mm, 4× M2 mounting holes
   Mains wire entry: left wall (J1 terminal block)

   Assembly:
     1. Print base (open face up, no supports needed)
     2. Print lid (inner face on build plate, no supports needed)
     3. Drop PCB straight into box — no tilt needed
     4. Secure PCB with 4× M2×6 pan-head screws (self-tapping in PLA)
     5. Place lid (lip locates it), screw down with 4× M3×13 pan-head screws

   Hardware:
     4× M2×6  pan-head screws  (PCB  → M2 bosses at floor)
     4× M3×13 pan-head screws  (lid  → M3 pilots at corner pillars)
   ================================================================ */

$fn = 64;

// ── PCB ──────────────────────────────────────────────────────
pcb_l = 99.06;   // length
pcb_w = 38.1;    // width
pcb_t = 1.6;     // PCB thickness

// Mounting holes relative to PCB corner
mh = [[2.54, 2.54], [96.52, 2.54], [2.54, 35.56], [96.52, 35.56]];

// ── Box ───────────────────────────────────────────────────────
wall     = 2.0;  // wall thickness
floor_t  = 3.0;  // base floor thickness
gap      = 2.5;  // clearance around PCB (was 6.0 — reduced for tighter footprint)
standoff = 5.0;  // boss height = PCB bottom clearance above floor
comp_h   = 16.0; // tallest component above PCB
top_clr  = 2.0;  // clearance above tallest component
corner_r = 3.0;  // exterior corner radius (vertical edges)

// ── Lid ───────────────────────────────────────────────────────
lid_t     = 3.0;  // lid plate thickness
engrave_d = 0.5;  // engraving depth for lid text

// ── Lid alignment lip ─────────────────────────────────────────
// 1 mm ring on the underside of the lid that drops into the box
// interior to locate it precisely before screwing down.
lip_h      = 1.0;   // lip protrusion below lid plate
lip_clr    = 0.25;  // radial clearance between lip and box interior
lip_wall_t = 1.5;   // ring wall thickness

// ── M2 PCB bosses (at PCB mounting hole positions) ────────────
boss_d   = 5.5;  // boss outer diameter
boss_h   = standoff;
m2_pilot = 1.8;  // M2 self-tapping pilot hole diameter

// ── Corner lid pillars ────────────────────────────────────────
// Positioned at the 4 interior corners — completely outside the
// PCB footprint so the PCB drops in straight without obstruction.
// Reduced diameter (3.5 mm) matched to the tighter gap.
pillar_rim_d  = 3.5; // diameter at rim (wide end, top)
pillar_foot_d = 2.0; // diameter at foot (narrow end, bottom)

// Lid / M3 screw parameters
m3_pilot  = 2.5;  // M3 self-tapping pilot hole diameter
m3_depth  = 10.0; // pilot depth from pillar tip
lid_clr_d   = 3.3; // M3 clearance hole through lid plate
lid_cbore_d = 6.5; // M3 pan-head counterbore diameter
lid_cbore_h = 2.0; // counterbore depth

// ── J1 terminal block cutout ─────────────────────────────────
j1_cy  = 20.32;
j1_cw  = 22.0;
j1_cz0 = standoff + 1.0;  // wire entry starts just above PCB surface
j1_ch  = pcb_t + 6.0;    // 7.6 mm — enough for 3 × 2.5 mm² leads

// ── HLK-PM01 vent grid ────────────────────────────────────────
// Component centre from KiCad PCB (relative to PCB corner):
//   X = 45.72 − 12.70 = 33.02 mm   Y = 36.905 − 12.70 = 24.205 mm
// Physical footprint: 34 × 20 mm
hlk_pcb_cx = 33.02;    // HLK centre along PCB length axis
hlk_pcb_cy = 24.205;   // HLK centre along PCB width axis
vent_n  = 5;    // number of vent slots
vent_sl = 26.0; // slot length (X direction)
vent_sw = 1.5;  // slot width
vent_sp = 3.0;  // slot pitch (centre-to-centre)

// ── Derived ───────────────────────────────────────────────────
int_l  = pcb_l + 2*gap;
int_w  = pcb_w + 2*gap;
int_h  = standoff + pcb_t + comp_h + top_clr;
pillar_h = int_h;  // full height — pillar runs from floor to rim
ext_l  = int_l + 2*wall;
ext_w  = int_w + 2*wall;
base_h = floor_t + int_h;

px0 = wall + gap;   // PCB X origin in world coords
py0 = wall + gap;   // PCB Y origin in world coords

// HLK-PM01 centre in world / lid coords
hlk_cx = px0 + hlk_pcb_cx;
hlk_cy = py0 + hlk_pcb_cy;

// PCB boss positions (world coords, at PCB mounting holes)
function bp(i) = [px0 + mh[i][0], py0 + mh[i][1]];

// Lid pillar positions (world coords, at interior corners)
// Pillar rim radius = pillar_rim_d/2; centre sits that far from each wall
function lp(i) = [
    (i == 0 || i == 2) ? wall + pillar_rim_d/2 : ext_l - wall - pillar_rim_d/2,
    (i == 0 || i == 1) ? wall + pillar_rim_d/2 : ext_w - wall - pillar_rim_d/2
];

j1_world_cy = py0 + j1_cy;

// ── Helpers ───────────────────────────────────────────────────
module rounded_rect(l, w, h, r) {
    hull()
        for (dx = [r, l-r], dy = [r, w-r])
            translate([dx, dy, 0])
                cylinder(r=r, h=h);
}

// ── Corner lid pillar ─────────────────────────────────────────
// Cone: wide at rim, narrow at foot — no supports needed.
// Top fused into the corner via hull() with the exterior corner arc.
module top_pillar(i) {
    pos = lp(i);
    z0  = base_h - pillar_h;

    // Exterior rounded-corner arc centre for this pillar's corner
    cx = (i == 0 || i == 2) ? corner_r : ext_l - corner_r;
    cy = (i == 0 || i == 1) ? corner_r : ext_w - corner_r;

    fuse_h = 4.0;  // depth of the fused zone from the rim downward

    difference() {
        union() {
            translate([pos[0], pos[1], z0])
                cylinder(d1=pillar_foot_d, d2=pillar_rim_d, h=pillar_h);
            hull() {
                translate([pos[0], pos[1], base_h - fuse_h])
                    cylinder(d=pillar_rim_d, h=fuse_h);
                translate([cx, cy, base_h - fuse_h])
                    cylinder(r=corner_r, h=fuse_h);
            }
        }
        // M3 blind pilot hole from rim downward
        translate([pos[0], pos[1], base_h - m3_depth])
            cylinder(d=m3_pilot, h=m3_depth + 0.01);
    }
}

// ── Base ──────────────────────────────────────────────────────
module base() {
    union() {
        // Hollow shell with J1 wire-entry cutout
        difference() {
            rounded_rect(ext_l, ext_w, base_h, corner_r);
            translate([wall, wall, floor_t])
                cube([int_l, int_w, int_h + 0.01]);
            translate([-0.01, j1_world_cy - j1_cw/2, floor_t + j1_cz0])
                cube([wall + 0.02, j1_cw, j1_ch]);
        }

        // M2 PCB bosses at mounting hole positions
        for (i = [0:3])
            difference() {
                translate([bp(i)[0], bp(i)[1], floor_t])
                    cylinder(d=boss_d, h=boss_h);
                translate([bp(i)[0], bp(i)[1], floor_t + boss_h - 4.0])
                    cylinder(d=m2_pilot, h=4.1);
            }

        // Corner lid pillars
        for (i = [0:3])
            top_pillar(i);
    }
}

// ── Lid ───────────────────────────────────────────────────────
module lid() {
    difference() {
        union() {
            // Main lid plate
            rounded_rect(ext_l, ext_w, lid_t, corner_r);

            // ── Alignment lip ─────────────────────────────────
            // 1 mm ring that drops into the box interior to locate
            // the lid before the screws are tightened.
            translate([0, 0, -lip_h])
                difference() {
                    // Solid ring outer profile
                    translate([wall + lip_clr, wall + lip_clr, 0])
                        cube([int_l - 2*lip_clr, int_w - 2*lip_clr, lip_h]);
                    // Hollow interior
                    translate([wall + lip_clr + lip_wall_t,
                               wall + lip_clr + lip_wall_t, -0.01])
                        cube([int_l - 2*lip_clr - 2*lip_wall_t,
                              int_w - 2*lip_clr - 2*lip_wall_t,
                              lip_h + 0.02]);
                    // Notch at each corner pillar so the lip clears
                    // the pillar rim when the lid is pressed down
                    for (i = [0:3])
                        translate([lp(i)[0], lp(i)[1], -0.01])
                            cylinder(d = pillar_rim_d + 0.5, h = lip_h + 0.02);
                }
        }

        // M3 clearance holes + counterbores aligned with corner pillars
        // Extended downward through the lip so the screw passes cleanly
        for (i = [0:3]) {
            translate([lp(i)[0], lp(i)[1], -lip_h - 0.01])
                cylinder(d=lid_clr_d, h=lid_t + lip_h + 0.02);
            translate([lp(i)[0], lp(i)[1], lid_t - lid_cbore_h])
                cylinder(d=lid_cbore_d, h=lid_cbore_h + 0.01);
        }

        // ── HLK-PM01 vent slots ───────────────────────────────
        // Horizontal slots through the lid above the power module.
        // Centred on lid X axis, lower quarter in Y (centre-down).
        for (k = [-(vent_n-1)/2 : 1 : (vent_n-1)/2])
            translate([ext_l/2 - vent_sl/2,
                       ext_w/4 + k*vent_sp - vent_sw/2,
                       -0.01])
                cube([vent_sl, vent_sw, lid_t + 0.02]);

        // "MaxPilot" engraved on outer face — centred horizontally, upper quarter
        translate([ext_l/2, ext_w*3/4, lid_t - engrave_d])
            linear_extrude(engrave_d + 0.01)
                text("MaxPilot", size=8, halign="center", valign="center",
                     font="Liberation Sans:style=Bold");
    }
}

// ── Render ────────────────────────────────────────────────────
part = "both";

if (part == "base" || part == "both")
    color("SteelBlue", 0.85) base();

if (part == "lid" || part == "both")
    color("LightSteelBlue", 0.7)
        if (part == "both")
            translate([0, 0, base_h + 8]) lid();
        else
            lid();

// ── Dimensions (echo) ─────────────────────────────────────────
echo(str("Box exterior: ", ext_l, " × ", ext_w, " × ", base_h + lid_t, " mm"));
echo(str("Base height:  ", base_h, " mm"));
echo(str("PCB clearance: ", gap, " mm each side"));
echo(str("Lid screws: 4× M3×", ceil(lid_t + m3_depth), " pan-head self-tapping"));
echo(str("PCB screws: 4× M2×6 pan-head self-tapping"));
echo(str("HLK-PM01 vent: ", vent_n, "× ", vent_sl, "×", vent_sw, " mm slots at ",
         vent_sp, " mm pitch"));
