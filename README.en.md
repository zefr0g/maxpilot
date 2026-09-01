# MaxPilot

[![Validate](https://github.com/zefr0g/maxpilot/actions/workflows/validate.yml/badge.svg)](https://github.com/zefr0g/maxpilot/actions/workflows/validate.yml) [![License](https://img.shields.io/badge/License-CERN--OHL--S--2.0-blue)](LICENSE) [![ESPHome](https://img.shields.io/badge/ESPHome-compatible-brightgreen)](https://esphome.io/) [![Home Assistant](https://img.shields.io/badge/Home%20Assistant-compatible-41BDF5)](https://www.home-assistant.io/) [![KiCad 9](https://img.shields.io/badge/KiCad-9-blue)](https://www.kicad.org/) [![GitHub stars](https://img.shields.io/github/stars/zefr0g/maxpilot?style=flat)](https://github.com/zefr0g/maxpilot/stargazers)

> WiFi control of French electric radiators from Home Assistant — open-source board, ~€12 in parts, 100% local.

[Version française → README.md](README.md)

| Assembled board | 3D-printed enclosure |
|:--:|:--:|
| <img src="images/photo.jpg" alt="MaxPilot - assembled board" width="380"> | <img src="images/enclosure-both.png" alt="MaxPilot enclosure" width="520"> |

MaxPilot is an open-source board that connects to the **fil pilote** (pilot wire) of French electric radiators and sets their mode (Comfort, Eco, Frost protection, Off) from Home Assistant through ESPHome. No more wall programmer: the board replaces the central thermostat, with no cloud and no subscription. It is built around **cheap, easy-to-find parts** (WeMos D1 Mini, optocouplers, HLK-PM01 power module) and is entirely through-hole: any electronics hobbyist can build it.

## Why MaxPilot?

- **Local and open** — no cloud, no proprietary app: ESPHome + Home Assistant, you stay in control
- **Really cheap** — about €12 per radiator, all in (see [cost](#cost))
- **One pilot wire, several radiators** — one board drives every radiator wired to the same pilot wire
- **Built-in thermostat** — import any Home Assistant temperature sensor and let the board regulate
- **Designed for 230 V** — fuse, varistor, isolated supply, IPC-2221B / IEC 62368-1 creepage and clearance, closed enclosure
- **Everything included** — KiCad schematic and PCB, Gerbers, BOM, firmware, OpenSCAD/STL enclosure

| | MaxPilot | Commercial WiFi module (e.g. Heatzy Pilote) | Z-Wave module (e.g. Qubino Pilot Wire) |
|---|:--:|:--:|:--:|
| Approx. price per radiator | **~€12** | ~€50 | ~€60 |
| Works without cloud | ✅ | ❌ | ✅ |
| Home Assistant integration | native (ESPHome) | third-party integration | Z-Wave JS + USB stick |
| Modifiable firmware | ✅ | ❌ | ❌ |
| Open hardware | ✅ | ❌ | ❌ |
| DIY assembly | yes (through-hole soldering) | no | no |

---

## Table of Contents

- [What is "Fil Pilote"?](#what-is-fil-pilote)
- [Features](#features)
- [Cost](#cost)
- [Quick Start](#quick-start)
- [Wiring](#wiring)
- [Schematic](#schematic)
- [Bill of Materials](#bill-of-materials)
- [ESPHome Firmware](#esphome-firmware)
- [Home Assistant Integration](#home-assistant-integration)
- [PCB Manufacturing](#pcb-manufacturing)
- [Enclosure](#enclosure)
- [Safety](#safety)
- [Contributing](#contributing)
- [License](#license)

---

## What is "Fil Pilote"?

**Fil pilote** ("pilot wire") is the standard system in France (GIFAM protocol) for controlling electric radiators. Besides live and neutral, an extra wire — the pilot wire — carries a control signal derived from the 230 V mains. The radiator picks its mode from the **shape of the signal** it receives:

| Mode | What the radiator does | Signal on pilot wire | SSR1 | SSR2 |
|---|---|---|:---:|:---:|
| **Comfort** | Heats to thermostat setpoint | No signal (open wire) | OFF | OFF |
| **Eco** | Setpoint lowered by ~3-4 °C | Full 230 V sine wave | ON | ON |
| **Frost protection** | Maintains ~7 °C minimum | Negative half-wave only | ON | OFF |
| **Off** | Radiator off | Positive half-wave only | OFF | ON |

```
Comfort (no signal)                Eco (full sine wave)

                                        ╭──╮      ╭──╮
                                       ╱    ╲    ╱    ╲
 ──────────────────────        ───────╱──────╲──╱──────╲───
                                    ╲    ╱    ╲    ╱
                                     ╰──╯      ╰──╯

   SSR1: OFF  SSR2: OFF           SSR1: ON   SSR2: ON


Frost protection (negative half-wave)   Off (positive half-wave)

                                             ╭──╮      ╭──╮
                                            ╱    ╲    ╱    ╲
 ───────────────────────────            ────╱──────╲──╱──────╲───
    ╲    ╱    ╲    ╱
     ╰──╯      ╰──╯

   SSR1: ON   SSR2: OFF                 SSR1: OFF  SSR2: ON
```

MaxPilot uses **two MOC3041M opto-triacs** (SSR1 and SSR2), each in series with a **1N4007 diode** mounted in opposite directions. SSR1 passes the negative half-wave, SSR2 the positive one; both together pass the full sine wave. The MOC3041M switches at zero crossing, so without electrical noise. A pilot wire only draws a few milliamps, so one board can drive **every radiator connected to the same pilot wire**.

---

## Features

- ESP8266 (WeMos D1 Mini) with built-in WiFi, ESPHome firmware
- Comfort / Eco / Frost protection / Off mode selector in Home Assistant
- Optional thermostat: temperature sensor imported from Home Assistant, Comfort / Eco / Frost / Away presets
- Mode restored after a power cut
- Isolated AC/DC supply (HLK-PM01, 5 V), 1 A fuse, 275 V varistor
- Zero-cross opto-triacs (MOC3041M)
- 99 × 38 mm PCB, through-hole parts only, 4 M2 mounting holes
- 3D-printable enclosure (OpenSCAD + STL) with vent slots above the power module

---

## Cost

Indicative 2026 prices (AliExpress / LCSC / distributors, excluding shipping), per board:

| Part | Approx. price |
|---|--:|
| WeMos D1 Mini | €3.00 |
| HLK-PM01 | €3.00 |
| 2 × MOC3041M | €1.20 |
| 7.62 mm terminal block | €0.70 |
| Fuse holder + 1 A fuse | €0.80 |
| Varistor, diodes, resistors, capacitor | €0.60 |
| PCB (JLCPCB, batch of 5) | ~€2.00 |
| **Total** | **~€11** |

---

## Quick Start

1. **Order the PCB** — send `hardware/gerber/MaxPilot.zip` to JLCPCB, PCBWay, Aisler…
2. **Solder the parts** — see the [bill of materials](#bill-of-materials); everything is through-hole
3. **Flash the firmware** — plug the D1 Mini via USB and run `esphome run esphome/maxpilot_ch1.yaml` (see [ESPHome Firmware](#esphome-firmware))
4. **Wire the board** — live, neutral and pilot wire on the terminal block, power off (see [wiring](#wiring))
5. **Close the enclosure** — mandatory, the board carries 230 V
6. **Add to Home Assistant** — the device is discovered automatically by the ESPHome integration
7. **Control your radiators** — from the dashboard, automations or the thermostat

---

## Wiring

> ⚠️ **WARNING**: switch off the circuit breaker before any wiring and check for absence of voltage.

The board connects through the 3-pin terminal block (J1). The radiator's pilot wire is the black (sometimes grey) wire leaving the radiator next to live and neutral. It must **never** be connected to neutral or earth.

```
                    Terminal block J1
                   ┌─────┬─────┬─────┐
                   │  L  │  N  │  P  │
                   └──┬──┴──┬──┴──┬──┘
                      │     │     │
                      │     │     └──── Pilot wire to the radiator(s)
                      │     │
                      │     └────────── Neutral (blue)
                      │
                      └──────────────── Live (brown or red)

          From the electrical panel (radiator circuit)
```

Power the board from the **same circuit** as the radiators it drives: the pilot wire signal is referenced to the radiator's neutral.

---

## Schematic

The full schematic is in `hardware/kicad/MaxPilot.kicad_sch` (KiCad 9).

![Schematic](images/MaxPilot.svg)

### Architecture

```
Mains ──► F1 (1 A fuse) ──► RV1 (varistor) ──► PS1 (HLK-PM01) ──► 5 V
   │                                                     │
   │                                              U1 (WeMos D1 Mini)
   │                                               │            │
   │                                           GPIO D3      GPIO D7
   │                                               │            │
   │                                           R1 (570 Ω)   R2 (570 Ω)
   │                                               │            │
   ├─────────────────────────────────────── U2 (MOC3041M)  U3 (MOC3041M)
   │  live                                        │            │
   │                                          D1 (1N4007)  D2 (1N4007)
   │                                          negative       positive
   │                                          half-wave      half-wave
   │                                               └─────┬──────┘
   │                                                     ▼
   └──────────────────────────────────────────►  P (pilot wire)
```

Both opto-triacs sit in parallel between live and the pilot wire, each through its diode. The low-voltage side (5 V, ESP8266) is isolated from mains by the HLK-PM01 module and by the optocouplers.

### Pin Mapping

| GPIO | Function |
|------|----------|
| D3 (GPIO0)  | SSR1 — U2 + D1, negative half-wave (Frost protection, Eco) |
| D7 (GPIO13) | SSR2 — U3 + D2, positive half-wave (Off, Eco) |

The GPIOs drive the optocoupler LEDs with inverted logic (low = on). D3 is an ESP8266 boot-strapping pin and stays high at boot, so the radiator is never switched while the board starts.

---

## Bill of Materials

| Ref | Qty | Value | Description |
|-----|:---:|-------|-------------|
| U1 | 1 | WeMos D1 Mini | ESP8266 microcontroller |
| PS1 | 1 | HLK-PM01 | Isolated AC/DC 5 V power supply |
| U2, U3 | 2 | MOC3041M | Zero-cross opto-triac, DIP-6 — **clip pin 5 before soldering** |
| D1, D2 | 2 | 1N4007 | Half-wave selection diodes |
| R1, R2 | 2 | 560–570 Ω | Axial resistors (opto LED current limit) |
| C1 | 1 | 22 µF 25 V | Ceramic 5 V decoupling capacitor |
| F1 | 1 | 1 A | Mini blade fuse + Keystone 3568 holder |
| RV1 | 1 | 14D431K | 275 V AC varistor |
| J1 | 1 | 3-pin, 7.62 mm pitch | Screw terminal block, e.g. Würth 691311400103, Phoenix MKDS 1,5/3-7,62 |

The BOM exported from KiCad is in `hardware/MaxPilot.csv`.

---

## ESPHome Firmware

The firmware is plain ESPHome configuration, no custom code.

```
esphome/
├── maxpilot_ch1.yaml                   # one board = one file (name, pins, secrets)
├── maxpilot_ch1_with_temp.yaml.example # variant with thermostat
├── secrets.yaml.example
└── common/
    ├── core.yaml             # board, API, OTA, fallback WiFi, diagnostics
    ├── maxpilot.yaml         # pilot wire logic (SSRs + mode selector)
    └── maxpilot_climate.yaml # optional thermostat
```

### 1. Secrets

```bash
cp esphome/secrets.yaml.example esphome/secrets.yaml
# Edit esphome/secrets.yaml: WiFi and API encryption key (openssl rand -base64 32)
```

### 2. Flash

```bash
# First flash (D1 Mini plugged in via USB)
esphome run esphome/maxpilot_ch1.yaml

# Later updates over the air
esphome run esphome/maxpilot_ch1.yaml --device maxpilot-ch1.local
```

For a second board, copy `maxpilot_ch1.yaml` and change `name` and `ch_name`.

### 3. Thermostat (optional)

If a room temperature sensor exists in Home Assistant (Zigbee, BLE, another ESPHome node…), the board can regulate on its own. See `esphome/maxpilot_ch1_with_temp.yaml.example`:

```yaml
substitutions:
  temp_sensor_entity: "sensor.temperature_salon"   # your sensor in Home Assistant

packages:
  core: !include common/core.yaml
  maxpilot: !include common/maxpilot.yaml
  climate: !include common/maxpilot_climate.yaml
```

| Preset | Setpoint | Pilot wire |
|--------|:--------:|-----------------|
| **Confort** | 19 °C | Comfort while cold, Eco once the setpoint is reached |
| **Éco** | 17 °C | same, around 17 °C |
| **Hors-gel** | 7 °C | same, around 7 °C |
| **Absent** | — | Off |

The thermostat always acts through the mode selector, so the state shown in Home Assistant is what is really sent to the radiator.

### 4. Adopt from the ESPHome dashboard

The configuration declares `dashboard_import`: an already-flashed board can be adopted with one click from the ESPHome dashboard ("Adopt"), which pulls the configuration straight from this repository.

---

## Home Assistant Integration

Once flashed, MaxPilot is discovered automatically by the ESPHome integration. You get:

- **Fil Pilote CH1** — mode selector: Confort, Éco, Hors-gel, Arrêt
- **Radiateur CH1** *(if thermostat enabled)* — climate entity with setpoint and presets
- WiFi signal, uptime and version under diagnostics

Example automation:

```yaml
automation:
  - alias: "Radiators - Eco at night"
    triggers:
      - trigger: time
        at: "22:00:00"
    actions:
      - action: select.select_option
        target:
          entity_id: select.maxpilot_ch1_fil_pilote_ch1
        data:
          option: "Éco"
```

---

## PCB Manufacturing

Gerber files ready for JLCPCB, PCBWay, Aisler… are in `hardware/gerber/` (`MaxPilot.zip` has everything). 2-layer, 1.6 mm, 99 × 38 mm; the manufacturer's default options are fine.

| Front | Back |
|:--:|:--:|
| ![PCB Front](images/MaxPilot-pcb-front.svg) | ![PCB Back](images/MaxPilot-pcb-back.svg) |

---

## Enclosure

A 3D-printable enclosure is provided in `hardware/enclosure/` (OpenSCAD source + STL). Print in PLA or PETG, no supports, open face up. The lid has vent slots above the power module and a cutout for the wires on the terminal block side.

![Enclosure](images/enclosure-both.png)

- **PCB screws**: 4 × M2×6 (self-tapping into the bosses)
- **Lid screws**: 4 × M3×13 (self-tapping into the corner pillars)

---

## Safety

> ⚠️ **WARNING: this project involves mains voltage (230 V AC). Risk of fatal electric shock.**
> Always switch off the power before any work. The board must be installed in a closed enclosure, out of reach. You are responsible for the compliance of your installation.

PCB v2.0 meets IPC-2221B and IEC 62368-1 isolation requirements:
- Mains ↔ low-voltage clearance: ≥ 3.0 mm
- Creepage distance: ≥ 5.0 mm
- Mains traces on the back layer only, no vias

---

## Contributing

Build photos, feedback on radiator models, fixes and improvements are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md). Questions go in [Discussions](https://github.com/zefr0g/maxpilot/discussions).

If this project is useful to you, a ⭐ on the repository helps others find it.

---

## Changelog

### v2.1
- Firmware: adopt from the ESPHome dashboard, thermostat driven through the selector, secrets only in the device file
- Enclosure v2.4: corner lid pillars, straight PCB drop-in, vent slots
- Docs: half-wave polarity corrected (Frost protection = negative, Off = positive), cost, comparison
- GitHub Actions CI: ESPHome validation and KiCad DRC

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
