/* ================================================================
   MaxPilot PCB Enclosure — v2.1
   PCB: 99.06 × 38.1 mm, 4× M2 mounting holes
   Mains wire entry: left wall (J1 terminal block)

   Assembly:
     1. Print base (open face up, no supports needed)
     2. Print lid (inner face on build plate, no supports needed)
     3. Insert PCB diagonally ("de travers", ~30° tilt about long axis)
        to clear the 4 internal pillars, then lower onto bosses
     4. Secure PCB with 4× M2×6 pan-head screws (self-tapping in PLA)
     5. Place lid, screw down with 4× M3×12 pan-head screws

   Hardware:
     4× M2×6  pan-head screws  (PCB  → pillar M2 boss)
     4× M3×12 pan-head screws  (lid  → pillar M3 top)
   ================================================================ */

$fn = 64;

// ── PCB ──────────────────────────────────────────────────────
pcb_l = 99.06;   // length
pcb_w = 38.1;    // width
pcb_t = 1.6;     // PCB thickness

// Mounting holes relative to PCB corner
mh = [[2.54, 2.54], [96.52, 2.54], [2.54, 35.56], [96.52, 35.56]];

// ── Box ───────────────────────────────────────────────────────
wall     = 3.0;  // wall thickness
floor_t  = 3.0;  // base floor thickness
gap      = 1.0;  // clearance around PCB edges
standoff = 5.0;  // boss height = PCB bottom clearance above floor
comp_h   = 22.0; // tallest component above PCB (HLK-PM01 ~20 mm)
top_clr  = 2.0;  // clearance above tallest component
corner_r = 3.0;  // exterior corner radius (vertical edges)

// ── Lid ───────────────────────────────────────────────────────
lid_t     = 3.0;  // lid plate thickness
engrave_d = 0.5;  // engraving depth for lid text

// ── Internal conical pillars ─────────────────────────────────
// Each pillar serves dual purpose:
//   • Lower section (M2 boss): PCB sits on top, M2 self-tapping screw
//   • Upper section (cone):    tapers to pillar_top_d at box rim
//   • M3 pilot at tip:         lid M3 screw threads in from above
boss_d        = 5.5;  // boss / cone base diameter
boss_h        = standoff; // boss height (= standoff height)
m2_pilot      = 1.8;  // M2 self-tapping pilot hole diameter
pillar_top_d  = 4.5;  // cone tip diameter (min ≈ m3_pilot + 2×0.75 mm wall)
m3_pilot      = 2.5;  // M3 self-tapping pilot hole diameter
m3_depth      = 10.0; // M3 pilot depth from pillar tip

// ── Lid screw clearances ─────────────────────────────────────
lid_clr_d    = 3.3;  // M3 clearance hole through lid plate
lid_cbore_d  = 6.5;  // M3 pan-head counterbore diameter
lid_cbore_h  = 2.0;  // counterbore depth

// ── J1 terminal block cutout ─────────────────────────────────
// J1 KiCad (17.78, 25.4) rot=-90° → PCB-rel (5.08, 12.7)
// Pins at PCB-Y: 12.7, 20.32, 27.94 — centre 20.32
// Wire entry: LEFT wall (X=0 face)
j1_cy  = 20.32; // pin centre Y in PCB coords
j1_cw  = 22.0;  // cutout width (Y), covers all 3 pins + margin
j1_cz0 = standoff - 2.5;  // start height rel to floor_t (below PCB)
j1_ch  = pcb_t + 13.0;    // cutout height: PCB + terminal body ~12 mm

// ── Derived ───────────────────────────────────────────────────
int_l  = pcb_l + 2*gap;
int_w  = pcb_w + 2*gap;
int_h  = standoff + pcb_t + comp_h + top_clr;
ext_l  = int_l + 2*wall;
ext_w  = int_w + 2*wall;
base_h = floor_t + int_h;

// PCB corner in box world coords
px0 = wall + gap;
py0 = wall + gap;

// Pillar centres in box world (same as PCB mounting holes)
function bp(i) = [px0 + mh[i][0], py0 + mh[i][1]];

// J1 cutout centre Y in box world
j1_world_cy = py0 + j1_cy;

// ── Helpers ───────────────────────────────────────────────────
// Rounded-corner prism (vertical edges only, fast hull)
module rounded_rect(l, w, h, r) {
    hull()
        for (dx = [r, l-r], dy = [r, w-r])
            translate([dx, dy, 0])
                cylinder(r=r, h=h);
}

// ── Conical pillar ────────────────────────────────────────────
// M2 boss at base (PCB standoff) + tapering cone to box rim + M3 at tip.
// Added via outer union() so the interior-cavity subtraction in base()
// does not remove the pillar body.
module inner_pillar(i) {
    pos = bp(i);
    difference() {
        union() {
            // M2 boss section — PCB rests on top face at z = floor_t + boss_h
            translate([pos[0], pos[1], floor_t])
                cylinder(d=boss_d, h=boss_h);
            // Conical section — tapers from boss_d to pillar_top_d up to box rim
            translate([pos[0], pos[1], floor_t + boss_h])
                cylinder(d1=boss_d, d2=pillar_top_d, h=int_h - boss_h);
        }
        // M2 blind pilot hole (PCB screw enters from above through PCB hole)
        translate([pos[0], pos[1], floor_t + boss_h - 4.0])
            cylinder(d=m2_pilot, h=4.1);
        // M3 blind pilot hole at pillar tip (lid screw enters from above)
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
            // Interior cavity
            translate([wall, wall, floor_t])
                cube([int_l, int_w, int_h + 0.01]);
            // J1 cutout through left wall
            translate([-0.01,
                       j1_world_cy - j1_cw/2,
                       floor_t + j1_cz0])
                cube([wall + 0.02, j1_cw, j1_ch]);
        }
        // 4 conical pillars — added to outer union so the interior
        // subtraction above does not remove them
        for (i = [0:3])
            inner_pillar(i);
    }
}

// ── Lid ───────────────────────────────────────────────────────
// Flat plate; no friction lip — the 4 M3 screws hold it in place.
// Print orientation: inner face on build plate, outer face up (no supports).
module lid() {
    difference() {
        // Flat lid plate, same footprint as base
        rounded_rect(ext_l, ext_w, lid_t, corner_r);

        // M3 clearance holes + pan-head counterbores on outer face (top)
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
// Set part = "base" | "lid" | "both" (default: "both" for preview)
part = "both";

if (part == "base" || part == "both")
    color("SteelBlue", 0.85) base();

if (part == "lid" || part == "both")
    color("LightSteelBlue", 0.7)
        if (part == "both")
            // Preview: lid floated above base
            translate([0, 0, base_h + 8]) lid();
        else
            // Print orientation: inner face on build plate
            lid();

// ── Dimensions (echo) ─────────────────────────────────────────
echo(str("Box exterior: ", ext_l, " × ", ext_w, " × ", base_h + lid_t, " mm"));
echo(str("Base height:  ", base_h, " mm"));
echo(str("Lid:          ", lid_t, " mm flat plate"));
echo(str("PCB standoff above floor: ", standoff, " mm"));
echo(str("Component space above PCB: ", comp_h, " mm"));
echo(str("Lid screws: 4× M3×", ceil(lid_t + m3_depth), " pan-head self-tapping"));
echo(str("PCB screws: 4× M2×6 pan-head self-tapping"));
