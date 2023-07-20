{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
      });
    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs }: {
        default =
          let
            androidComposition = pkgs.androidenv.composeAndroidPackages {
              buildToolsVersions = [ "30.0.3" ];
              platformVersions = [ "33" ];
              abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
            };
            androidSdk = androidComposition.androidsdk;
          in
          pkgs.mkShell {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";

            buildInputs = with pkgs; [
              flutter
              androidSdk
              jdk17
              flatbuffers
            ];
          };
      });
    };
}
