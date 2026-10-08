{
  description = "Bast Garmin Forerunner 965 watch-face development";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      # Garmin distributes its Linux SDK for x86_64 only.
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # Garmin's downloaded executables expect conventional Linux library paths.
      # Keep the SDK and downloaded device definitions in Garmin's writable
      # per-user directory rather than copying them into the Nix store.
      garminRuntime = pkgs.buildFHSEnv {
        name = "garmin-run";
        targetPkgs =
          p: with p; [
            bash
            coreutils
            findutils
            gnugrep
            gnused
            which
            jdk17
            curl
            cacert
            unzip
            stdenv.cc.cc.lib
            zlib
            libusb1
            gtk2
            gtk3
            glib
            cairo
            pango
            atk
            gdk-pixbuf
            fontconfig
            freetype
            dejavu_fonts
            libjpeg8
            libpng
            libpng12
            libGL
            libGLU
            libxkbcommon
            libx11
            libxext
            libxi
            libxrender
            libxrandr
            libxcursor
            libxfixes
            libsm
            libice
            alsa-lib
            libpulseaudio
            webkitgtk_4_1
          ];
        runScript = pkgs.writeShellScript "garmin-exec" ''
          if [ "$#" -eq 0 ]; then
            exec bash
          fi
          exec "$@"
        '';
        profile = ''
          export JAVA_HOME=${pkgs.jdk17}
          export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
        '';
      };

      sdkCommand =
        command:
        pkgs.writeShellApplication {
          name = command;
          runtimeInputs = [ pkgs.coreutils ];
          text = ''
            sdk="''${CONNECTIQ_SDK_HOME:-}"
            if [ -z "$sdk" ] && [ -f "$HOME/.Garmin/ConnectIQ/current-sdk.cfg" ]; then
              sdk=$(tr -d '\r\n' < "$HOME/.Garmin/ConnectIQ/current-sdk.cfg")
            fi
            if [ -z "$sdk" ] || [ ! -x "$sdk/bin/${command}" ]; then
              echo "Install and activate a Linux SDK with Garmin SDK Manager, or set CONNECTIQ_SDK_HOME to its root directory." >&2
              exit 1
            fi
            exec ${garminRuntime}/bin/garmin-run "$sdk/bin/${command}" "$@"
          '';
        };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.openssl # developer key
          pkgs.python3 # browser preview server
          pkgs.unzip # SDK Manager archive
          pkgs.go-mtpfs # sideload to the watch
          garminRuntime
        ]
        ++ map sdkCommand [
          "monkeyc"
          "monkeydo"
          "connectiq"
        ];

        shellHook = ''
          export GARMIN_DEVELOPER_KEY="''${GARMIN_DEVELOPER_KEY:-$HOME/.local/share/garmin/developer_key.der}"
          echo "Bast / FR965: monkeyc, connectiq, monkeydo; see README.md for setup and USB transfer."
        '';
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
