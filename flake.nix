{
  description = "Wil Taylor's system configuration";

  inputs = {
    nixos.url = "nixpkgs/nixos-20.09";
    nixos-unstable.url = "nixpkgs/nixos-unstable";
    nixos-master.url = "nixpkgs/master";
    home-manager.url = "github:nix-community/home-manager/release-20.09";
    home-manager.inputs.nixpkgs.follows = "nixos";
    wtdevtools.url = "github:wiltaylor/wtdevtools";
    nixbundler.url = "github:wiltaylor/nix/IgnoreReferenceSwitch";
  };

  outputs = inputs @ {self, nixos, nixos-unstable, nixos-master, home-manager, wtdevtools, nixpkgs, nixbundler, ... }:
  let
    inherit (nixos) lib;
    inherit (lib) attrValues;

    util = import ./lib { inherit system pkgs home-manager lib; };

    inherit (util) host;
    inherit (util) user;

    mkPkgs = pkgs: extraOverlays: import pkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = extraOverlays;
    };

    pkgs = mkPkgs nixos [ self.overlay nixbundler.overlay ];
    upkgs = mkPkgs nixos-unstable [];
    mpkgs = mkPkgs nixos-master [];

    system = "x86_64-linux";

  in {
    overlay = 
      final: prev: {
        unstable = upkgs;
        master = mpkgs;
        my = self.packages."${system}";
      };

    packages."${system}" = import ./pkgs { inherit pkgs wtdevtools;};

    devShell."${system}" = import ./shell.nix { inherit pkgs; };

    nixosConfigurations = {
      titan = host.mkHost {
        name = "titan";
        NICs = [ "enp62s0" "wlp63s0" ];
        initrdMods = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
        kernelMods = [" kvm-intel" ];
        kernelParams = ["intel_pstate=active" "nvidia-drm.modeset=1" ];
        roles = [ "sshd" "yubikey" "kvm" "desktop-xorg" "games" "efi" "wifi" "nvidia-graphics" "core" "alienware-amplifier"];
        users = [ (user.mkUser {
          name = "wil";
          groups = [ "wheel" "networkmanager" "libvirtd" "docker" ];
          uid = 1000;
          shell = "zsh";
          roles = [ "neovim" "git" "desktop/i3wm" "ranger" "tmux" "zsh" "email" ];
        })];
        cpuCores = 8;
      };

      mini = host.mkHost {
        name = "mini";
        NICs = [ "wlo1" ];
        initrdMods = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
        kernelMods = [ "kvm-intel" ];
        kernelParams = [ "intel_pstate=active" ];
        roles = [ "sshd" "yubikey" "desktop-xorg" "efi" "wifi" "core" ];
        users = [ (user.mkUser {
          name = "wil";
          groups = [ "wheel" "networkmanager" "libvirtd" "docker" ];
          uid = 1000;
          shell = "zsh";
          roles = [ "neovim" "git" "desktop/i3wm" "ranger" "tmux" "zsh" "email" ];
        })];
        cpuCores = 2;
      };      
    };
  };
}
