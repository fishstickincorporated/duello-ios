import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  // App ID, confirmed by Jeff (Nov 9, 2026). This is the bundle ID
  // in App Store Connect too — changing it later means a new app
  // listing, not just a config edit.
  appId: 'com.duellogame.app',
  appName: 'Duello',
  webDir: 'www',
  // No `server.url` on purpose: the app loads the BUNDLED web assets
  // from local files. The game talks to https://duellogame.com only
  // for its API (see README — the web app needs absolute API URLs
  // when window.Capacitor is present).
};

export default config;
