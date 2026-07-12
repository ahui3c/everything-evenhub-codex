---
name: build-and-deploy
description: Package and deploy an Even Hub G2 app — validate app.json, build, pack into .ehpk, and prepare for submission. Use when packaging, deploying, publishing, or submitting an Even Hub app.
allowed-tools: [Read, Grep, Glob, Bash, Write, Edit]
argument-hint: [task description]
---

You are packaging an Even Hub G2 app for distribution. Follow the steps below carefully, validating each stage before proceeding.

## Packaging Workflow

Follow these steps in order:

### Step 1 — Validate app.json

1. Locate `app.json` in the project root.
2. Read the file and validate every field against the field reference below.
3. If any field is missing, has the wrong type, or fails a validation rule, report the exact error and fix it (with user confirmation if the fix changes meaningful values like `package_id` or `name`).
4. Do not proceed until `app.json` is valid.

### Step 2 — Build

Run the build command from the project root:

```bash
npm run build
```

Check that the build succeeds (exit code 0) and that the output folder (typically `dist/`) exists and is non-empty.

### Step 3 — Pack into .ehpk

Run the pack command, substituting the app name for `<name>`:

```bash
npx evenhub pack app.json dist -o <name>.ehpk
```

Use the value of the `name` field from `app.json` (lowercased, spaces replaced with hyphens) as `<name>`. For example, if `name` is "Weather Now", use `weather-now.ehpk`.

### Step 4 — Verify output

Confirm the `.ehpk` file was created:

```bash
ls -lh <name>.ehpk
```

If the file is missing, check the error output from the pack command and consult the troubleshooting table below.

### Step 5 — Distribute

Submit the `.ehpk` file to the Even Hub developer portal for review and publication.

---

## app.json Field Reference

Every field is required unless noted. Validate each field before running `evenhub pack`.

| Field | Type | Required | Validation rules |
|---|---|---|---|
| `package_id` | string | yes | Reverse-domain format (e.g. `com.example.myapp`). Lowercase letters and digits only — no hyphens, no uppercase, no underscores. Minimum 2 dot-separated segments. Each segment must start with a lowercase letter and contain only lowercase letters or digits. |
| `edition` | string | yes | Must be exactly `"202601"`. |
| `name` | string | yes | Maximum 20 characters. |
| `version` | string | yes | Semver format `x.y.z` — three numeric parts separated by dots (e.g. `"1.0.0"`). No `v` prefix, no pre-release suffixes. |
| `min_app_version` | string | yes | Minimum Even Hub app version required. E.g. `"2.0.0"`. |
| `min_sdk_version` | string | yes | Minimum SDK version required. E.g. `"0.0.10"`. |
| `entrypoint` | string | yes | Path to the entry HTML/JS file, relative to the build output folder. The file must exist inside the build output after `npm run build`. |
| `permissions` | array | yes | Array of permission objects (see Permissions Reference). Can be empty `[]`. Must NOT be a key-value map. |
| `supported_languages` | array | yes | Array of BCP 47 language codes from the supported set. Valid values: `en`, `de`, `fr`, `es`, `it`, `zh`, `ja`, `ko`. |

### Minimal valid app.json example

```json
{
  "package_id": "com.example.weatherapp",
  "edition": "202601",
  "name": "Weather Now",
  "version": "1.0.0",
  "min_app_version": "2.0.0",
  "min_sdk_version": "0.0.10",
  "entrypoint": "index.html",
  "permissions": [],
  "supported_languages": ["en"]
}
```

---

## Permissions Reference

`permissions` must be an **array of objects**. Each object has:

| Field | Type | Required | Notes |
|---|---|---|---|
| `name` | string | yes | One of the valid permission names listed below. |
| `desc` | string | yes | Human-readable description, 1–300 characters. |
| `whitelist` | string[] | only for `network` | List of allowed URLs. Required when `name` is `"network"`. |

### Valid permission names

- `network` — outbound network access (requires `whitelist`)
- `location` — device GPS/location data
- `g2-microphone` — microphone on the G2 glasses
- `phone-microphone` — microphone on the paired phone
- `album` — access to the photo album
- `camera` — access to the camera

### Example

```json
"permissions": [
  {
    "name": "network",
    "desc": "Fetches weather data from the API.",
    "whitelist": ["https://api.weather.com"]
  },
  {
    "name": "g2-microphone",
    "desc": "Enables voice commands for hands-free control."
  }
]
```

### Common mistake

Do NOT use a key-value map format:

```json
// WRONG
"permissions": { "network": ["example.com"] }

// CORRECT
"permissions": [{ "name": "network", "desc": "...", "whitelist": ["example.com"] }]
```

---

## CORS in the WebView

The Even App runs your plugin inside a real browser engine (Chromium on Android, WKWebView on iOS). **Full CORS enforcement applies.** The `app.json` network whitelist is an Even-level permission check — it does NOT bypass CORS. You need BOTH:

1. The domain whitelisted in `app.json` `permissions.network.whitelist`, AND
2. The remote API to respond with the correct CORS headers (`Access-Control-Allow-Origin`, etc.)

If the API you're calling doesn't send CORS headers, `fetch()` will fail with a network error even though the domain is whitelisted.

| Scenario | Fix |
|---|---|
| API has CORS headers | Just whitelist the domain in `app.json` — it works |
| API has no CORS headers | Use your own backend, a Cloudflare Worker proxy (free tier), or find a CORS-enabled mirror |
| Dev server (localhost) is blocked by CORS | Add a Vite proxy in `vite.config.ts` — see below |

### Vite dev proxy

Use a Vite proxy to avoid CORS during local development:

```typescript
// vite.config.ts
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'https://api.example.com',
        changeOrigin: true,
        rewrite: (p) => p.replace(/^\/api/, ''),
      },
    },
  },
})
```

This proxy only works in dev. For the production `.ehpk`, the WebView makes requests directly — your API must have CORS headers, or you must route through your own proxy.

### Free CORS proxy services are unreliable

Public proxies like `corsproxy.io`, `allorigins.win`, and `api.codetabs.com` go down, return 403s, or timeout without warning. If your app depends on a third-party API without CORS, deploy your own Cloudflare Worker (free tier, ~5 min setup) or find a mirror that serves CORS headers natively.

---

## evenhub pack Options

```
npx evenhub pack <app.json> <build-folder> [options]
```

| Option | Description |
|---|---|
| `-o <file>` / `--output <file>` | Output filename. Defaults to `out.ehpk` if not specified. |
| `--no-ignore` | Include dotfiles and other normally-ignored files in the package. |
| `-c` / `--check` | Check whether the `package_id` is available on the Even Hub store before packing. |

---

## Troubleshooting

| Error | Fix |
|---|---|
| `Invalid package id` | Use lowercase reverse-domain format with a minimum of 2 dot-s…18233 tokens truncated…rs are placeholders** — after `createStartUpPageContainer` succeeds, image containers are empty until populated via `updateImageRawData`.
6. **`audioControl` and `imuControl` require startup to succeed** — these will fail if called before `createStartUpPageContainer` returns `StartUpPageCreateResult.success`.
7. **Always unsubscribe event listeners on teardown** — `onEvenHubEvent`, `onDeviceStatusChanged`, and `onLaunchSource` all return an unsubscribe function; call it when your component/page is destroyed.
8. **`onLaunchSource` fires only once** — register the listener early (before or immediately after `waitForEvenAppBridge`) to avoid missing the event.

---

## Canvas Specifications

| Property | Value |
|---|---|
| Resolution | 576 × 288 px |
| Colour depth | 4-bit greyscale (16 shades, 0 = black, 15 = white) |
| Coordinate origin | (0, 0) at top-left |
| X axis | Increases rightward |
| Y axis | Increases downward |

---

## Host Push Format (Simulator / Testing)

The companion app (and simulator) push events into the WebView via `window.postMessage`. You generally do not need to handle these directly — the SDK processes them internally — but the formats are useful when writing tests or a custom simulator.

```javascript
// Format 1 — named event type with jsonData wrapper
{ type: 'listen_even_app_data', method: 'evenHubEvent', data: { type: 'listEvent', jsonData: { /* event payload */ } } }

// Format 2 — snake_case event type with data wrapper
{ type: 'listen_even_app_data', method: 'evenHubEvent', data: { type: 'list_event', data: { /* event payload */ } } }

// Format 3 — array format [eventType, payload]
{ type: 'listen_even_app_data', method: 'evenHubEvent', data: ['list_event', { /* event payload */ }] }

// Audio event — audioPcm is an array of PCM sample integers
{ type: 'listen_even_app_data', method: 'evenHubEvent', data: { type: 'audioEvent', jsonData: { audioPcm: [/* numbers */] } } }

// Device status changed
{ type: 'listen_even_app_data', method: 'deviceStatusChanged', data: { sn: 'ABC123', connectType: 'connected', isWearing: true, batteryLevel: 80, isCharging: false } }

// Launch source (fires once on app open)
{ method: 'evenAppLaunchSource', data: { launchSource: 'appMenu' } }
```

---

## Task

Look up SDK reference for: $ARGUMENTS
