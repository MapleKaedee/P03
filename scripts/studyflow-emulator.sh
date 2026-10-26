# Packaged by writeShellApplication in flake.nix (Bash, strict mode).

software=false
case "${1:-}" in
  --help|-h)
    cat <<'HELP'
Usage: studyflow-emulator [--software] [emulator options...]

Creates the project's StudyFlow AVD on first use, then starts it.
Uses KVM when available; otherwise uses software CPU/GPU rendering.

Examples:
  studyflow-emulator
  studyflow-emulator --software
  studyflow-emulator --software -no-window -no-audio

Run this command inside `nix develop` from the StudyFlow project root.
HELP
    exit 0
    ;;
  --software)
    software=true
    shift
    ;;
esac

: "${ANDROID_AVD_HOME:?Enter the project with nix develop first.}"
: "${STUDYFLOW_ANDROID_SYSTEM_IMAGE:?Enter the project with nix develop first.}"

avd_name=StudyFlow
mkdir -p "$ANDROID_AVD_HOME"

if [[ ! -f "$ANDROID_AVD_HOME/$avd_name.ini" ]]; then
  echo "Creating $avd_name in $ANDROID_AVD_HOME..."
  printf 'no\n' | avdmanager create avd \
    --name "$avd_name" \
    --package "$STUDYFLOW_ANDROID_SYSTEM_IMAGE" \
    --device pixel_6 \
    --path "$ANDROID_AVD_HOME/$avd_name.avd"
fi

if [[ "$software" == false ]] && ! emulator -accel-check >/dev/null 2>&1; then
  echo "KVM unavailable; using software emulation (booting can be slow)." >&2
  software=true
fi

rendering_args=()
if [[ "$software" == true ]]; then
  rendering_args=(-accel off -gpu swiftshader)
fi

# Cold boots avoid restoring a snapshot created with another rendering mode.
exec emulator -avd "$avd_name" -no-snapshot -memory 2048 -cores 2 \
  "${rendering_args[@]}" "$@"
