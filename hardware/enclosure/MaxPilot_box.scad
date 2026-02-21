/* ================================================================
   MaxPilot PCB Enclosure — v2.2
   PCB: 99.06 × 38.1 mm, 4× M2 mounting holes
   Mains wire entry: left wall (J1 terminal block)

   Assembly:
     1. Print base (open face up, no supports needed)
     2. Print lid (inner face on build plate, no supports needed)
     3. Lower PCB straight into box until ~12 mm from top, then tilt
        slightly ("de travers") to slip corners past the 4 top pillars,
        and lower onto the M2 bosses
     4. Secure PCB with 4× M2×6 pan-head screws (self-tapping in PLA)
     5. Place lid, screw down with 4× M3×12 pan-head screws

   Hardware:
     4× M2×6  pan-head screws  (PCB  → M2 boss at base of pillar)
     4× M3×12 pan-head screws  (lid  → M3 pilot at pillar tip)
   ================================================================ */

$fn = 64;

// ── PCB ──────────────────────────────────────────────────────
pcb_l = 99.06;   // length
pcb_w = 38.1;    // width
pcb_t = 1.6;     // PCB thickness

// Mounting holes relative to PCB corner
mh = [[2.54, 2.54], [96.52, 2.54], [2.54, 35.56], [96.52, 35.56]];

// ── Box ───────────────────────────────────────────────────────
wall     = 2.5;  // wall thickness (thinned; gap widened to keep same exterior)
floor_t  = 3.0;  // base floor thickness
gap      = 1.5;  // clearance around PCB edges
standoff = 5.0;  // boss height = PCB bottom clearance above floor
comp_h   = 19.0; // tallest component above PCB (trimmed 3 mm from measured fit)
top_clr  = 2.0;  // clearance above tallest component
corner_r = 3.0;  // exterior corner radius (vertical edges)

// ── Lid ───────────────────────────────────────────────────────
lid_t     = 3.0;  // lid plate thickness
engrave_d = 0.5;  // engraving depth for lid text

// ── M2 PCB bosses (bottom, unchanged from v2.0) ───────────────
boss_d   = 5.5;  // boss outer diameter
boss_h   = standoff;
m2_pilot = 1.8;  // M2 self-tapping pilot hole diameter

// ── Short top pillars (conical, near box rim only) ────────────
// These start pillar_h mm from the top — the rest of the box is
// clear so the PCB drops in freely until the last ~12 mm.
// pillar_rim_d (wide, at top/rim) merges with corner walls so
// the pillar prints without supports and is solid.
// Cone tapers downward to pillar_foot_d (narrow at bottom).
pillar_h      = 12.0; // height from box rim down to pillar foot
pillar_rim_d  = 7.0;  // diameter at rim (top) — merges with corner walls
pillar_foot_d = 5.0;  // diameter at foot (bottom, narrow end)

// Lid / M3 screw parameters
m3_pilot  = 2.5;  // M3 self-tapping pilot hole diameter
m3_depth  = 10.0; // pilot depth from pillar tip
lid_clr_d   = 3.3; // M3 clearance hole through lid plate
lid_cbore_d = 6.5; // M3 pan-head counterbore diameter
lid_cbore_h = 2.0; // counterbore depth

// ── J1 terminal block cutout ─────────────────────────────────
j1_cy  = 20.32;
j1_cw  = 22.0;
j1_cz0 = standoff + 1.0;   // wire entry starts just above PCB surface
j1_ch  = pcb_t + 6.0;     // 7.6 mm — enough for 3 × 2.5 mm² leads

// ── Derived ───────────────────────────────────────────────────
int_l  = pcb_l + 2*gap;
int_w  = pcb_w + 2*gap;
int_h  = standoff + pcb_t + comp_h + top_clr;
ext_l  = int_l + 2*wall;
ext_w  = int_w + 2*wall;
base_h = floor_t + int_h;

px0 = wall + gap;
py0 = wall + gap;

function bp(i) = [px0 + mh[i][0], py0 + mh[i][1]];

j1_world_cy = py0 + j1_cy;

// ── Helpers ───────────────────────────────────────────────────
module rounded_rect(l, w, h, r) {
    hull()
        for (dx = [r, l-r], dy = [r, w-r])
            translate([dx, dy, 0])
                cylinder(r=r, h=h);
}

// ── Short top pillar ──────────────────────────────────────────
// Cone tapers from pillar_foot_d (bottom) up to pillar_rim_d (top).
// Top is fused into the corner walls via hull() with the exterior
// corner arc — no gap between pillar and walls at the rim.
module top_pillar(i) {
    pos = bp(i);
    z0  = base_h - pillar_h;

    // Exterior rounded-corner arc centre for this pillar's corner
    cx = (i == 0 || i == 2) ? corner_r : ext_l - corner_r;
    cy = (i == 0 || i == 1) ? corner_r : ext_w - corner_r;

    fuse_h = 4.0;  // depth of the fused zone from the rim downward

    difference() {
        union() {
            // Conical body
            translate([pos[0], pos[1], z0])
                cylinder(d1=pillar_foot_d, d2=pillar_rim_d, h=pillar_h);
            // Fuse top into corner: hull between pillar top and corner arc
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

        // M2 PCB bosses — added to outer union so interior subtraction
        // above does not remove them
        for (i = [0:3])
            difference() {
                translate([bp(i)[0], bp(i)[1], floor_t])
                    cylinder(d=boss_d, h=boss_h);
                translate([bp(i)[0], bp(i)[1], floor_t + boss_h - 4.0])
                    cylinder(d=m2_pilot, h=4.1);
            }

        // Short top pillars — also added to outer union
        for (i = [0:3])
            top_pillar(i);
    }
}

// ── Lid ───────────────────────────────────────────────────────
// Flat plate; held by 4 M3 screws into the top pillar tips.
// Print: inner face on build plate, outer face up — no supports.
module lid() {
    difference() {
        rounded_rect(ext_l, ext_w, lid_t, corner_r);

        // M3 clearance holes + counterbores (outer / top face)
        for (i = [0:3]) {
            translate([bp(i)[0], bp(i)[1], -0.01])
                cylinder(d=lid_clr_d, h=lid_t + 0.02);
            translate([bp(i)[0], bp(i)[1], lid_t - lid_cbore_h])
                cylinder(d=lid_cbore_d, h=lid_cbore_h + 0.01);
        }

        // "MaxPilot" engraved on outer face
        translate([ext_l/2, ext_w/2, lid_t - engrave_d])
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
            lid();  // print: inner face on build plate

// ── Dimensions (echo) ─────────────────────────────────────────
echo(str("Box exterior: ", ext_l, " × ", ext_w, " × ", base_h + lid_t, " mm"));
echo(str("Base height:  ", base_h, " mm"));
echo(str("Clear interior height (below pillars): ", base_h - pillar_h - floor_t, " mm"));
echo(str("Pillar zone height: ", pillar_h, " mm from top"));
echo(str("Lid screws: 4× M3×", ceil(lid_t + m3_depth), " pan-head self-tapping"));
echo(str("PCB screws: 4× M2×6 pan-head self-tapping"));
