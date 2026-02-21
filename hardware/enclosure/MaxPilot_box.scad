/* ================================================================
   MaxPilot PCB Enclosure — v2.0
   PCB: 99.06 × 38.1 mm, 4× M2 mounting holes
   Mains wire entry: left wall (J1 terminal block)

   Assembly:
     1. Print base (open face up, no supports needed)
     2. Print lid (lip face up, flip for installation)
     3. Place PCB on bosses, secure with 4× M2×6 screws from above
     4. Press-fit lid onto base (lip depth = 5 mm)

   Hardware:
     4× M2×6 pan-head screws (PCB to bosses, self-tapping in PLA)
   ================================================================ */

$fn = 64;

// ── PCB ──────────────────────────────────────────────────────
pcb_l = 99.06;   // length (KiCad X 12.7 → 111.76)
pcb_w = 38.1;    // width  (KiCad Y 12.7 → 50.8)
pcb_t = 1.6;     // PCB thickness

// Mounting holes relative to PCB corner (KiCad origin 12.7, 12.7)
mh = [[2.54, 2.54], [96.52, 2.54], [2.54, 35.56], [96.52, 35.56]];

// ── Box ───────────────────────────────────────────────────────
wall     = 3.0;  // wall thickness
floor_t  = 3.0;  // base floor thickness
gap      = 1.0;  // clearance around PCB edges
standoff = 5.0;  // boss height = PCB clearance above floor
comp_h   = 22.0; // tallest component above PCB (HLK-PM01 ~20 mm)
top_clr  = 2.0;  // clearance above tallest component

// ── Lid ───────────────────────────────────────────────────────
lid_t    = 3.0;  // lid plate thickness
lip_h    = 5.0;  // friction-fit lip depth
lip_t    = 2.0;  // lip wall thickness
lip_clr  = 0.2;  // clearance each side (adjust for printer tolerance)

// ── Bosses (M2 standoffs) ────────────────────────────────────
boss_d   = 5.5;  // boss outer diameter
boss_h   = standoff;
screw_d  = 1.8;  // self-tapping M2 blind hole in boss
floor_d  = 2.3;  // M2 clearance hole through base floor

// ── J1 terminal block cutout ─────────────────────────────────
// J1 KiCad (17.78, 25.4) rot=-90° → PCB-rel (5.08, 12.7)
// Pins at PCB-Y: 12.7, 20.32, 27.94 — centre 20.32
// Wire entry: LEFT wall (X=0 face)
j1_cy   = 20.32; // pin centre Y in PCB coords
j1_cw   = 22.0;  // cutout width (Y direction, covers all 3 pins + margin)
j1_cz0  = standoff - 2.5; // start below PCB (rel to floor_t)
j1_ch   = pcb_t + 13.0;   // height: PCB thickness + terminal body ~12 mm

// ── Derived ───────────────────────────────────────────────────
int_l  = pcb_l + 2*gap;
int_w  = pcb_w + 2*gap;
int_h  = standoff + pcb_t + comp_h + top_clr;
ext_l  = int_l + 2*wall;
ext_w  = int_w + 2*wall;
base_h = floor_t + int_h;

// PCB corner in box world
px0 = wall + gap;
py0 = wall + gap;

// Boss centres in box world
function bp(i) = [px0 + mh[i][0], py0 + mh[i][1]];

// J1 cutout centre Y in box world
j1_world_cy = py0 + j1_cy;

// ── Base ──────────────────────────────────────────────────────
module base() {
    union() {
        // Hollow shell (outer cube minus interior cavity and J1 cutout)
        difference() {
            cube([ext_l, ext_w, base_h]);

            // Interior cavity
            translate([wall, wall, floor_t])
                cube([int_l, int_w, int_h + 0.01]);

            // J1 wire entry cutout (left wall)
            translate([-0.01,
                       j1_world_cy - j1_cw/2,
                       floor_t + j1_cz0])
                cube([wall + 0.02, j1_cw, j1_ch]);
        }

        // PCB standoff bosses (added after interior subtraction so they survive)
        for (i = [0:3])
            difference() {
                translate([bp(i)[0], bp(i)[1], floor_t])
                    cylinder(d=boss_d, h=boss_h);

                // M2 blind hole in boss top (self-tapping, 4 mm deep)
                translate([bp(i)[0], bp(i)[1], floor_t + boss_h - 4.0])
                    cylinder(d=screw_d, h=4.1);
            }
    }
}

// ── Lid ───────────────────────────────────────────────────────
module lid() {
    lip_ol = int_l - 2*lip_clr;
    lip_ow = int_w - 2*lip_clr;

    union() {
        // Lid plate
        cube([ext_l, ext_w, lid_t]);

        // Friction-fit lip (hangs into base interior when installed)
        translate([(ext_l - lip_ol) / 2,
                   (ext_w - lip_ow) / 2,
                   -lip_h])
            difference() {
                cube([lip_ol, lip_ow, lip_h]);
                translate([lip_t, lip_t, -0.01])
                    cube([lip_ol - 2*lip_t,
                          lip_ow - 2*lip_t,
                          lip_h + 0.02]);
            }
    }
}

// ── Render ────────────────────────────────────────────────────
// Set part = "base" | "lid" | "both" (default: "both" for preview)
part = "both";

if (part == "base" || part == "both")
    color("SteelBlue", 0.85) base();

if (part == "lid" || part == "both")
    color("LightSteelBlue", 0.7)
        translate([0, 0, (part == "both") ? base_h + 8 : 0])
            lid();

// ── Dimensions (echo) ─────────────────────────────────────────
echo(str("Box exterior: ", ext_l, " × ", ext_w, " × ", base_h + lid_t, " mm"));
echo(str("Base height:  ", base_h, " mm"));
echo(str("Lid height:   ", lid_t, " mm"));
echo(str("PCB clearance above floor: ", standoff, " mm"));
echo(str("Component space above PCB: ", comp_h, " mm"));
