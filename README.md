# MaxPilot

![MaxPilot - Photo de la carte assemblée / Assembled board photo](images/photo.jpg)

**FR** | MaxPilot est une carte open-source qui permet de **contrôler vos radiateurs électriques depuis votre téléphone ou votre ordinateur**, via Home Assistant. Elle se branche sur le fil pilote de vos radiateurs et commande le mode de chauffage (Confort, Éco, Hors-gel, Arrêt) en WiFi. Plus besoin de programmateur mural : vous gérez tout depuis votre domotique. Conçue autour de composants **peu coûteux et facilement disponibles** (WeMos D1 Mini ~3 €, optocoupleurs, MOSFETs), elle est accessible à tout amateur d'électronique.

**EN** | MaxPilot is an open-source board that lets you **control your electric radiators from your phone or computer**, via Home Assistant. It connects to your radiators' "fil pilote" (pilot wire) and sets the heating mode (Comfort, Eco, Frost protection, Off) over WiFi. No more wall-mounted programmer: manage everything from your smart home. Built around **low-cost, widely available components** (WeMos D1 Mini ~€3, optocouplers, MOSFETs), it is accessible to any electronics hobbyist.

---

## Sommaire / Table of Contents

- [C'est quoi le fil pilote ? / What is "Fil Pilote"?](#cest-quoi-le-fil-pilote---what-is-fil-pilote)
- [Fonctionnalités / Features](#fonctionnalités--features)
- [Contrôle climatique / Climate Control](#4-contrôle-climatique-optionnel--climate-control-optional)
- [Démarrage rapide / Quick Start](#démarrage-rapide--quick-start)
- [Câblage / Wiring](#câblage--wiring)
- [Schéma / Schematic](#schéma--schematic)
- [Nomenclature / Bill of Materials](#nomenclature--bill-of-materials)
- [Configuration ESPHome](#configuration-esphome)
- [Intégration Home Assistant](#intégration-home-assistant--home-assistant-integration)
- [Fabrication du PCB / PCB Manufacturing](#fabrication-du-pcb--pcb-manufacturing)
- [Sécurité / Safety](#sécurité--safety)
- [Licence / License](#licence--license)

---

## C'est quoi le fil pilote ? / What is "Fil Pilote"?

**FR**

Le **fil pilote** est un système utilisé en France pour piloter les radiateurs électriques. En plus des fils d'alimentation (phase + neutre), un fil supplémentaire — le fil pilote — transporte un signal de commande 230V AC. Le radiateur adapte son fonctionnement selon la **forme du signal** qu'il reçoit :

| Mode | Ce que fait le radiateur | Signal sur le fil pilote | SSR1 | SSR2 |
|---|---|---|:---:|:---:|
| **Confort** | Chauffe à la température du thermostat | Pas de signal (fil ouvert) | OFF | OFF |
| **Éco** | Réduit la température de ~3-4°C | Sinusoïde complète 230V | ON | ON |
| **Hors-gel** | Maintient ~7°C minimum | Alternance positive uniquement | ON | OFF |
| **Arrêt** | Radiateur éteint | Alternance négative uniquement | OFF | ON |

```
Confort (pas de signal)            Éco (sinusoïde complète)

                                        ╭──╮      ╭──╮
                                       ╱    ╲    ╱    ╲
 ──────────────────────        ───────╱──────╲──╱──────╲───
                                    ╲    ╱    ╲    ╱
                                     ╰──╯      ╰──╯

   SSR1: OFF  SSR2: OFF           SSR1: ON   SSR2: ON


Hors-gel (alternance +)            Arrêt (alternance −)

      ╭──╮      ╭──╮
     ╱    ╲    ╱    ╲
 ───╱──────╲──╱──────╲───     ─────────────────────────────
                                    ╲    ╱    ╲    ╱
                                     ╰──╯      ╰──╯

   SSR1: ON   SSR2: OFF           SSR1: OFF  SSR2: ON
```

MaxPilot utilise **deux optocoupleurs MOC3041M** par canal, avec des **diodes 1N4007**, pour laisser passer sélectivement l'alternance positive, négative, les deux, ou aucune. Les MOC3041M intègrent un détecteur de passage par zéro pour commuter proprement sans parasites.

---

**EN**

**Fil pilote** ("pilot wire") is a system used in France to control electric radiators. In addition to power wires (live + neutral), an extra wire — the pilot wire — carries a 230V AC control signal. The radiator adjusts its operation based on the **shape of the signal** it receives:

| Mode | What the radiator does | Signal on pilot wire | SSR1 | SSR2 |
|---|---|---|:---:|:---:|
| **Comfort** | Heats to thermostat setpoint | No signal (open wire) | OFF | OFF |
| **Eco** | Reduces temperature by ~3-4°C | Full 230V sine wave | ON | ON |
| **Frost protection** | Maintains ~7°C minimum | Positive half-wave only | ON | OFF |
| **Off** | Radiator off | Negative half-wave only | OFF | ON |

MaxPilot uses **two MOC3041M optocouplers** per channel, with **1N4007 diodes**, to selectively pass the positive half-wave, the negative half-wave, both, or neither. The MOC3041M includes built-in zero-cross detection to switch cleanly without electrical noise.

---

## Fonctionnalités / Features

**FR**
- Microcontrôleur ESP8266 (WeMos D1 Mini) avec WiFi intégré
- Compatible ESPHome et Home Assistant
- Alimentation AC/DC isolée (HLK-PM01, 5V)
- Protection contre les surtensions (varistance)
- Optocoupleurs à passage par zéro (MOC3041M) pour une commutation propre
- Fusible de protection 1A
- Thermostat intégré avec capteur de température externe (optionnel)

**EN**
- ESP8266 microcontroller (WeMos D1 Mini) with built-in WiFi
- Compatible with ESPHome and Home Assistant
- Isolated AC/DC power supply (HLK-PM01, 5V)
- Surge protection (varistor)
- Zero-cross optocouplers (MOC3041M) for clean switching
- 1A fuse protection
- Built-in thermostat with external temperature sensor (optional)

---

## Démarrage rapide / Quick Start

**FR**

1. **Fabriquer ou commander le PCB** — envoyez les fichiers Gerber à un fabricant (JLCPCB, PCBWay...)
2. **Souder les composants** — voir la [nomenclature](#nomenclature--bill-of-materials) ci-dessous
3. **Flasher le firmware** — branchez le D1 Mini en USB et lancez `esphome run esphome/maxpilot_ch1.yaml`
4. **Câbler la carte** — branchez phase, neutre et fil pilote sur le bornier (voir [câblage](#câblage--wiring))
5. **Ajouter à Home Assistant** — le périphérique apparaît automatiquement dans Home Assistant via l'intégration ESPHome
6. **Piloter vos radiateurs** — commandez les modes depuis le tableau de bord ou via des automatisations

**EN**

1. **Manufacture or order the PCB** — send Gerber files to a manufacturer (JLCPCB, PCBWay...)
2. **Solder the components** — see the [bill of materials](#nomenclature--bill-of-materials) below
3. **Flash the firmware** — plug the D1 Mini via USB and run `esphome run esphome/maxpilot_ch1.yaml`
4. **Wire the board** — connect live, neutral and pilot wire to the terminal block (see [wiring](#câblage--wiring))
5. **Add to Home Assistant** — the device appears automatically in Home Assistant via ESPHome integration
6. **Control your radiators** — set modes from the dashboard or through automations

---

## Câblage / Wiring

> **ATTENTION / WARNING** : Coupez le courant au disjoncteur avant tout câblage ! / Switch off the circuit breaker before any wiring!

**FR** | La carte se branche sur le bornier 3 points (J1). Le fil pilote de votre radiateur est le fil noir (ou parfois gris) présent dans la gaine électrique de votre radiateur.

**EN** | The board connects via the 3-pin terminal block (J1). The pilot wire on your radiator is the black (or sometimes grey) wire in your radiator's electrical conduit.

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

## Schéma / Schematic

**FR** | Le schéma complet se trouve dans `hardware/kicad/MaxPilot.kicad_sch` (KiCad 9).
**EN** | The full schematic is in `hardware/kicad/MaxPilot.kicad_sch` (KiCad 9).

![Schéma / Schematic](images/MaxPilot.svg)

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

### Brochage / Pin Mapping

| GPIO | Fonction / Function |
|------|---------------------|
| D3   | SSR1 — Optocoupleur U2 (alternance + / positive half-wave) |
| D7   | SSR2 — Optocoupleur U3 (alternance - / negative half-wave) |

---

## Nomenclature / Bill of Materials

| Réf | Valeur | Boîtier / Footprint | Qté | Description |
|-----|--------|----------------------|-----|-------------|
| F1 | 1A | Fuseholder_Blade_Mini_Keystone_3568 | 1 | Fusible / Fuse |
| C1 | 22µF 25V céramique | C_Disc_D8.0mm_W2.5mm_P5.00mm | 1 | Condensateur céramique / Ceramic capacitor |
| U1 | WeMos D1 Mini | WEMOS_D1_mini_light | 1 | Microcontrôleur ESP8266 |
| U2, U3 | MOC3041M | MOC3041M_DIP6_W7.62mm_NC5 | 2 | Optocoupleur triac / Opto-triac (pin 5 NC — à couper / clip before soldering) |
| R1, R2 | 570Ω | R_Axial_DIN0207 | 2 | Résistances / Resistors |
| D1, D2 | 1N4007 | D_DO-41_SOD81 | 2 | Diodes de protection / Protection diodes |
| RV1 | MOV 275V (14D431K) | RV_Disc_D12mm | 1 | Varistance 275V / 275V Varistor (surge protection) |
| PS1 | HLK-PM01 | Converter_ACDC_HiLink_HLK-PMxx | 1 | Alimentation AC/DC 5V / AC-DC 5V PSU |
| J1 | Bornier 3 pts 7.62mm | TerminalBlock_Generic_1x03_P7.62mm_Horizontal | 1 | Connecteur / Terminal block (ex: Würth 691311400103, Phoenix MKDS 1,5/3-7,62) |

---

## Configuration ESPHome

### 1. Préparer les secrets / Prepare secrets

```bash
cp esphome/secrets.yaml.example esphome/secrets.yaml
# Éditez esphome/secrets.yaml avec vos identifiants / Edit esphome/secrets.yaml with your credentials
```

### 2. Configuration par canal / Per-channel configuration

Voir `esphome/maxpilot_ch1.yaml` pour un exemple de configuration :

```yaml
substitutions:
  name: maxpilot_ch1
  ch_name: "CH1"
  ssr1_pin: D3
  ssr2_pin: D7
  # Capteur de température optionnel / Optional temperature sensor
  temp_sensor_entity: "none"       # ou / or "sensor.temperature_salon"
  temp_sensor_internal: "true"     # "false" pour activer / to enable

packages:
  core: !include common/core.yaml
  wifi: !include common/wifi.yaml
  maxpilot: !include common/maxpilot.yaml

esphome:
  name: ${name}
```

**FR** | Les fichiers `esphome/common/` contiennent la configuration partagée (WiFi, capteurs, logique fil pilote). Adaptez-les à votre installation.
**EN** | The `esphome/common/` files contain shared configuration (WiFi, sensors, fil pilote logic). Adapt them to your setup.

### 3. Capteur de température (optionnel) / Temperature sensor (optional)

**FR** | Si vous avez un capteur de température dans la pièce (Zigbee, BLE, WiFi...), vous pouvez l'importer dans MaxPilot depuis Home Assistant. La température sera affichée à côté du sélecteur fil pilote. Modifiez les substitutions dans votre fichier de configuration :

**EN** | If you have a room temperature sensor (Zigbee, BLE, WiFi...), you can import it into MaxPilot from Home Assistant. The temperature will be displayed alongside the fil pilote selector. Edit the substitutions in your config file:

```yaml
substitutions:
  temp_sensor_entity: "sensor.temperature_salon"  # votre entity ID HA / your HA entity ID
  temp_sensor_internal: "false"
```

**FR** | Voir `esphome/maxpilot_ch1_with_temp.yaml.example` pour un exemple complet.
**EN** | See `esphome/maxpilot_ch1_with_temp.yaml.example` for a complete example.

### 4. Contrôle climatique (optionnel) / Climate control (optional)

**FR** | Si un capteur de température est configuré, vous pouvez ajouter un **thermostat intégré** qui bascule automatiquement entre Confort et Éco selon la température de la pièce. Ajoutez le package `maxpilot_climate.yaml` :

**EN** | If a temperature sensor is configured, you can add a **built-in thermostat** that automatically switches between Comfort and Eco based on room temperature. Add the `maxpilot_climate.yaml` package:

```yaml
packages:
  core: !include common/core.yaml
  wifi: !include common/wifi.yaml
  maxpilot: !include common/maxpilot.yaml
  climate: !include common/maxpilot_climate.yaml
```

**FR** | Le thermostat expose une entité **climate** dans Home Assistant avec 4 presets :

**EN** | The thermostat exposes a **climate** entity in Home Assistant with 4 presets:

| Preset | Consigne / Setpoint | Mode fil pilote |
|--------|:-------------------:|-----------------|
| **Confort** | 19°C | Confort (chauffe) |
| **Éco** | 17°C | Éco (réduit) |
| **Hors-gel** | 7°C | Hors-gel |
| **Absent** | — | Arrêt |

**FR** | Quand la température est inférieure à la consigne, le thermostat passe en Confort (chauffe). Quand la consigne est atteinte, il passe en Éco (réduit). Le sélecteur fil pilote reste synchronisé avec le thermostat.

**EN** | When the temperature is below the setpoint, the thermostat switches to Comfort (heating). When the setpoint is reached, it switches to Eco (reduced). The fil pilote selector stays synchronized with the thermostat.

### 5. Flasher / Flash

**FR** | Branchez le D1 Mini en USB sur votre ordinateur, puis :
**EN** | Plug the D1 Mini via USB to your computer, then:

```bash
# Premier flash (USB obligatoire) / First flash (USB required)
esphome run esphome/maxpilot_ch1.yaml

# Mises à jour suivantes (via WiFi OTA) / Subsequent updates (via WiFi OTA)
esphome run esphome/maxpilot_ch1.yaml --device maxpilot_ch1.local
```

---

## Intégration Home Assistant / Home Assistant Integration

**FR**

Une fois le firmware flashé et la carte alimentée, le périphérique MaxPilot apparaît automatiquement dans Home Assistant via la découverte ESPHome. Vous trouverez :

- **Fil Pilote CH1** — sélecteur de mode avec 4 options : Confort, Éco, Hors-gel, Arrêt
- **Radiateur CH1** *(si climate activé)* — thermostat avec consigne de température et presets

Les interrupteurs SSR sont cachés (marqués `internal`) — la logique fil pilote est gérée automatiquement par le sélecteur ou le thermostat. Le mode choisi est sauvegardé en mémoire flash et restauré après un redémarrage.

Exemple d'automatisation pour passer en mode Éco la nuit :

```yaml
automation:
  - alias: "Radiateur salon - Éco la nuit"
    trigger:
      - platform: time
        at: "22:00:00"
    action:
      - service: select.select_option
        target:
          entity_id: select.fil_pilote_ch1
        data:
          option: "Éco"

  - alias: "Radiateur salon - Confort le matin"
    trigger:
      - platform: time
        at: "06:30:00"
    action:
      - service: select.select_option
        target:
          entity_id: select.fil_pilote_ch1
        data:
          option: "Confort"
```

---

**EN**

Once the firmware is flashed and the board is powered, the MaxPilot device appears automatically in Home Assistant via ESPHome discovery. You will find:

- **Fil Pilote CH1** — mode selector with 4 options: Confort, Éco, Hors-gel, Arrêt
- **Radiateur CH1** *(if climate enabled)* — thermostat with temperature setpoint and presets

The SSR switches are hidden (marked `internal`) — the fil pilote logic is handled automatically by the selector or thermostat. The chosen mode is saved to flash memory and restored after a reboot.

Example automation to switch to Eco mode at night:

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

  - alias: "Living room radiator - Comfort in the morning"
    trigger:
      - platform: time
        at: "06:30:00"
    action:
      - service: select.select_option
        target:
          entity_id: select.fil_pilote_ch1
        data:
          option: "Confort"
```

---

## Fabrication du PCB / PCB Manufacturing

**FR** | Les fichiers Gerber sont prêts à l'envoi chez un fabricant (JLCPCB, PCBWay, etc.).
**EN** | Gerber files are ready to send to a manufacturer (JLCPCB, PCBWay, etc.).

| Face avant / Front | Face arrière / Back |
|:--:|:--:|
| ![PCB Front](images/MaxPilot-pcb-front.svg) | ![PCB Back](images/MaxPilot-pcb-back.svg) |

Fichiers inclus dans `hardware/gerber/` / Included files in `hardware/gerber/`:
- `MaxPilot-F_Cu.gbr` / `MaxPilot-B_Cu.gbr` — Cuivre / Copper layers
- `MaxPilot-F_Mask.gbr` / `MaxPilot-B_Mask.gbr` — Masque de soudure / Solder mask
- `MaxPilot-F_Silkscreen.gbr` / `MaxPilot-B_Silkscreen.gbr` — Sérigraphie / Silkscreen
- `MaxPilot-Edge_Cuts.gbr` — Contour de la carte / Board outline
- `MaxPilot-PTH.drl` / `MaxPilot-NPTH.drl` — Perçages / Drill files

Fichiers d'assemblage dans `hardware/` / Assembly files in `hardware/`:
- `MaxPilot-top.pos` / `MaxPilot-bottom.pos` — Positions des composants / Component placement
- `MaxPilot.csv` — Nomenclature / Bill of materials

---

## Sécurité / Safety

> **FR** | **ATTENTION : Ce projet implique des tensions secteur (230V AC). L'installation et la manipulation doivent être effectuées par une personne qualifiée. Risque d'électrocution mortelle. Coupez toujours le courant avant toute intervention. La carte doit être installée dans un boîtier fermé et isolé.**

> **EN** | **WARNING: This project involves mains voltage (230V AC). Installation and handling must be performed by a qualified person. Risk of fatal electric shock. Always disconnect power before any work. The board must be installed in a closed, insulated enclosure.**

**FR** | Le PCB v2.0 respecte les distances d'isolement IPC-2221B et IEC 62368-1 pour 230V AC (clearance ≥ 3,0 mm mains↔BT, creepage ≥ 5,0 mm). Les règles DRC sont dans `hardware/kicad/MaxPilot.kicad_dru`.

**EN** | PCB v2.0 meets IPC-2221B and IEC 62368-1 isolation distances for 230V AC (clearance ≥ 3.0 mm mains↔LV, creepage ≥ 5.0 mm). DRC rules are in `hardware/kicad/MaxPilot.kicad_dru`.

---

## Versions / Changelog

### v2.0 — PCB redesign (sécurité / safety)

**FR**

Refonte complète du PCB pour conformité aux normes de sécurité secteur :

- **Distances d'isolement conformes IPC-2221B / IEC 62368-1** — clearance mains↔BT ≥ 3,0 mm, clearance mains↔mains ≥ 2,5 mm, creepage ≥ 5,0 mm (règles DRC dans `MaxPilot.kicad_dru`)
- **Bornier J1 remplacé par pas 7,62 mm** — le bornier 5,08 mm de v1 ne respectait pas les distances entre LINE/NEUT/PILOT
- **Empreinte MOC3041M corrigée** — pin 5 (substrat triac, DO NOT CONNECT) remplacé par trou mécanique NPTH, à couper avant soudure
- **Routage mains en 2 mm** — toutes les pistes secteur en 2 mm de large

**EN**

Full PCB redesign for mains safety standard compliance:

- **IPC-2221B / IEC 62368-1 compliant clearances** — mains↔LV clearance ≥ 3.0 mm, mains↔mains clearance ≥ 2.5 mm, creepage ≥ 5.0 mm (DRC rules in `MaxPilot.kicad_dru`)
- **J1 terminal block replaced with 7.62 mm pitch** — the v1 5.08 mm terminal block did not meet LINE/NEUT/PILOT spacing requirements
- **MOC3041M footprint corrected** — pin 5 (TRIAC substrate, DO NOT CONNECT) replaced with NPTH mechanical hole; clip before soldering
- **Mains traces at 2 mm width** — all mains-side traces are 2 mm wide

### v1.0 — Initial release

**FR** | Premier design fonctionnel, distribué sur HACS. Problèmes de distances d'isolement corrigés en v2.

**EN** | First working design, published on HACS. Clearance issues fixed in v2.

---

## Licence / License

Ce projet est distribué sous la licence **CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S-2.0)**.

This project is licensed under the **CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S-2.0)**.

Voir / See [LICENSE](LICENSE) pour le texte complet / for the full text.
