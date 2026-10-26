{
  description = "StudyFlow Flutter/Android development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };

      # Match Flutter 3.47's Android defaults. Update together with Flutter.
      platformVersion = "36";
      buildToolsVersion = "36.0.0";
      ndkVersion = "28.2.13676358";
      flutter = pkgs.flutter347.override {
        # Universal artifacts include the host engine used by flutter test.
        supportedTargetFlutterPlatforms = [ "android" "universal" ];
      };
      jdk = pkgs.jdk21;
      android = pkgs.androidenv.composeAndroidPackages {
        platformVersions = [ platformVersion ];
        buildToolsVersions = [ buildToolsVersion ];
        includeNDK = true;
        ndkVersions = [ ndkVersion ];
        includeCmake = false;
        includeEmulator = true;
        includeSystemImages = true;
        systemImageTypes = [ "google_apis" ];
        abiVersions = [ "x86_64" ];
        includeSources = false;
        toolsVersion = null;
        # sdkmanager --licenses (used by flutter doctor) checks the whole
        # repository, including licenses for packages that are not installed.
        extraLicenses = [
          "android-googletv-license"
          "android-googlexr-license"
          "android-sdk-arm-dbt-license"
          "android-sdk-preview-license"
          "google-gdk-license"
          "microxr-sysimage-license"
          "mips-android-sysimage-license"
        ];
      };
      androidHome = "${android.androidsdk}/libexec/android-sdk";
      emulatorLauncher = pkgs.writeShellApplication {
        name = "studyflow-emulator";
        runtimeInputs = [ pkgs.coreutils pkgs.gnugrep android.androidsdk ];
        text = builtins.readFile ./scripts/studyflow-emulator.sh;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          flutter
          jdk
          android.androidsdk
          emulatorLauncher
          pkgs.gitMinimal
          pkgs.curl
          pkgs.unzip
        ];

        JAVA_HOME = jdk.home;
        ANDROID_HOME = androidHome;
        ANDROID_SDK_ROOT = androidHome;
        ANDROID_NDK_ROOT = "${androidHome}/ndk/${ndkVersion}";
        FLUTTER_ROOT = "${flutter}";
        STUDYFLOW_ANDROID_SYSTEM_IMAGE = "system-images;android-${platformVersion};google_apis;x86_64";
        FLUTTER_SUPPRESS_ANALYTICS = "true";
        DART_SUPPRESS_ANALYTICS = "true";

        shellHook = ''
          export STUDYFLOW_PROJECT_ROOT="$(pwd -P)"
          export STUDYFLOW_DEV_DIR="$STUDYFLOW_PROJECT_ROOT/.dev"
          export XDG_CACHE_HOME="$STUDYFLOW_DEV_DIR/cache"
          export XDG_CONFIG_HOME="$STUDYFLOW_DEV_DIR/config"
          export PUB_CACHE="$STUDYFLOW_DEV_DIR/pub-cache"
          export GRADLE_USER_HOME="$STUDYFLOW_DEV_DIR/gradle"
          export ANDROID_USER_HOME="$STUDYFLOW_DEV_DIR/android"
          export ANDROID_EMULATOR_HOME="$ANDROID_USER_HOME"
          export ANDROID_AVD_HOME="$ANDROID_USER_HOME/avd"
          export GRADLE_OPTS="''${GRADLE_OPTS:-} -Dorg.gradle.project.android.aapt2FromMavenOverride=${androidHome}/build-tools/${buildToolsVersion}/aapt2"

          mkdir -p "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$PUB_CACHE" \
            "$GRADLE_USER_HOME" "$ANDROID_AVD_HOME"
          echo "StudyFlow dev shell — Flutter ${flutter.version}, Android API ${platformVersion}, JDK 21"
          echo "Emulator: studyflow-emulator (software: studyflow-emulator --software)"
        '';
      };
    };
}
