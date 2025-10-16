{ pkgs, ... }:
let
  android_sdk_packages = pkgs.androidenv.composeAndroidPackages {
    platform-tools = true;
    build-tools = ["34.0.0"];
    platforms = ["android-36"]; # Matched with compileSdk=36
    cmdline-tools = ["latest"];
  };
in
{
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.flutter
    pkgs.dart-sdk # Explicitly include Dart SDK
    pkgs.jdk21
    pkgs.unzip
  ];

  # Android SDK configuration
  android_sdk = android_sdk_packages;

  # Sets environment variables in the workspace
  env = {
    ANDROID_HOME = "${android_sdk_packages}";
  };

  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];
    workspace = {
      # Runs when a workspace is first created
      onCreate = {
        get-deps = "flutter pub get";
      };
      # Runs on every workspace start
      onStart = {
        doctor = "flutter doctor -v";
      };
    };
    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT"];
          manager = "flutter";
        };
        android = {
          command = ["flutter" "run" "--machine" "-d" "android" "-d" "localhost:5555"];
          manager = "flutter";
        };
      };
    };
  };
}