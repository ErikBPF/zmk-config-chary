set shell := ["bash", "-euo", "pipefail", "-c"]

config_dir := justfile_directory() / "config"
extra_modules := justfile_directory() / "input-processor-idle-suppress"
dev := "devenv shell --"

# Board specifiers — /nrf52840/zmk selects the ZMK variant (enables BLE, USB, settings)
xiao  := "xiao_ble/nrf52840/zmk"
nano  := "nice_nano/nrf52840/zmk"

# List available recipes
default:
    @just --list

# Initialize west workspace (first time only)
init:
    {{dev}} west init -l config/
    {{dev}} west update

# Update west modules
update:
    {{dev}} west update

# Build a specific target: dongle-xiao, dongle-nano, left, right, reset-xiao, reset-nano
build target:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{target}}" in
        dongle-xiao) {{dev}} west build -p -s zmk/app -d build/dongle-xiao -b {{xiao}} -- -DSHIELD=charybdis_dongle -DZMK_CONFIG="{{config_dir}}" -DZMK_EXTRA_MODULES="{{extra_modules}}" ;;
        dongle-nano)  {{dev}} west build -p -s zmk/app -d build/dongle-nano  -b {{nano}} -- -DSHIELD=charybdis_dongle -DZMK_CONFIG="{{config_dir}}" -DZMK_EXTRA_MODULES="{{extra_modules}}" ;;
        left)         {{dev}} west build -p -s zmk/app -d build/left         -b {{nano}} -- -DSHIELD=charybdis_left   -DZMK_CONFIG="{{config_dir}}" -DZMK_EXTRA_MODULES="{{extra_modules}}" ;;
        right)        {{dev}} west build -p -s zmk/app -d build/right        -b {{nano}} -- -DSHIELD=charybdis_right  -DZMK_CONFIG="{{config_dir}}" -DZMK_EXTRA_MODULES="{{extra_modules}}" ;;
        reset-xiao)   {{dev}} west build -p -s zmk/app -d build/reset-xiao   -b {{xiao}} -- -DSHIELD=settings_reset   -DZMK_CONFIG="{{config_dir}}" -DZMK_EXTRA_MODULES="{{extra_modules}}" ;;
        reset-nano)   {{dev}} west build -p -s zmk/app -d build/reset-nano   -b {{nano}} -- -DSHIELD=settings_reset   -DZMK_CONFIG="{{config_dir}}" -DZMK_EXTRA_MODULES="{{extra_modules}}" ;;
        tps43)        {{dev}} west build -p -s zmk/app -d build/tps43         -b {{nano}} -- -DSHIELD=tps43             -DZMK_CONFIG="{{config_dir}}" -DZMK_EXTRA_MODULES="{{extra_modules}};{{justfile_directory()}}/zmk-driver-azoteq-iqs5xx" ;;
        corne-dongle) {{dev}} west build -p -s zmk/app -d build/corne-dongle -b {{nano}} -- -DSHIELD=corne_tps43_dongle -DZMK_CONFIG="{{config_dir}}" -DZMK_EXTRA_MODULES="{{extra_modules}};{{justfile_directory()}}/zmk-driver-azoteq-iqs5xx" ;;
        corne-left)   {{dev}} west build -p -s zmk/app -d build/corne-left   -b {{nano}} -- -DSHIELD=corne_tps43_left  -DZMK_CONFIG="{{config_dir}}" -DZMK_EXTRA_MODULES="{{extra_modules}};{{justfile_directory()}}/zmk-driver-azoteq-iqs5xx" ;;
        corne-right)  {{dev}} west build -p -s zmk/app -d build/corne-right  -b {{nano}} -- -DSHIELD=corne_tps43_right -DZMK_CONFIG="{{config_dir}}" -DZMK_EXTRA_MODULES="{{extra_modules}};{{justfile_directory()}}/zmk-driver-azoteq-iqs5xx" ;;
        *) echo "Unknown target: {{target}}"; echo "Available: dongle-xiao dongle-nano left right reset-xiao reset-nano tps43 corne-dongle corne-left corne-right"; exit 1 ;;
    esac
    echo "Firmware: build/{{target}}/zephyr/zmk.uf2"

# Build all firmware targets and collect .uf2 files
build-all: (build "dongle-xiao") (build "dongle-nano") (build "left") (build "right") collect

# Rebuild a target (clean + build)
rebuild target: (clean-target target) (build target)

# Draw keymap SVG locally (requires keymap-drawer)
draw:
    {{dev}} ./scripts/draw-keymap.sh

# Clean all build artifacts
clean:
    rm -rf build/

# Clean a single target
clean-target target:
    rm -rf build/{{target}}

# Collect all .uf2 files into a directory
collect dest="firmware":
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "{{dest}}"
    for d in build/*/zephyr/zmk.uf2; do
        [ -f "$d" ] || { echo "No .uf2 files found. Run 'just build-all' first."; exit 1; }
        name=$(basename "$(dirname "$(dirname "$d")")")
        cp "$d" "{{dest}}/charybdis_${name}.uf2"
        echo "  ${name} → {{dest}}/charybdis_${name}.uf2"
    done
    echo "All firmware collected in {{dest}}/"
