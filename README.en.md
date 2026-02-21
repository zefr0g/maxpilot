# MaxPilot

[Version française → README.md](README.md)

![MaxPilot - Assembled board photo](images/photo.jpg)

MaxPilot is an open-source board that lets you **control your electric radiators from your phone or computer**, via Home Assistant. It connects to your radiators' "fil pilote" (pilot wire) and sets the heating mode (Comfort, Eco, Frost protection, Off) over WiFi. No more wall-mounted programmer: manage everything from your smart home. Built around **low-cost, widely available components** (WeMos D1 Mini ~€3, optocouplers, MOSFETs), it is accessible to any electronics hobbyist.

---

## Table of Contents

- [What is "Fil Pilote"?](#what-is-fil-pilote)
- [Features](#features)
- [Climate Control](#4-climate-control-optional)
- [Quick Start](#quick-start)
- [Wiring](#wiring)
- [Schematic](#schematic)
- [Bill of Materials](#bill-of-materials)
- [ESPHome Configuration](#esphome-configuration)
- [Home Assistant Integration](#home-assistant-integration)
- [PCB Manufacturing](#pcb-manufacturing)
- [Safety](#safety)
- [License](#license)

---

## What is "Fil Pilote"?

**Fil pilote** ("pilot wire") is a system used in France to control electric radiators. In addition to power wires (live + neutral), an extra wire — the pilot wire — carries a 230V AC control signal. The radiator adjusts its operation based on the **shape of the signal** it receives:

| Mode | What the radiator does | Signal on pilot wire | SSR1 | SSR2 |
|---|---|---|:---:|:---:|
| **Comfort** | Heats to thermostat setpoint | No signal (open wire) | OFF | OFF |
| **Eco** | Reduces temperature by ~3-4°C | Full 230V sine wave | ON | ON |
| **Frost protection** | Maintains ~7°C minimum | Positive half-wave only | ON | OFF |
| **Off** | Radiator off | Negative half-wave only | OFF | ON |

```
Comfort (no signal)                Eco (full sine wave)

                                        ╭──╮      ╭──╮
                                       ╱    ╲    ╱    ╲
 ──────────────────────        ───────╱──────╲──╱──────╲───
                                    ╲    ╱    ╲    ╱
                                     ╰──╯      ╰──╯

   SSR1: OFF  SSR2: OFF           SSR1: ON   SSR2: ON


Frost protection (positive half-wave)   Off (negative half-wave)

      ╭──╮      ╭──╮
     ╱    ╲    ╱    ╲
 ───╱──────╲──╱──────╲───     ─────────────────────────────
                                    ╲    ╱    ╲    ╱
                                     ╰──╯      ╰──╯

   SSR1: ON   SSR2: OFF           SSR1: OFF  SSR2: ON
```

MaxPilot uses **two MOC3041M optocouplers** per channel, with **1N4007 diodes**, to selectively pass the positive half-wave, the negative half-wave, both, or neither. The MOC3041M includes built-in zero-cross detection to switch cleanly without electrical noise.

---

## Features

- ESP8266 microcontroller (WeMos D1 Mini) with built-in WiFi
- Compatible with ESPHome and Home Assistant
- Isolated AC/DC power supply (HLK-PM01, 5V)
- Surge protection (varistor)
- Zero-cross optocouplers (MOC3041M) for clean switching
- 1A fuse protection
- Built-in thermostat with external temperature sensor (optional)

---

## Quick Start

1. **Manufacture or order the PCB** — send Gerber files to a manufacturer (JLCPCB, PCBWay...)
2. **Solder the components** — see the [bill of materials](#bill-of-materials) below
3. **Flash the firmware** — plug the D1 Mini via USB and run `esphome run esphome/maxpilot_ch1.yaml`
4. **Wire the board** — connect live, neutral and pilot wire to the terminal block (see [wiring](#wiring))
5. **Add to Home Assistant** — the device appears automatically in Home Assistant via ESPHome integration
6. **Control your radiators** — set modes from the dashboard or through automations

---

## Wiring

> **WARNING**: Switch off the circuit breaker before any wiring!

The board connects via the 3-pin terminal block (J1). The pilot wire on your radiator is the black (or sometimes grey) wire in your radiator's electrical conduit.

```
                    Bornier J1 / Terminal block J1
                   ┌─────┬─────┬─────┐
                   │  L  │  N  │  P  │
                   └──┬──┴──┬──┴──┬──┘
                      │     │     │
                      │     │     └──── Fil pilote vers radiateur
                      │     │           Pilot wire to radiator
                      │     │
                      │     └────────── Neutre / Neutral (bleu/blue)
                      │
                      └──────────────── Phase / Live (marron ou rouge / brown or red)

          Depuis le tableau électrique / From the electrical panel
```

---

## Schematic

The full schematic is in `hardware/kicad/MaxPilot.kicad_sch` (KiCad 9).

![Schematic](images/MaxPilot.svg)

### Architecture

```
Secteur AC ──► Fusible (F1) ──► Varistance (RV1) ──► HLK-PM01 (PS1) ──► 5V DC
                                                            │
                                                     WeMos D1 Mini (U1)
                                                      │           │
                                                  GPIO D3      GPIO D7
                                                      │           │
                                                  R1 (570Ω)   R2 (570Ω)
                                                      │           │
                                                  MOC3041M     MOC3041M
                                                   (U2)         (U3)
                                                      │           │
                                                  D1 (1N4007) D2 (1N4007)
                                                      │           │
                                                  Canal 1      Canal 2
                                                 Channel 1    Channel 2
```

### Pin Mapping

| GPIO | Function |
|------|----------|
| D3   | SSR1 — Optocoupler U2 (positive half-wave) |
| D7   | SSR2 — Optocoupler U3 (negative half-wave) |

---

## Bill of Materials

| Ref | Value | Footprint | Qty | Description |
|-----|-------|-----------|-----|-------------|
| F1 | 1A | Fuseholder_Blade_Mini_Keystone_3568 | 1 | Fuse |
| C1 | 22µF 25V ceramic | C_Disc_D8.0mm_W2.5mm_P5.00mm | 1 | Ceramic capacitor |
| U1 | WeMos D1 Mini | WEMOS_D1_mini_light | 1 | ESP8266 microcontroller |
| U2, U3 | MOC3041M | MOC3041M_DIP6_W7.62mm_NC5 | 2 | Opto-triac (pin 5 NC — clip before soldering) |
| R1, R2 | 570Ω | R_Axial_DIN0207 | 2 | Resistors |
| D1, D2 | 1N4007 | D_DO-41_SOD81 | 2 | Protection diodes |
| RV1 | MOV 275V (14D431K) | RV_Disc_D12mm | 1 | 275V Varistor (surge protection) |
| PS1 | HLK-PM01 | Converter_ACDC_HiLink_HLK-PMxx | 1 | AC-DC 5V power supply |
| J1 | 3-pin terminal block 7.62mm | TerminalBlock_Generic_1x03_P7.62mm_Horizontal | 1 | Terminal block (e.g. Würth 691311400103, Phoenix MKDS 1,5/3-7,62) |

---

## ESPHome Configuration

### 1. Prepare secrets

```bash
cp esphome/secrets.yaml.example esphome/secrets.yaml
# Edit esphome/secrets.yaml with your credentials
```

### 2. Per-channel configuration

See `esphome/maxpilot_ch1.yaml` for a configuration example:

```yaml
substitutions:
  name: maxpilot_ch1
  ch_name: "CH1"
  ssr1_pin: D3
  ssr2_pin: D7
  temp_sensor_entity: "none"
  temp_sensor_internal: "true"

packages:
  core: !include common/core.yaml
  wifi: !include common/wifi.yaml
  maxpilot: !include common/maxpilot.yaml

esphome:
  name: ${name}
```

The `esphome/common/` files contain shared configuration (WiFi, sensors, fil pilote logic).

### 3. Temperature sensor (optional)

If you have a room temperature sensor, you can import it from Home Assistant:

```yaml
substitutions:
  temp_sensor_entity: "sensor.temperature_salon"
  temp_sensor_internal: "false"
```

### 4. Climate control (optional)

Add the climate package for a built-in thermostat:

```yaml
packages:
  core: !include common/core.yaml
  wifi: !include common/wifi.yaml
  maxpilot: !include common/maxpilot.yaml
  climate: !include common/maxpilot_climate.yaml
```

| Preset | Setpoint | Fil pilote mode |
|--------|:--------:|-----------------|
| **Comfort** | 19°C | Comfort |
| **Eco** | 17°C | Eco |
| **Frost protection** | 7°C | Frost protection |
| **Away** | — | Off |

### 5. Flash

```bash
# First flash (USB)
esphome run esphome/maxpilot_ch1.yaml

# OTA updates
esphome run esphome/maxpilot_ch1.yaml --device maxpilot_ch1.local
```

---

## Home Assistant Integration

Once flashed, MaxPilot appears automatically in Home Assistant:
- **Fil Pilote CH1** — mode selector: Confort, Éco, Hors-gel, Arrêt
- **Radiateur CH1** *(if climate enabled)* — thermostat with setpoint and presets

Example automation:

```yaml
automation:
  - alias: "Living room radiator - Eco at night"
    trigger:
      - platform: time
        at: "22:00:00"
    action:
      - service: select.select_option
        target:
          entity_id: select.fil_pilote_ch1
        data:
          option: "Éco"
```

---

## PCB Manufacturing

Gerber files ready for JLCPCB, PCBWay, etc.

| Front | Back |
|:--:|:--:|
| ![PCB Front](images/MaxPilot-pcb-front.svg) | ![PCB Back](images/MaxPilot-pcb-back.svg) |

Files in `hardware/gerber/`:
- `MaxPilot-F_Cu.gtl` / `MaxPilot-B_Cu.gbl`
- `MaxPilot-F_Mask.gts` / `MaxPilot-B_Mask.gbs`
- `MaxPilot-F_Silkscreen.gto` / `MaxPilot-B_Silkscreen.gbo`
- `MaxPilot-Edge_Cuts.gm1`
- `MaxPilot.drl` — drill file (unified PTH+NPTH)
- `MaxPilot-job.gbrjob`

---

## Safety

> **WARNING: This project involves mains voltage (230V AC). Risk of fatal electrocution. Always switch off the power before any work. The board must be installed in a closed enclosure.**

PCB v2.0 meets IPC-2221B and IEC 62368-1 creepage and clearance requirements (clearance ≥ 3.0 mm mains↔LV, creepage ≥ 5.0 mm).

---

## Changelog

### v2.0
- Creepage and clearance compliant with IPC-2221B / IEC 62368-1
- J1 terminal block replaced with 7.62 mm pitch
- MOC3041M footprint corrected (pin 5 NPTH)
- Mains routing on back copper layer (B.Cu), no vias
- M2 mounting holes at all 4 corners
- 3D-printable enclosure (hardware/enclosure/)

### v1.0
- First functional design

---

## License

CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S-2.0)

See [LICENSE](LICENSE) for the full text.
