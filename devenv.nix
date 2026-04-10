{ pkgs, lib, config, inputs, ... }:

{
  packages = with pkgs; [
    git
    cmake
    ninja
    dtc
    gcc-arm-embedded
    just
  ];

  env.ZEPHYR_TOOLCHAIN_VARIANT = "gnuarmemb";
  env.GNUARMEMB_TOOLCHAIN_PATH = "${pkgs.gcc-arm-embedded}";
  env.CMAKE_PREFIX_PATH = "zephyr/share/zephyr-package/cmake";

  languages.python = {
    enable = true;
    venv.enable = true;
    venv.requirements = ''
      west
      pyelftools
      pyyaml
      packaging
      keymap-drawer
    '';
  };

  enterShell = ''
    echo "ZMK Charybdis dev environment"
    echo ""
    echo "  just init       — initialize west workspace (first time)"
    echo "  just build-all  — build all firmware targets"
    echo "  just draw       — draw keymap SVG locally"
    echo "  just --list     — show all commands"
  '';
}
