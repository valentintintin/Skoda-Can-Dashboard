flutter build bundle \
&& dart /home/valentin/Softs/flutter/bin/cache/dart-sdk/bin/snapshots/frontend_server.dart.snapshot \
  --sdk-root /home/valentin/Softs/flutter/bin/cache/artifacts/engine/common/flutter_patched_sdk_product \
  --target=flutter \
  --aot \
  --tfa \
  -Dart.vm.product=true \
  --packages .packages \
  --output-dill build/kernel_snapshot.dill \
  --verbose \
  --depfile build/kernel_snapshot.d \
  package:skoda_can_dashboard/main.dart \
&&  /home/valentin/Téléchargements/Voiture/gen_snapshot_linux_x64_release \
  --deterministic \
  --snapshot_kind=app-aot-elf \
  --elf=build/flutter_assets/app.so \
  --strip \
  --sim-use-hardfp \
  build/kernel_snapshot.dill