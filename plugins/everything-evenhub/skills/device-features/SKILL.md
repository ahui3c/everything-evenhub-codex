---
name: device-features
description: Use G2 hardware features in Even Hub apps — microphone audio capture, IMU motion data, device info, user info, and local storage. Use when working with audio, IMU, battery, wearing detection, or persistent storage.
allowed-tools: [Read, Grep, Glob, Bash, Write, Edit]
argument-hint: [feature task description]
---

You are implementing G2 hardware feature integration for an Even Hub app. Use the reference below to implement exactly what `$ARGUMENTS` describes.

## Prerequisite

`createStartUpPageContainer` must succeed before calling `audioControl` or `imuControl`. Both features depend on the startup page container being established first.

---

## Audio Capture

Start the microphone with `await bridge.audioControl(true)` and stop it with `await bridge.audioControl(false)`.

Audio data arrives through the `onEvenHubEvent` listener. Access it via `event.audioEvent.audioPcm`, which is a `Uint8Array`.

**Format:** PCM, 16 kHz sample rate, signed 16-bit little-endian, mono channel.

```typescript
// Prerequisite: createStartUpPageContainer must succeed first
await bridge.audioControl(true)

const unsubscribe = bridge.onEvenHubEvent(event => {
  if (event.audioEvent) {
    const pcm = event.audioEvent.audioPcm // Uint8Array
    // Process PCM data (Web Audio API, speech recognition, etc.)
  }
})

// Stop and clean up
await bridge.audioControl(false)
unsubscribe()
```

---

## IMU Control

Start IMU reporting with `await bridge.imuControl(true, ImuReportPace.P500)` and stop with `await bridge.imuControl(false)`.

**ImuReportPace enum values:** P100, P200, P300, P400, P500, P600, P700, P800, P900, P1000. These are protocol pacing codes, not literal Hz values.

IMU data arrives via `onEvenHubEvent`. Access it through `event.sysEvent.imuData`, which has the shape `{ x: float, y: float, z: float }`. Filter events by checking `sys.eventType === OsEventTypeList.IMU_DATA_REPORT`.

```typescript
import { ImuReportPace, OsEventTypeList } from '@evenrealities/even_hub_sdk'

await bridge.imuControl(true, ImuReportPace.P500)

const unsubscribe = bridge.onEvenHubEvent(event => {
  const sys = event.sysEvent
  if (!sys?.imuData) return
  if (sys.eventType !== OsEventTypeList.IMU_DATA_REPORT) return
  const { x, y, z } = sys.imuData
  console.log('IMU:', x, y, z)
})

await bridge.imuControl(false)
unsubscribe()
```

---

## Device Info

`await bridge.getDeviceInfo()` returns a `DeviceInfo` object or `null`.

**DeviceInfo fields:**
- `model` — `DeviceModel` enum (`DeviceModel.G1 = "g1"`, `DeviceModel.G2 = "g2"`, `DeviceModel.Ring1 = "ring1"`)
- `sn` — serial number string
- `status` — a `DeviceStatus` object

**DeviceStatus interface fields:**
- `sn` — serial number
- `connectType` — a `DeviceConnectType` enum value
- `isWearing?` — boolean, whether the user is wearing the device
- `batteryLevel?` — integer 0–100
- `isCharging?` — boolean
- `isInCase?` — boolean

**DeviceConnectType enum values:** None, Connecting, Connected, Disconnected, ConnectionFailed

**DeviceStatus helper methods:** `isNone()`, `isConnected()`, `isConnecting()`, `isDisconnected()`, `isConnectionFailed()`

For real-time status updates, subscribe with `bridge.onDeviceStatusChanged`:

```typescript
const unsubscribe = bridge.onDeviceStatusChanged(status => {
  console.log('Battery:', status.batteryLevel)
  console.log('Connected:', status.isConnected())
})
```

Call `unsubscribe()` to stop listening.

---

## User Info

`await bridge.getUserInfo()` returns a `UserInfo` object.

**UserInfo fields:**
- `uid` — number, unique user identifier
- `name` — string, display name
- `avatar` — string, URL to the user's avatar image
- `country` — string, user's country code

---

## Local Storage

Persist data to the Even Realities App (survives app restarts):

- `await bridge.setLocalStorage(key, value)` — stores a string value; returns `boolean` indicating success
- `await bridge.getLocalStorage(key)` — retrieves a stored string; returns an empty string if the key does not exist

### SDK localStorage is the only reliable persistence

The Even App WebView is a Flutter WebView. **Browser IndexedDB and browser `localStorage` do NOT reliably persist across app restarts** in this environment — data saved there can be lost when the user closes and reopens the app.

Use `bridge.setLocalStorage` / `bridge.getLocalStorage` for all user state: settings, progress, bookmarks, preferences, cached content. For large content (e.g. ebook text), chunk it across multiple keys:

```typescript
const CHUNK_SIZE = 50_000  // chars per key
const PREFIX = 'myapp.content_'

async function saveContent(bridge: EvenAppBridge, id: string, text: string) {
  const chunks = Math.ceil(text.length / CHUNK_SIZE)
  await bridge.setLocalStorage(`${PREFIX}${id}_n`, String(chunks))
  for (let i = 0; i < chunks; i++) {
    await bridge.setLocalStorage(
      `${PREFIX}${id}_${i}`,
      text.slice(i * CHUNK_SIZE, (i + 1) * CHUNK_SIZE),
    )
  }
}
```

See `glasses-ui` → Best Practices for debouncing and serializing bridge writes.…9104 tokens truncated…te serves as the app root; leave as `"index.html"`.
- `permissions` — Array of permission objects (`{ "name": "...", "desc": "..." }`). Use `[]` for apps that need no special permissions. Valid names: `network`, `location`, `g2-microphone`, `phone-microphone`, `album`, `camera`.
- `supported_languages` — ISO 639-1 language codes the app supports.

---

## Next Steps

Tell the user how to run the project after scaffolding:

1. **Start the dev server**

   ```bash
   npm run dev
   ```

   Vite will serve the app at `http://localhost:5173` (or another port if 5173 is occupied).

2. **Preview in the simulator**

   ```bash
   npx evenhub-simulator http://localhost:5173
   ```

   The simulator renders the G2 display (576x288, 4-bit greyscale) in a desktop window so you can iterate without hardware.

3. **Test on real glasses**

   Ensure your computer and the glasses are on the same Wi-Fi network, then run:

   ```bash
   npx evenhub qr --url http://<your-ip>:5173
   ```

   Scan the QR code from the Even Hub companion app to sideload the app onto your G2.

---

## Hardware Quick Reference

| Property | Value |
|---|---|
| Display resolution | 576 x 288 px |
| Colour depth | 4-bit greyscale (16 shades of green) |
| Camera | None |
| Speaker | None |
| Connectivity | Bluetooth 5.2 |
| Input | Touchpad on the frame; optional R1 ring controller |

Keep these constraints in mind when designing layouts: full-width containers should use `width: 576`, full-height containers should use `height: 288`, and all colours must be greyscale values 0–15.

---

## Key Resources

- **SDK package**: [@evenrealities/even_hub_sdk on npm](https://www.npmjs.com/package/@evenrealities/even_hub_sdk)
- **Official docs**: https://hub.evenrealities.com/docs/getting-started/overview
- **Community Discord**: https://discord.gg/Y4jHMCU4sv

---

## Task

Scaffold a new Even Hub G2 project for: $ARGUMENTS
