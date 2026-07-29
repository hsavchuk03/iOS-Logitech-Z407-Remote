# logi_z407_remote

Control Logitech Z407 speakers over BLE using Flutter.

## Build the IPA with GitHub Actions

Builds run in CI via [.github/workflows/ios-build.yml](.github/workflows/ios-build.yml) — no Mac, Codemagic account, or VM required.

1. Push to `main`, or trigger the workflow manually from the **Actions** tab (`Build iOS IPA` → **Run workflow**).
2. The workflow builds an unsigned `Runner.app`, ad-hoc signs it (`codesign --sign -`), and zips it into `Z407Remote.ipa`.
3. Once the run finishes, download the `Z407Remote-ipa` artifact from the workflow run's summary page.

### SideStore / free Apple ID sideloading
- This project targets sideloading with SideStore, not App Store distribution — the IPA from CI is ad-hoc signed only.
- Install the downloaded `Z407Remote.ipa` on your device through SideStore, which re-signs it with your Apple ID.
- SideStore re-signs apps periodically, so expect to refresh the app roughly every 7 days.

## Notes
- The app uses the proprietary Logitech Z407 BLE service and characteristic UUIDs.
- Bluetooth permissions are declared in the iOS plist.
