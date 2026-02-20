# MaxPilot

**FR** | Carte de contrôle "fil pilote" pour radiateurs, basée sur un ESP D1 Mini et ESPHome.
**EN** | "Fil pilote" radiator controller board, based on an ESP D1 Mini and ESPHome.

---

## Sommaire / Table of Contents

- [Principe du fil pilote / How "Fil Pilote" Works](#principe-du-fil-pilote--how-fil-pilote-works)
- [Fonctionnalités / Features](#fonctionnalités--features)
- [Schéma / Schematic](#schéma--schematic)
- [Nomenclature / Bill of Materials](#nomenclature--bill-of-materials)
- [Configuration ESPHome](#configuration-esphome)
- [Fabrication du PCB / PCB Manufacturing](#fabrication-du-pcb--pcb-manufacturing)
- [Sécurité / Safety](#sécurité--safety)
- [Licence / License](#licence--license)

---

## Principe du fil pilote / How "Fil Pilote" Works

**FR**

Le **fil pilote** est un protocole de commande utilisé en France pour contrôler les radiateurs électriques. Un signal 230V AC est envoyé sur un fil dédié (le fil pilote) pour indiquer au radiateur le mode de fonctionnement souhaité. Le principe repose sur la forme du signal AC envoyé :

| Ordre / Mode | Signal sur le fil pilote | SSR1 | SSR2 |
|---|---|:---:|:---:|
| **Confort** (pleine chauffe) | Pas de signal (fil ouvert) | OFF | OFF |
| **Éco** (réduit) | Sinusoïde complète 230V | ON | ON |
| **Hors-gel** | Alternance positive uniquement (+) | ON | OFF |
| **Arrêt** | Alternance négative uniquement (−) | OFF | ON |

```
Confort (pas de signal)         Éco (sinusoïde complète)
          ╭─╮                         ╭─╮
         │   │                       │   │
 ────────│───│────────       ────────│───│────────
         │   │                       │   │
          ╰─╯                         ╰─╯
   SSR1: OFF  SSR2: OFF        SSR1: ON  SSR2: ON

Hors-gel (alternance +)         Arrêt (alternance −)
          ╭─╮
         │   │
 ────────│───│────────       ────────────────────
                                     │   │
                                      ╰─╯
   SSR1: ON  SSR2: OFF        SSR1: OFF  SSR2: ON
```

Chaque canal de MaxPilot utilise **deux optocoupleurs MOC3041M** avec des **diodes 1N4007** pour laisser passer sélectivement l'alternance positive, l'alternance négative, les deux, ou aucune. Les MOC3041M intègrent un détecteur de passage par zéro pour commuter proprement sans générer de parasites.

---

**EN**

**Fil pilote** ("pilot wire") is a control protocol used in France to manage electric radiators. A 230V AC signal is sent on a dedicated wire to tell the radiator which operating mode to use. The principle relies on the shape of the AC waveform sent:

| Mode | Signal on pilot wire | SSR1 | SSR2 |
|---|---|:---:|:---:|
| **Comfort** (full heat) | No signal (open wire) | OFF | OFF |
| **Eco** (reduced) | Full 230V sine wave | ON | ON |
| **Frost protection** | Positive half-wave only (+) | ON | OFF |
| **Off** | Negative half-wave only (−) | OFF | ON |

Each MaxPilot channel uses **two MOC3041M optocouplers** with **1N4007 diodes** to selectively pass the positive half-wave, the negative half-wave, both, or neither. The MOC3041M includes built-in zero-cross detection to switch cleanly without generating electrical noise.

---

## Fonctionnalités / Features

**FR**
- 2 canaux indépendants de contrôle fil pilote
- Microcontrôleur ESP8266 (WeMos D1 Mini) avec WiFi intégré
- Compatible ESPHome et Home Assistant
- Alimentation AC/DC isolée (HLK-PM01, 5V)
- Protection contre les surtensions (varistance)
- Optocoupleurs à passage par zéro (MOC3041M) pour une commutation propre
- Fusible de protection 1A

**EN**
- 2 independent fil pilote control channels
- ESP8266 microcontroller (WeMos D1 Mini) with built-in WiFi
- Compatible with ESPHome and Home Assistant
- Isolated AC/DC power supply (HLK-PM01, 5V)
- Surge protection (varistor)
- Zero-cross optocouplers (MOC3041M) for clean switching
- 1A fuse protection

---

## Schéma / Schematic

**FR** | Le schéma complet se trouve dans `MaxPilot.kicad_sch` (KiCad 9).
**EN** | The full schematic is in `MaxPilot.kicad_sch` (KiCad 9).

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
| D7   | SSR2 — Optocoupleur U3 (alternance − / negative half-wave) |

---

## Nomenclature / Bill of Materials

| Réf | Valeur | Boîtier / Footprint | Qté | Description |
|-----|--------|----------------------|-----|-------------|
| F1 | 1A | Fuseholder_Blade_Mini_Keystone_3568 | 1 | Fusible / Fuse |
| C1 | 22µF | C_Disc_D8.0mm_W2.5mm_P5.00mm | 1 | Condensateur / Capacitor |
| U1 | WeMos D1 Mini | WEMOS_D1_mini_light | 1 | Microcontrôleur ESP8266 |
| U2, U3 | MOC3041M | DIP-6_W7.62mm | 2 | Optocoupleur triac / Opto-triac |
| R1, R2 | 570Ω | R_Axial_DIN0207 | 2 | Résistances / Resistors |
| D1, D2 | 1N4007 | D_DO-41_SOD81 | 2 | Diodes de protection / Protection diodes |
| RV1 | Varistance | RV_Disc_D12mm | 1 | Protection surtension / Surge protection |
| PS1 | HLK-PM01 | Converter_ACDC_HiLink_HLK-PMxx | 1 | Alimentation AC/DC 5V / AC-DC 5V PSU |
| J1 | Bornier 3 pts | TerminalBlock_bornier-3_P5.08mm | 1 | Connecteur / Terminal block |

---

## Configuration ESPHome

### 1. Préparer les secrets / Prepare secrets

```bash
cp secrets.yaml.example secrets.yaml
# Éditez secrets.yaml avec vos identifiants / Edit secrets.yaml with your credentials
```

### 2. Configuration par canal / Per-channel configuration

Voir `maxpilot_ch1.yaml` pour un exemple de configuration :

```yaml
substitutions:
  name: maxpilot_ch1
  ch_name: "CH1"
  ssr1_pin: D3
  ssr2_pin: D7

packages:
  core: !include common/core.yaml
  wifi: !include common/wifi.yaml
  maxpilot: !include common/maxpilot.yaml

esphome:
  name: ${name}
```

**FR** | Les fichiers `common/` contiennent la configuration partagée (WiFi, capteurs, logique fil pilote). Adaptez-les à votre installation.
**EN** | The `common/` files contain shared configuration (WiFi, sensors, fil pilote logic). Adapt them to your setup.

### 3. Flasher / Flash

```bash
esphome run maxpilot_ch1.yaml
```

---

## Fabrication du PCB / PCB Manufacturing

**FR** | Les fichiers Gerber sont prêts à l'envoi chez un fabricant (JLCPCB, PCBWay, etc.).
**EN** | Gerber files are ready to send to a manufacturer (JLCPCB, PCBWay, etc.).

| Face avant / Front | Face arrière / Back |
|:--:|:--:|
| ![PCB Front](images/MaxPilot-pcb-front.svg) | ![PCB Back](images/MaxPilot-pcb-back.svg) |

Fichiers inclus / Included files:
- `MaxPilot-F_Cu.gbr` / `MaxPilot-B_Cu.gbr` — Cuivre / Copper layers
- `MaxPilot-F_Mask.gbr` / `MaxPilot-B_Mask.gbr` — Masque de soudure / Solder mask
- `MaxPilot-F_Silkscreen.gbr` / `MaxPilot-B_Silkscreen.gbr` — Sérigraphie / Silkscreen
- `MaxPilot-Edge_Cuts.gbr` — Contour de la carte / Board outline
- `MaxPilot-PTH.drl` / `MaxPilot-NPTH.drl` — Perçages / Drill files
- `MaxPilot-top.pos` / `MaxPilot-bottom.pos` — Positions des composants / Component placement

---

## Sécurité / Safety

> **FR** | **ATTENTION : Ce projet implique des tensions secteur (230V AC). L'installation et la manipulation doivent être effectuées par une personne qualifiée. Risque d'électrocution mortelle. Coupez toujours le courant avant toute intervention.**

> **EN** | **WARNING: This project involves mains voltage (230V AC). Installation and handling must be performed by a qualified person. Risk of fatal electric shock. Always disconnect power before any work.**

---

## Licence / License

Ce projet est distribué sous la licence **CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S-2.0)**.

This project is licensed under the **CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S-2.0)**.

Voir / See [LICENSE](LICENSE) pour le texte complet / for the full text.
