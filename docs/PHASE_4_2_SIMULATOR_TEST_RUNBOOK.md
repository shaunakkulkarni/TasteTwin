# Phase 4.2 Simulator Test Runbook

## Goal
Validate Phase 4.2 behavior in simulator:
1. Log save is non-blocking even if extraction fails.
2. Taste extraction updates Taste Twin when available.
3. Failed extraction becomes pending and retry runs on launch/activation/manual debug action.

## How To Run
1. In Xcode, choose scheme `TasteTwin` and an iOS 26.2 simulator.
2. Clean old app data once (recommended after model/schema changes):
   - delete `com.shaunakkulkarni.TasteTwin` from the simulator.
3. Run app from Xcode.
4. Optional terminal build check:
   - `xcodebuild -project TasteTwin/TasteTwin.xcodeproj -scheme TasteTwin -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/TasteTwinDerived CODE_SIGNING_ALLOWED=NO build`

## Automated Checks (Terminal)
1. Build:
   - `xcodebuild -project TasteTwin/TasteTwin.xcodeproj -scheme TasteTwin -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/TasteTwinDerived CODE_SIGNING_ALLOWED=NO build`
2. Boot simulator (example device):
   - `xcrun simctl boot DBA7CABD-4AEE-4564-A122-318AA6078AF1`
3. Clean install:
   - `xcrun simctl uninstall DBA7CABD-4AEE-4564-A122-318AA6078AF1 com.shaunakkulkarni.TasteTwin`
   - `xcrun simctl install DBA7CABD-4AEE-4564-A122-318AA6078AF1 /tmp/TasteTwinDerived/Build/Products/Debug-iphonesimulator/TasteTwin.app`
4. Launch and relaunch (retry trigger):
   - `xcrun simctl launch DBA7CABD-4AEE-4564-A122-318AA6078AF1 com.shaunakkulkarni.TasteTwin`
   - `xcrun simctl terminate DBA7CABD-4AEE-4564-A122-318AA6078AF1 com.shaunakkulkarni.TasteTwin`
   - `xcrun simctl launch DBA7CABD-4AEE-4564-A122-318AA6078AF1 com.shaunakkulkarni.TasteTwin`

## Manual UI Scenarios (Xcode Simulator)
1. Smoke:
   - Open app and verify Home/Search/Profile/Taste Twin tabs load.
   - Verify Taste Twin loads seeded dimensions.
2. Post-save extraction:
   - From Search (or Home quick `+`), create a new log with rating/review/tags.
   - Verify log appears immediately in Home/Profile (save not blocked).
   - Open Taste Twin and verify dimensions/evidence updates when extraction succeeds.
3. Failure/pending behavior:
   - If Foundation Models extraction is unavailable/fails, verify no crash.
   - Verify log still exists and Taste Twin may not update immediately.
4. Retry behavior:
   - Background/foreground app, or use `Retry Pending` button on Taste Twin in Debug.
   - Verify pending logs are retried and reflected in Taste Twin if extraction succeeds.
5. Regression:
   - Verify edit/delete log still works.
   - Verify Search -> Album Detail -> Log Entry navigation is unchanged.

## Where This Is Wired
- `TasteTwin/TasteTwin/TasteTwin/App/AppEnvironment.swift`
- `TasteTwin/TasteTwin/TasteTwin/App/AppRouter.swift`
- `TasteTwin/TasteTwin/TasteTwin/ViewModels/LogEntryViewModel.swift`
- `TasteTwin/TasteTwin/TasteTwin/Views/TasteTwin/TasteTwinPlaceholderView.swift`

## Notes
- Simulator Foundation Models behavior can vary; pending state on extraction failure is expected.
- If simulator data gets inconsistent after schema changes, uninstall the app and rerun.
