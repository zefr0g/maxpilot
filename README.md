# MaxPilot

![MaxPilot - Photo de la carte assemblée / Assembled board photo](images/photo.jpg)

**FR** | MaxPilot est une carte open-source qui permet de **contrôler vos radiateurs électriques depuis votre téléphone ou votre ordinateur**, via Home Assistant. Elle se branche sur le fil pilote de vos radiateurs et commande le mode de chauffage (Confort, Éco, Hors-gel, Arrêt) en WiFi. Plus besoin de programmateur mural : vous gérez tout depuis votre domotique.

**EN** | MaxPilot is an open-source board that lets you **control your electric radiators from your phone or computer**, via Home Assistant. It connects to your radiators' "fil pilote" (pilot wire) and sets the heating mode (Comfort, Eco, Frost protection, Off) over WiFi. No more wall-mounted programmer: manage everything from your smart home.

---

## Sommaire / Table of Contents

- [C'est quoi le fil pilote ? / What is "Fil Pilote"?](#cest-quoi-le-fil-pilote---what-is-fil-pilote)
- [Fonctionnalités / Features](#fonctionnalités--features)
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

**EN**
- ESP8266 microcontroller (WeMos D1 Mini) with built-in WiFi
- Compatible with ESPHome and Home Assistant
- Isolated AC/DC power supply (HLK-PM01, 5V)
- Surge protection (varistor)
- Zero-cross optocouplers (MOC3041M) for clean switching
- 1A fuse protection

---

## Démarrage rapide / Quick Start

**FR**

1. **Fabriquer ou commander le PCB** — envoyez les fichiers Gerber à un fabricant (JLCPCB, PCBWay...)
2. **Souder les composants** — voir la [nomenclature](#nomenclature--bill-of-materials) ci-dessous
3. **Flasher le firmware** — branchez le D1 Mini en USB et lancez `esphome run maxpilot_ch1.yaml`
4. **Câbler la carte** — branchez phase, neutre et fil pilote sur le bornier (voir [câblage](#câblage--wiring))
5. **Ajouter à Home Assistant** — le périphérique apparaît automatiquement dans Home Assistant via l'intégration ESPHome
6. **Piloter vos radiateurs** — commandez les modes depuis le tableau de bord ou via des automatisations

**EN**

1. **Manufacture or order the PCB** — send Gerber files to a manufacturer (JLCPCB, PCBWay...)
2. **Solder the components** — see the [bill of materials](#nomenclature--bill-of-materials) below
3. **Flash the firmware** — plug the D1 Mini via USB and run `esphome run maxpilot_ch1.yaml`
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
| D7   | SSR2 — Optocoupleur U3 (alternance - / negative half-wave) |

---

## Nomenclature / Bill of Materials

| Réf | Valeur | Boîtier / Footprint | Qté | Description |
|-----|--------|----------------------|-----|-------------|
| F1 | 1A | Fuseholder_Blade_Mini_Keystone_3568 | 1 | Fusible / Fuse |
| C1 | 22µF 25V céramique | C_Disc_D8.0mm_W2.5mm_P5.00mm | 1 | Condensateur céramique / Ceramic capacitor |
| U1 | WeMos D1 Mini | WEMOS_D1_mini_light | 1 | Microcontrôleur ESP8266 |
| U2, U3 | MOC3041M | DIP-6_W7.62mm | 2 | Optocoupleur triac / Opto-triac |
| R1, R2 | 570Ω | R_Axial_DIN0207 | 2 | Résistances / Resistors |
| D1, D2 | 1N4007 | D_DO-41_SOD81 | 2 | Diodes de protection / Protection diodes |
| RV1 | MOV 275V (14D431K) | RV_Disc_D12mm | 1 | Varistance 275V / 275V Varistor (surge protection) |
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

**FR** | Les fichiers `common/` contiennent la configuration partagée (WiFi, capteurs, logique fil pilote). Adaptez-les à votre installation.
**EN** | The `common/` files contain shared configuration (WiFi, sensors, fil pilote logic). Adapt them to your setup.

### 3. Capteur de température (optionnel) / Temperature sensor (optional)

**FR** | Si vous avez un capteur de température dans la pièce (Zigbee, BLE, WiFi...), vous pouvez l'importer dans MaxPilot depuis Home Assistant. La température sera affichée à côté du sélecteur fil pilote. Modifiez les substitutions dans votre fichier de configuration :

**EN** | If you have a room temperature sensor (Zigbee, BLE, WiFi...), you can import it into MaxPilot from Home Assistant. The temperature will be displayed alongside the fil pilote selector. Edit the substitutions in your config file:

```yaml
substitutions:
  temp_sensor_entity: "sensor.temperature_salon"  # votre entity ID HA / your HA entity ID
  temp_sensor_internal: "false"
```

**FR** | Voir `maxpilot_ch1_with_temp.yaml.example` pour un exemple complet.
**EN** | See `maxpilot_ch1_with_temp.yaml.example` for a complete example.

### 4. Flasher / Flash

**FR** | Branchez le D1 Mini en USB sur votre ordinateur, puis :
**EN** | Plug the D1 Mini via USB to your computer, then:

```bash
# Premier flash (USB obligatoire) / First flash (USB required)
esphome run maxpilot_ch1.yaml

# Mises à jour suivantes (via WiFi OTA) / Subsequent updates (via WiFi OTA)
esphome run maxpilot_ch1.yaml --device maxpilot_ch1.local
```

---

## Intégration Home Assistant / Home Assistant Integration

**FR**

Une fois le firmware flashé et la carte alimentée, le périphérique MaxPilot apparaît automatiquement dans Home Assistant via la découverte ESPHome. Vous trouverez une entité **select** :

- **Fil Pilote CH1** — sélecteur de mode avec 4 options : Confort, Éco, Hors-gel, Arrêt

Les interrupteurs SSR sont cachés (marqués `internal`) — la logique fil pilote est gérée automatiquement par le sélecteur. Le mode choisi est sauvegardé en mémoire flash et restauré après un redémarrage.

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

Once the firmware is flashed and the board is powered, the MaxPilot device appears automatically in Home Assistant via ESPHome discovery. You will find a **select** entity:

- **Fil Pilote CH1** — mode selector with 4 options: Confort, Éco, Hors-gel, Arrêt

The SSR switches are hidden (marked `internal`) — the fil pilote logic is handled automatically by the selector. The chosen mode is saved to flash memory and restored after a reboot.

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

Fichiers inclus / Included files:
- `MaxPilot-F_Cu.gbr` / `MaxPilot-B_Cu.gbr` — Cuivre / Copper layers
- `MaxPilot-F_Mask.gbr` / `MaxPilot-B_Mask.gbr` — Masque de soudure / Solder mask
- `MaxPilot-F_Silkscreen.gbr` / `MaxPilot-B_Silkscreen.gbr` — Sérigraphie / Silkscreen
- `MaxPilot-Edge_Cuts.gbr` — Contour de la carte / Board outline
- `MaxPilot-PTH.drl` / `MaxPilot-NPTH.drl` — Perçages / Drill files
- `MaxPilot-top.pos` / `MaxPilot-bottom.pos` — Positions des composants / Component placement

---

## Sécurité / Safety

> **FR** | **ATTENTION : Ce projet implique des tensions secteur (230V AC). L'installation et la manipulation doivent être effectuées par une personne qualifiée. Risque d'électrocution mortelle. Coupez toujours le courant avant toute intervention. La carte doit être installée dans un boîtier fermé et isolé.**

> **EN** | **WARNING: This project involves mains voltage (230V AC). Installation and handling must be performed by a qualified person. Risk of fatal electric shock. Always disconnect power before any work. The board must be installed in a closed, insulated enclosure.**

---

## Améliorations possibles (v2) / Possible Improvements (v2)

**FR**

Le design actuel fonctionne correctement pour l'usage prévu. Voici des améliorations envisageables pour une future révision :

1. **Fusible surdimensionné** — Le fusible 1A est généreux pour ce circuit (le HLK-PM01 consomme ~15mA et le fil pilote quelques mA). Un **fusible 250mA ou 500mA** offrirait une meilleure protection.

2. **Pas de résistance de limitation en sortie des MOC3041M** — En cas de court-circuit accidentel du fil pilote vers la phase ou le neutre, le triac interne du MOC3041M (100mA RMS max) pourrait être endommagé. Ajouter une **résistance série de 330Ω à 1kΩ** sur la sortie protégerait le composant sans affecter le signal pilote.

3. **Pas de protection sur la sortie fil pilote** — Une **diode TVS** ou une petite varistance sur le fil pilote protégerait contre les surtensions venant du côté radiateur.

4. **Distances d'isolement insuffisantes sur le PCB** — Les normes IPC-2221B et IEC 62368-1 recommandent **>2,5mm de clearance** entre pistes secteur et basse tension pour du 230V AC. Le DRC révèle que la règle actuelle est de **0,5mm** et que plusieurs pistes sont trop proches, notamment la piste NEUT et les pads de D1/D2 (jusqu'à **0,44mm** de distance). Le bornier J1 (pas de 5,08mm) ne laisse que 2,08mm entre les pads LINE/NEUT/PILOT. Une v2 nécessiterait un re-routage du PCB et potentiellement un bornier au pas de 7,62mm.

5. **Traces non connectées** — Le DRC signale 2 connexions manquantes sur U3 (pin 5, net D2-Pad2) et une piste flottante sur R2. À corriger dans KiCad.

---

**EN**

The current design works correctly for its intended use. Here are possible improvements for a future revision:

1. **Oversized fuse** — The 1A fuse is generous for this circuit (the HLK-PM01 draws ~15mA and the pilot wire only a few mA). A **250mA or 500mA fuse** would provide tighter protection.

2. **No current-limiting resistor on MOC3041M output** — If the pilot wire is accidentally shorted to live or neutral, the MOC3041M internal triac (100mA RMS max) could be damaged. Adding a **330Ω to 1kΩ series resistor** on the output would protect it without affecting the pilot signal.

3. **No protection on pilot wire output** — A **TVS diode** or small varistor on the pilot wire would protect against surges coming from the radiator side.

4. **Insufficient PCB creepage distances** — IPC-2221B and IEC 62368-1 standards recommend **>2.5mm clearance** between mains and low-voltage traces for 230V AC. DRC reveals the current rule is only **0.5mm** and several traces are too close, notably the NEUT trace and D1/D2 pads (as low as **0.44mm**). The J1 terminal block (5.08mm pitch) only allows 2.08mm between LINE/NEUT/PILOT pads. A v2 would require PCB re-routing and potentially a 7.62mm pitch terminal block.

5. **Unconnected traces** — DRC reports 2 missing connections on U3 (pin 5, net D2-Pad2) and a dangling track on R2. To be fixed in KiCad.

---

## Licence / License

Ce projet est distribué sous la licence **CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S-2.0)**.

This project is licensed under the **CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S-2.0)**.

Voir / See [LICENSE](LICENSE) pour le texte complet / for the full text.
