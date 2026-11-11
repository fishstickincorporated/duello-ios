# Duello — iOS wrapper (TestFlight prep)

A Capacitor shell (WKWebView) around the exact same Duello web app.
No rebuild of the game: the app loads the bundled HTML/CSS/JS from
local files and talks to the live server at https://duellogame.com
for its API. The UI in the app is the UI on the web — same code,
same server.

## What is done

- Capacitor project (Capacitor 8.6.0: `@capacitor/core`, `@capacitor/cli`,
  `@capacitor/ios`, plus `typescript` as a dev dependency, which the
  `.ts` config requires). `npx cap add ios` succeeded; the Xcode
  project lives at `ios/App/App.xcodeproj`.
- App name **Duello**, bundle ID **com.duellogame.app** — confirmed by
  Jeff (Nov 9, 2026). It is set in `capacitor.config.ts`, in the
  generated `ios/App/App/capacitor.config.json`, and as
  `PRODUCT_BUNDLE_IDENTIFIER` in the Xcode project (both targets).
  Changing it later means a new app listing, not just a config edit.
- Web assets copied from `~/workspace/duello-botplay/public/` into
  `www/` (a copy — the live source is untouched) and synced into the
  Xcode project at `ios/App/App/public/`. The copy is from the live
  v87 build. **No `server.url` in the Capacitor config**: the app
  loads the bundled assets, not a remote page.
- App icon: the finalized numberless 3D D tile (1024×1024, downloaded
  from the Duello Google Drive, `duello-app-icon.png`) is in place at
  `ios/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png`.
  The template uses a single universal 1024 icon — Xcode derives all
  smaller sizes from it at build time. The master is kept at
  `assets/duello-app-icon-1024.png`.
- Splash screen: Duello Blue `#03eaff` background with the D tile
  centered, generated at 2732×2732 for all three slots the template
  expects (`splash-2732x2732.png`, `-1.png`, `-2.png`) in
  `ios/App/App/Assets.xcassets/Splash.imageset/`. The LaunchScreen
  storyboard already references this image set.

## What is left

### 1. Two small web changes (in the web app, not here)

Do these in `~/workspace/duello-botplay/` and push as a normal web
release, then re-copy the assets here with `npx cap sync ios`:

**(a) Absolute API URLs when running in the shell.** In the app,
relative `/api/...` resolves against the local file, not the server,
so every API call (and the EventSource stream URL for live 1v1
updates) must use `https://duellogame.com/api/...` when
`window.Capacitor` is present. In a browser nothing changes.

**(b) Safe-area CSS.** The shell has no Safari chrome, so the notch /
Dynamic Island and the home bar overlap the app unless the layout
accounts for them: add `viewport-fit=cover` to the viewport meta tag
and pad the top/bottom of the app with `env(safe-area-inset-*)`
(notably the tab bar at the bottom and the home header at the top).

### 2. IPA build + signing (needs a Mac with Xcode)

This Linux VM cannot build an IPA. On Jeff's Mac:

1. Enroll in the **Apple Developer Program ($99/yr)** — required even
   for TestFlight, even just for himself. This is not done yet.
2. Open `ios/App/App.xcodeproj` in Xcode (there is no `.xcworkspace` — this project uses no CocoaPods, so the project file is the one to open).
3. Select the App target → Signing & Capabilities → pick his team
   (the Apple ID enrolled in the program). Bundle ID
   `com.duellogame.app` must match the App ID created in App Store
   Connect.
4. Create the app record in App Store Connect (same bundle ID, name
   Duello) — no public listing is created by this; TestFlight builds
   are private until submitted for App Store review.
5. In Xcode: Product → Archive, then Distribute App → App Store
   Connect → upload. The build appears in TestFlight; install it on
   his phone from the TestFlight app.

### 3. Keeping the wrapper in step with the web app

- **Server-side changes** (game logic, rules, matchmaking, stats,
  definitions — anything in `server.js` or the API) reach TestFlight
  instantly: the app talks to the same live server, no new build.
- **Bundled UI changes** (anything in `www/`) need a new build:
  copy the fresh `public/` over `www/`, run `npx cap sync ios`,
  re-archive and upload. TestFlight review on a new build is short
  (usually hours).

## Exact next steps

1. Make the two web changes above (absolute API URLs + safe-area CSS)
   in the web app, verify live on the web, then:
   `cp -r ~/workspace/duello-botplay/public/* www/` (or re-copy the
   folder) and `npx cap sync ios`.
2. Jeff enrolls in the Apple Developer Program.
3. On his Mac: open the workspace, sign the App target, archive, and
   upload to App Store Connect.
4. Install from TestFlight and play a real 1v1 on the phone (the
   drag feel and the safe-area padding are the two things that can
   only be judged on the device).
5. Public App Store submission is a later, separate step — nothing
   here creates a public listing.

## Layout

- `capacitor.config.ts` — Capacitor config (appId, appName, webDir).
- `www/` — bundled web assets (copy of the web app's `public/`).
- `ios/` — the Xcode project (`ios/App/App.xcodeproj`).
- `assets/duello-app-icon-1024.png` — the master app icon.
- `package.json` / `package-lock.json` — Capacitor 8.6.0 + TypeScript.
