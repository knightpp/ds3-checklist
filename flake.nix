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
      ({pkgs}: {
        default = let
          androidComposition = pkgs.androidenv.composeAndroidPackages {
            buildToolsVersions = ["30.0.3"];
            platformVersions = ["33"];
            abiVersions = ["armeabi-v7a" "arm64-v8a"];
          };
          androidSdk = androidComposition.androidsdk;
          buildApk = pkgs.writeShellScriptBin "buildApk" ''
            set -euo pipefail
            export ANDROID_SDK_ROOT="${androidSdk}/libexec/android-sdk"

            cd ds3_checklist
            flutter pub get
            flutter analyze --no-fatal-infos
            flutter build apk --release
          '';
        in
          pkgs.mkShell {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";

            buildInputs = [
              buildApk
              androidSdk

              pkgs.flutter
              pkgs.jdk17
              pkgs.flatbuffers
            ];
          };
      });
  };
}
