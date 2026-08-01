# iOS Logitech Z407 Remote

Control Logitech Z407 speakers over BLE using Flutter.

> **Disclaimer:** This project is not affiliated with, endorsed by, or connected to Logitech (Logi) in any way. "Z407" is a product name used solely to identify compatibility. It communicates with the speaker using a reverse-engineered, undocumented protocol — use at your own risk.

## Credits

- The BLE protocol (service/characteristic UUIDs and handshake sequence) is based on [freundTech/logi-z407-reverse-engineering](https://github.com/freundTech/logi-z407-reverse-engineering).
- The connection approach in this app was adapted from [androrama/Logitech-Z407-Remote-Control-Web-App---Windows](https://github.com/androrama/Logitech-Z407-Remote-Control-Web-App---Windows), a working Python implementation of the same protocol.
- Overall assistance with Flutter/CocoaPods development was provided by [Claude.ai](https://claude.ai/).

## Installation

This project targets sideloading, not App Store distribution. Find the newest pre-built version of the IPA in Releases.

### Option 1: SideStore
Install `Z407Remote.ipa` directly through [SideStore](https://github.com/SideStore/SideStore), which re-signs it with your free Apple ID. This uses one of the 3 app slots a free Apple ID gets, and SideStore re-signs apps roughly every 7 days to keep them working. See the SideStore repo/website for setup instructions.

### Option 2: LiveContainer (skip using an app slot)
If you'd rather not spend one of your 3 free-Apple-ID app slots on this, install `Z407Remote.ipa` inside [LiveContainer](https://github.com/LiveContainer/LiveContainer) instead — it runs sideloaded IPAs inside a single container app, so it doesn't count against your slot limit. See the LiveContainer repo for setup instructions (it's commonly paired with SideStore itself).

## (CONTRIBUTORS/PERMISSION ONLY) Manually Building the IPA with GitHub Actions

Builds run in CI via [.github/workflows/ios-build.yml](.github/workflows/ios-build.yml) - no Mac, or VM required.

1. Push to `main`, or trigger the workflow manually from the **Actions** tab (`Build iOS IPA` → **Run workflow**).
2. The workflow builds an unsigned `Runner.app`, ad-hoc signs it (`codesign --sign -`), and zips it into `Z407Remote.ipa`.
3. Once the run finishes, download the `Z407Remote-ipa` artifact from the workflow run's summary page.

## Notes
- The app uses the proprietary Logitech Z407 BLE service and characteristic UUIDs.
- Bluetooth permissions are declared in the iOS plist.
