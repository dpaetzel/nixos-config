{
  # TODO Maybe setup cachix for this
  description = "dpaetzel's NixOS configuration";

  # From: https://github.com/srid/nixos-config/blob/master/flake.nix
  # “To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
  # https://status.nixos.org/ This ensures that we always use the official nix
  # cache.”
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/5aaed40d22f0d9376330b6fa413223435ad6fee5";
  inputs = {
    nixpkgs.url =
      "github:dpaetzel/nixpkgs/dpaetzel/nixos-config";

    neuron.url = "github:srid/neuron/master";
    # This seems to be broken?
    # neuron.inputs.nixpkgs.follows = "nixpkgs";

    musnix.url = "github:musnix/musnix";
    musnix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    overlays.url = "github:dpaetzel/overlays/master";
    overlays.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # TODO Maybe use these
    # emacs-overlay.url = "github:nix-community/emacs-overlay";
    # nix-doom-emacs.url = "github:vlaci/nix-doom-emacs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, musnix, nixos-hardware, overlays, ... }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        # Add nixpkgs overlays and config here. They apply to system and
        # home-manager builds.
        config = {
          allowUnfree = true;
          allowBroken = true;
          android_sdk.accept_license = true;
          chromium.pulseSupport = true;
          nvidia.acceptLicense = true;
          oraclejdk.accept_license = true;
          # permittedInsecurePackages = [
          #   # TODO I'm not sure yet which package requires this, we probably just
          #   # want to remove that then
          #   "spidermonkey-38.8.0"
          # ];
        };
        overlays = with overlays; [
          # https://github.com/NixOS/nixpkgs/issues/205014#issuecomment-1402380175
          (self: super: {
            khal = super.khal.overridePythonAttrs (_ : { doCheck = false; });
          })
          yapfToml
          # (self: super: {
          #   nix-direnv = super.nix-direnv.override { enableFlakes = true; };
          # })
          # (self: super: {
          #   steam = super.steam.override { extraPkgs = pkgs: with pkgs; [ super.openssl ]; };
          # })
        ];
      };

      # General purpose Python shell I use everyday (I have an alias that runs
      # `nix run github:dpaetzel/nixos-config#pythonShell -- --profile=p`).
      pythonEnv = let
        # We use the default Python 3 currently used by nixpkgs (3.11.9 as of
        # 2024-06-22) because the version does really not matter much in
        # everyday use.
        mypython = pkgs.python3;
        cmdstanpy = mypython.pkgs.buildPythonPackage rec {
          pname = "cmdstanpy";
          version = "1.0.7";

          propagatedBuildInputs = with mypython.pkgs; [ numpy pandas tqdm ujson ];

          patches =
            [ "${self}/0001-Remove-dynamic-cmdstan-version-selection.patch" ];

          postPatch = ''
            sed -i \
              "s|\(cmdstan = \)\.\.\.|\1\"${pkgs.cmdstan}/opt/cmdstan\"|" \
              cmdstanpy/utils/cmdstan.py
          '';

          doCheck = false;

          src = mypython.pkgs.fetchPypi {
            inherit pname version;
            sha256 = "sha256-AyzbqfVKup4pLl/JgDcoNKFi5te4QfO7KKt3pCNe4N8=";
          };
        };

      in mypython.withPackages (ps:
        with ps; [
          # pkgs.cmdstan # Rather large.
          # cmdstanpy
          click
          deap
          graphviz
          ipython
          matplotlib
          numpy
          pandas
          requests
          scikit-learn
          scipy
          seaborn
          tabulate # For to_markdown of pandas DataFrames.
          toolz
          tqdm
          xlrd
        ]);
    in {
      nixosConfigurations.anaxagoras = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = { inherit pkgs system inputs pythonEnv; };
        modules = [
          ./anaxagoras/configuration.nix
          ./anaxagoras/packages.nix
          ./anaxagoras/audio.nix

          ./common.nix
          ./desktop.nix
          ./theme.nix

          musnix.nixosModules.musnix
        ];
      };
      nixosConfigurations.sokrates = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = { inherit pkgs system inputs pythonEnv; };
        modules = [
          # Not quite my t470 but close enough.
          nixos-hardware.nixosModules.lenovo-thinkpad-t470s
          ./sokrates/configuration.nix
          ./sokrates/packages.nix

          ./sokrates/cachix.nix
          ./common.nix
          ./desktop.nix
          ./theme.nix
          ./workstation.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              # Use the global nixpkgs instance.
              useGlobalPkgs = true;
              # Store user packages in `/etc/profiles/per-user/<username>`.
              useUserPackages = true;
              # I don't need this right now.
              # extraSpecialArgs = {inherit inputs outputs;};
              users.david = import ./sokrates/home.nix;
            };
          }
        ];
      };

      nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ({ pkgs, ... }: {
            environment.systemPackages = [ pkgs.inxi pkgs.hwinfo ];
          })
        ];
      };

      # Expose the Python shell.
      apps.${system}.pythonShell = {
        type = "app";
        program = "${pythonEnv}/bin/ipython";
      };
    };
}
