{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    # Systems supported
    allSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    # Helper to provide system-specific attributes
    forAllSystems = f:
      nixpkgs.lib.genAttrs allSystems (system:
        f {
          pkgs = import nixpkgs {
            inherit system;
            config = {
              android_sdk.accept_license = true;
              allowUnfree = true;
            };
          };
        });
  in {
    # Development environment output
    devShells =
      forAllSystems
      ({pkgs}: let
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = ["34.0.0"];
          platformVersions = ["34"];
          abiVersions = ["armeabi-v7a" "arm64-v8a"];
        };
        androidSdk = androidComposition.androidsdk;
        buildFlutter = pkgs.writeShellScriptBin "buildFlutter" ''
          set -euo pipefail
          export ANDROID_SDK_ROOT="${androidSdk}/libexec/android-sdk"

          cd ds3_checklist
          flutter pub get
          flutter analyze --no-fatal-infos
          flutter build "$@" --release
        '';
      in {
        fhs = let
          fhs = pkgs.buildFHSUserEnv {
            name = "gradle-env";
            targetPkgs = pkgs: [
              buildFlutter
              androidSdk

              pkgs.flutter
              pkgs.jdk
              pkgs.gradle
              pkgs.kotlin
              pkgs.flatbuffers
              pkgs.aapt
            ];
          };
        in
          pkgs.stdenv.mkDerivation {
            name = "flutter-env-shell";
            nativeBuildInputs = [fhs];

            # this seems to trigger an infinite loop when direnv loads this nix file... how to avoid that?
            shellHook = "exec gradle-env";

            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          };

        default = pkgs.mkShell {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          # GRADLE_HOME = "${pkgs.gradle}";

          buildInputs = [
            buildFlutter
            androidSdk

            pkgs.flutter
            pkgs.jdk
            pkgs.flatbuffers
            # pkgs.gradle
            # pkgs.aapt
          ];
        };
      });
  };
}
