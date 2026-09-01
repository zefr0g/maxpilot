# Contributing / Contribuer

Thanks for your interest in MaxPilot! Bug reports, build photos, wiring questions and
pull requests are all welcome. *(Merci de votre intérêt ! Rapports de bugs, photos de
montage, questions de câblage et pull requests sont les bienvenus, en français ou en anglais.)*

## Reporting a problem

Open an [issue](https://github.com/zefr0g/maxpilot/issues) and include:

- PCB version (silkscreen, e.g. `v2.0`) and radiator model
- ESPHome version and the device YAML you flashed (without secrets)
- What you expected vs. what happened; ESPHome logs help a lot

## Hardware changes

- Edit the KiCad 9 project in `hardware/kicad/`; keep ERC and DRC clean
- Mains traces stay on the back copper layer with the existing clearance rules
  (`MaxPilot.kicad_dru`) — do not reduce creepage or clearance
- Regenerate `hardware/gerber/`, `hardware/MaxPilot.csv` and the SVGs in `images/`
- Bump the version on the silkscreen and in the README changelog

## Firmware changes

- Shared logic lives in `esphome/common/`; device files only carry substitutions and secrets
- Run `esphome config esphome/maxpilot_ch1.yaml` before opening a PR (CI does it too)
- Keep `common/` free of custom `!secret` names so the dashboard adopt flow keeps working

## Enclosure

- Source is `hardware/enclosure/MaxPilot_box.scad` (OpenSCAD); regenerate the STLs after editing

## License

By contributing you agree that your contribution is licensed under CERN-OHL-S-2.0.
