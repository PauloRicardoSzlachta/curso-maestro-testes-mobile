#!/usr/bin/env bash
set -euo pipefail

# Instala o Maestro dentro do container
export MAESTRO_VERSION=2.7.0
curl -Ls "https://get.maestro.mobile.dev" | bash
"$HOME/.maestro/bin/maestro" --version

# Suprime dialogos de ANR/crash
adb shell settings put global hide_error_dialogs 1
adb shell wm dismiss-keyguard

# Instala o APK
adb install ShopDemo.apk

# Roda as flows EM SEQUENCIA, uma por vez
mkdir -p reports
cd flows/s3-suite-shopdemo
failed=0
for flow in 01-login.yaml 02-catalogo.yaml 03-carrinho-checkout.yaml 04-e2e-compra.yaml; do
  "$HOME/.maestro/bin/maestro" test "$flow" --format junit --output "../../reports/${flow%.yaml}.xml" || failed=1
done
exit $failed