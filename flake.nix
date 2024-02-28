{
  description = "ROS overlay for the Nix package manager";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #nixpkgs-qtwebkit_fix.url = "github:orivej/nixpkgs/qtwebkit";
    flake-utils.url = "github:numtide/flake-utils";
    livox-sdk.url = "github:purepani/Livox-SDK";
    livox-ros-driver.url = "github:purepani/livox_ros_driver";
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/develop";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    livox_laser_simulation = {
      url = "github:purepani/livox_laser_simulation";
    };
    #nix-ros-overlay.inputs.nixpkgs.follows = "nixpkgs-qtwebkit_fix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nix-ros-overlay,
    livox-sdk,
    livox-ros-driver,
    livox_laser_simulation,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    #pkgs_fix = import (inputs.nixpkgs-qtwebkit_fix) {
    #inherit system;
    #config.permittedInsecurePackages = [
    #"qtwebkit-5.212.0-alpha4"
    #];
    #};
    #

    overlay_fix = self: super: {
      rosPackages.noetic = super.rosPackages.noetic.overrideScope (rosSelf: rosSuper: {
        livox-mapping = rosSelf.callPackage ./nix/livoxmapping.nix {};
        rosgraph = rosSuper.rosgraph.overrideAttrs ({patches ? [], ...}: {
          patches =
            patches
            ++ [
              ./rosgraph-2353.patch
            ];
        });
      });
    };

    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        nix-ros-overlay.overlays.default
        livox-ros-driver.overlays.default
        #livox_laser_simulation.overlays.default
        overlay_fix
      ];

      config.permittedInsecurePackages = [
        "qtwebkit-5.212.0-alpha4"
        "freeimage-unstable-2021-11-01"
      ];
    };
  in {
    #nixpkgs.overlays = [nix-ros-overlay.overlay];
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs;
      with rosPackages.noetic;
      with pythonPackages; [
        glibcLocales
        qt5.wrapQtAppsHook
        makeWrapper
        bashInteractive
        (buildEnv
          {
            ignoreCollisions = true;
            paths = [
              ros-base
              #desktop-full
              livox-driver
              #livox-laser-simulation
              livox-mapping
            ];
          })
      ];
      nativeBuildInputs = with pkgs; [
        libsForQt5.wrapQtAppsHook
        makeWrapper
      ];
      shellHook = ''
        bashdir=$(mktemp -d)
        makeWrapper "$(type -p bash)" "$bashdir/bash" "''${qtWrapperArgs[@]}"
        exec "$bashdir/bash"
      '';
      #QT_PLUGIN_PATH = with pkgs.qt5; "${qtbase}/${qtbase.qtPluginPrefix}";
      ROS_HOSTNAME = "localhost";
      ROS_MASTER_URI = "http://localhost:11311";
    };
    packages.x86_64-linux.livox-mapping = pkgs.rosPackages.noetic.livox-mapping;
    packages.x86_64-linux.livox-driver = pkgs.rosPackages.noetic.livox-driver;
    nixConfig = {
      extra-substituters = [
        "https://cache.nixos.org"
        "https://ros.cachix.org"
        "https://livoxpackages.cachix.org"
      ];
      extra-trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
        "livoxpackages.cachix.org-1:3AHIctixz1S97DqgeTp1rFcmb94dZ3nWAptPzijuoOg="
      ];
    };
  };
}
