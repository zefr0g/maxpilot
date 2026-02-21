# MaxPilot

[![License](https://img.shields.io/badge/License-CERN--OHL--S--2.0-blue)](LICENSE) [![ESPHome](https://img.shields.io/badge/ESPHome-compatible-brightgreen)](https://esphome.io/) [![KiCad 9](https://img.shields.io/badge/KiCad-9-blue)](https://www.kicad.org/) [![Home Assistant](https://img.shields.io/badge/Home%20Assistant-compatible-41BDF5)](https://www.home-assistant.io/)

> WiFi control for French electric radiators via Home Assistant — under €15.

[Version française → README.md](README.md)

![MaxPilot - Assembled board photo](images/photo.jpg)

MaxPilot is an open-source board that lets you **control your electric radiators from your phone or computer**, via Home Assistant. It connects to your radiators' "fil pilote" (pilot wire) and sets the heating mode (Comfort, Eco, Frost protection, Off) over WiFi. No more wall-mounted programmer — manage everything from your smart home. Built around **low-cost, widely available components** (WeMos D1 Mini ~€3, optocouplers), it is accessible to any electronics hobbyist.

---

## Table of Contents

- [What is "Fil Pilote"?](#what-is-fil-pilote)
- [Features](#features)
- [Quick Start](#quick-start)
- [Wiring](#wiring)
- [Schematic](#schematic)
- [Bill of Materials](#bill-of-materials)
- [ESPHome Configuration](#esphome-configuration)
- [Home Assistant Integration](#home-assistant-integration)
- [PCB Manufacturing](#pcb-manufacturing)
- [Enclosure](#enclosure)
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
- Surge protection (275V MOV varistor)
- Zero-cross optocouplers (MOC3041M) for clean switching
- 1A fuse protection
- Built-in thermostat with external temperature sensor (optional)
- 3D-printable enclosure included

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

> ⚠️ **WARNING**: Switch off the circuit breaker before any wiring!

The board connects via the 3-pin terminal block (J1). The pilot wire on your radiator is the black (or sometimes grey) wire in your radiator's electrical conduit.

```
                    Bornier J1 / Terminal block J1
                   ┌─────┬─────┬─────┐
                   │  L  │  N  │  P  │
                   └──┬──┴──┬──┴──┬──┘
                      │     │     │
                      │     │     └──── Pilot wire to radiator
                      │     │
                      │     └────────── Neutral (blue)
                      │
                      └──────────────── Live (brown or red)

          From the electrical panel
```

---

## Schematic

The full schematic is in `hardware/kicad/MaxPilot.kicad_sch` (KiCad 9).

![Schematic](images/MaxPilot.svg)

### Architecture

```
Mains AC ──► F1 (1A fuse) ──► RV1 (varistor) ──► PS1 (HLK-PM01) ──► 5V DC
                                                         │
                                                  U1 (WeMos D1 Mini)
                                                   │            │
                                               GPIO D3       GPIO D7
                                                   │            │
                                               R1 (570Ω)    R2 (570Ω)
                                                   │            │
                                               U2 (MOC3041M) U3 (MOC3041M)
                                                   │            │
                                               D1 (1N4007)  D2 (1N4007)
                                                   │            │
                                                Channel 1    Channel 2
```

### Pin Mapping

| GPIO | Function |
|------|----------|
| D3   | SSR1 — Optocoupler U2 (positive half-wave) |
| D7   | SSR2 — Optocoupler U3 (negative half-wave) |

---

## Bill of Materials

| Ref | Qty | Value | Description |
|-----|:---:|-------|-------------|
| F1 | 1 | 1A | Mini blade fuse (Keystone 3568) |
| C1 | 1 | 22µF 25V | Ceramic capacitor |
| U1 | 1 | WeMos D1 Mini | ESP8266 microcontroller |
| U2, U3 | 2 | MOC3041M | Opto-triac — clip pin 5 before soldering |
| R1, R2 | 2 | 570Ω | Axial resistors |
| D1, D2 | 2 | 1N4007 | Protection diodes |
| RV1 | 1 | MOV 275V | Varistor 14D431K (surge protection) |
| PS1 | 1 | HLK-PM01 | Isolated AC-DC 5V power supply |
| J1 | 1 | 3-pin 7.62mm | Terminal block — e.g. Würth 691311400103, Phoenix MKDS 1,5/3-7,62 |

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

Gerber files ready for JLCPCB, PCBWay, etc. — in `hardware/gerber/`.

| Front | Back |
|:--:|:--:|
| ![PCB Front](images/MaxPilot-pcb-front.svg) | ![PCB Back](images/MaxPilot-pcb-back.svg) |

---

## Enclosure

A 3D-printable enclosure is included in `hardware/enclosure/`. Print without supports in PLA, open face up.

- **PCB screws**: 4× M2×6 (into bottom standoffs)
- **Lid screws**: 4× M3×13 (self-tapping into corner pillars)

---

## Safety

> ⚠️ **WARNING: This project involves mains voltage (230V AC). Risk of fatal electrocution.**
> Always switch off the power before any work. The board must be installed in a closed enclosure.

PCB v2.0 meets IPC-2221B and IEC 62368-1 isolation requirements:
- Mains ↔ low-voltage clearance: ≥ 3.0 mm
- Creepage distance: ≥ 5.0 mm

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
