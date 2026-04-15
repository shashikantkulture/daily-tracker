# Daily Tracker Android APK

This folder contains a native Android wrapper for the existing web dashboard.

## What it does
- Loads `index.html` from local assets inside a full-screen `WebView`.
- Includes `client.html` and routes `/client` links to the local client page.
- Keeps existing UI/behavior from the web app (including localStorage persistence inside WebView storage).

## Build debug APK

```bash
cd android-app
gradle assembleDebug
```

APK output (debug):

```text
app/build/outputs/apk/debug/app-debug.apk
```

## Notes
- Requires Android SDK + platform tools configured (`ANDROID_HOME` / `sdk.dir`) and a compatible JDK (17/21 recommended for AGP).
- If you update root `index.html` or `client.html`, copy them into `app/src/main/assets/` before rebuilding.


## GitHub Actions APK build

A CI workflow is included at `.github/workflows/android-apk.yml`.
It builds `app-debug.apk` and uploads it as a workflow artifact on pushes/PRs that touch Android or web asset files.
