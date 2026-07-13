# Typeractive Corne + TPS43 + Prospector

Topology:

- Prospector (XIAO BLE): USB/BLE central dongle
- Typeractive Corne left: nice!nano v2 split peripheral plus TPS43
- Typeractive Corne right: nice!nano v2 split peripheral plus TPS43

## TPS43 pinout — schematic names

Typeractive Corne matrix leaves nice!nano D0-D3 unused. Connect one TPS43 to each half using identical wiring:

Use connector pin numbers, not cable position alone. TPS43 `J1` pin order from Azoteq schematic/datasheet:

| TPS43 connector | TPS43 net | nice!nano silkscreen | Pro Micro name | nRF52840 net | ZMK function |
|---|---|---|---|---|---|
| `J1.1` | `RDY` | `006` | `D1` | `P0.06` | `rdy-gpios` |
| `J1.2` | `SDA` | `017` | `D2` | `P0.17` | `TWIM_SDA` |
| `J1.3` | `GND` | `GND` | `GND` | `GND` | Ground |
| `J1.4` | `VDDHI` | `VCC` | `VCC` | `+3V3` | 3.3 V supply |
| `J1.5` | `SCL` | `020` | `D3` | `P0.20` | `TWIM_SCL` |
| `J1.6` | `NRST` | `008` | `D0` | `P0.08` | `reset-gpios`, active low |

Compact wiring order:

```text
TPS43 J1.1 RDY   -> nice!nano 006 / D1 / P0.06
TPS43 J1.2 SDA   -> nice!nano 017 / D2 / P0.17
TPS43 J1.3 GND   -> nice!nano GND
TPS43 J1.4 VDDHI -> nice!nano VCC / +3V3
TPS43 J1.5 SCL   -> nice!nano 020 / D3 / P0.20
TPS43 J1.6 NRST  -> nice!nano 008 / D0 / P0.08
```

## Corne matrix pin audit

Names below match nice!nano silkscreen/nRF52840 schematic nets. They are consumed by Typeractive Corne key matrix:

| Matrix signal | Pro Micro name | nice!nano / nRF net |
|---|---|---|
| `ROW0` | `D4` | `022` / `P0.22` |
| `ROW1` | `D5` | `024` / `P0.24` |
| `ROW2` | `D6` | `100` / `P1.00` |
| `ROW3` | `D7` | `011` / `P0.11` |
| `COL0..COL5`, left | `D21,D20,D19,D18,D15,D14` | `031,029,002,115,113,111` |
| `COL0..COL5`, right | `D14,D15,D18,D19,D20,D21` | `111,113,115,002,029,031` |

Audit conclusion: TPS43 nets use `008`, `006`, `017`, and `020`; none overlap matrix nets above. `017`/`020` are nice!nano hardware I2C defaults, so no custom pin swap exists in this implementation.

Do not fit nice!view adapters: they use the same exposed pin area.
TPS43 is a 3.3 V device; never connect it to raw battery voltage.

Firmware gives each touchpad a distinct split-input ID:

- left TPS43: `0`
- right TPS43: `1`

Both feed pointer events to Prospector. `Raise`/`Lower` process native two-finger scrolling; `Snipe` reduces cursor speed.

## Firmware

```sh
just build corne-dongle
just build corne-left
just build corne-right
```

Outputs:

- `build/corne-dongle/zephyr/zmk.uf2` → Prospector XIAO BLE
- `build/corne-left/zephyr/zmk.uf2` → left nice!nano v2
- `build/corne-right/zephyr/zmk.uf2` → right nice!nano v2

After flashing clean settings, power and pair left first, then right. Prospector orders peripheral status using pairing order.

## Test checklist

1. Flash Prospector, left, and right firmware.
2. Reset saved settings if old split bonds remain.
3. Pair left first, then right.
4. Confirm all 42 keys register.
5. Move each TPS43 independently and confirm cursor motion.
6. Test one-finger tap, two-finger tap, and two-finger scrolling on each TPS43.
7. Hold `Raise` or `Lower` while scrolling; verify scroll scaling.
8. Confirm Prospector shows both peripheral connections, batteries, and active layer names.
