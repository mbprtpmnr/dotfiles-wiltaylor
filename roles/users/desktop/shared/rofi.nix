{pkgs, config, lib, ...}:
{
    home.packages = with pkgs; [
      rofi
    ];

    home.file = {
      ".config/rofi/config".text = ''
        rofi.color-enabled: true
        rofi.color-window: #1e1e20, #2c5159, #2c5159
        rofi.color-normal: #1e1e20, #c5c8c6, #1e1e20, #1e1e20, #2c5159
        rofi.color-active: #1e1e20, #c5c8c6, #1e1e20, #1e1e20, #2c5159
        rofi.color-urgent: #1e1e20, #c5c8c6, #1e1e20, #1e1e20, #2c5159

        rofi.separator-style: solid
        rofi.sidebar-mode: false
        rofi.lines: 5
        rofi.font: Source Code Pro Semibold 10.5
        rofi.bw: 1
        rofi.columns: 2
        rofi.padding: 5
        rofi.fixed-num-lines: true
        rofi.hide-scrollbar: true
      '';
    };
}
