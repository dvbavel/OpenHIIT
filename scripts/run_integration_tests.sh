#!/usr/bin/env bash
# Runs every integration test on the already running emulator, one after
# another, each on a fresh install. Keeps going after a failure and exits
# non-zero at the end if any test failed. Screenshots end up in
# screenshots/<test name>/.
set -u

DEVICE=emulator-5554
PACKAGE=com.codepup.workout_timer.dev
APK=build/app/outputs/flutter-apk/app-debug.apk

bash scripts/wait_for_pm.sh

mkdir -p results
failed=()

for test in integration_test/*_test.dart; do
  name=$(basename "$test" .dart)
  echo "::group::$name"

  ok=true
  flutter build apk --debug --target "$test" || ok=false

  if $ok; then
    adb -s "$DEVICE" uninstall "$PACKAGE" >/dev/null 2>&1 || true
    adb -s "$DEVICE" install "$APK" || ok=false
  fi

  if $ok; then
    adb -s "$DEVICE" shell appops set "$PACKAGE" SCHEDULE_EXACT_ALARM allow
    flutter drive -d "$DEVICE" --no-pub \
      --driver=integration_test/driver.dart \
      --use-application-binary="$APK" || ok=false
  fi

  # driver.dart recreates screenshots/ on every run; keep each test's set.
  if [ -d screenshots ]; then
    mv screenshots "results/$name"
  fi

  echo "::endgroup::"
  if $ok; then
    echo "PASSED: $name"
  else
    echo "::error::FAILED: $name"
    failed+=("$name")
  fi
done

mv results screenshots

if [ ${#failed[@]} -gt 0 ]; then
  echo "Failed tests: ${failed[*]}"
  exit 1
fi
echo "All integration tests passed."
