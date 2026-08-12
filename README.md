# carplayOS

Widgets, browser, and device tools for wireless CarPlay screens (Onn dashcam mount / Carlink units).

- **Widget pack** — Dash Clock, Day Progress, SlyBrowser quick-launch. iOS 26 pins small widgets to a dedicated CarPlay widget screen: Settings → General → CarPlay → your car → Widgets.
- **SlyBrowser** — in-app browser with quick links, including the Carlink unit's backend at `192.168.50.2`.
- **Device tab** — pairing steps and settings access for CARLINK-* units.

## Build

XcodeGen project; CI builds and ships to TestFlight on push to `main`. No local Xcode required.

```
xcodegen generate
xcodebuild -project CarplayOS.xcodeproj -scheme CarplayOS build
```
