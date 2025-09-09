# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "unstable"; # Changed from "stable-24.05" to "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.jdk21
    pkgs.unzip
    pkgs.chromium # Changed from pkgs.google-chrome
    pkgs.flutter # Added Flutter
  ];
  # Sets environment variables in the workspace
  env = {
    CHROME_EXECUTABLE = "${pkgs.chromium}/bin/chromium"; # Changed path to chromium
  };
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Co1e = { };
      # To run something each time the workspace is (re)started, use the `onStart` hook
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
