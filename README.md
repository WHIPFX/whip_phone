# whip_phone

The whip Duo phone as a real FiveM resource:
- **The device:** the book-fold Duo in 3D, folding into a phone in the bottom-right and unfolding into a tablet in the middle.
- **The shell:** the WhipOS lock screen, home screen and capsule dock.
- **Notifications:** capsule-style, peeking up from out of sight.
- **Layouts:** a mouse & keyboard layout and a console layout, switched by what the player uses (not a setting).

The core has **no apps of its own**. Every app is a module, and five come built in:

| Module | What it does |
|---|---|
| Phone | recents, contacts, keypad, call screen. Incoming calls show as a capsule when the phone is put away or in an app, and full screen on the home screen or when the phone is taken out. |
| Messages | threads, chats, new message |
| Bank | your accounts and their activity, transfers, sharing an account (people nearby or by character ID), opening and closing savings and shared accounts. "Received $X" when money arrives. whip_core's bank, always your own whatever SIM is in. |
| Business | your jobs and duty; for ranks that may: the staff (hire nearby or by ID, change rank, fire) and the ranks. whip_core's jobs and their rules. |
| Settings | My card (your name and a Fivemanage profile picture, dragged and zoomed to fit; people who have your number saved see it), wallpaper, SIM, Do Not Disturb, apps, about |

Remove any of them and the phone keeps working. Modules are UI only, so the framework supplies all data through whip_core SecureCallbacks.

**Apps from other resources** can be written two ways:
- **render mode:** HTML strings with the phone's UI kit, matching the phone's look;
- **mount mode:** the app draws itself with any library (React, Vue, Svelte, Preact...) in its own style. It gets a box the phone never touches.

Either way, an app's CSS is scoped to that app, and it can set the status bar ink for a light design. Mount-mode apps can render live 3D (three.js comes with the page). See `docs/MODULES.md`. Working examples: `html/dev/example/app.js` (Garage, Preact) and `html/dev/example_3d/app.js` (Atlas, a 3D map).

**Status: not tested in game yet.** The core and modules have been run end-to-end in a browser against a mock framework (`html/preview.html`). The server side (numbers, SIM cards, contacts, messages, calls, Bank, Business) has passed Lua harnesses on stubs, but has not run on a server.

## Install

1. WHIP's txAdmin recipe installs it and adds `ensure whip_phone` to server.cfg (oxmysql and whip_core start first: its manifest asks for both). It makes and updates its own tables on start; no SQL.
2. Give a player a `phone` and a `sim_card`. The card gets a new number for them. Put it in the phone: right-click the phone, then SIM tray.
3. Press **M** (rebindable: "Phone: open / close"), use the phone item, or pick Phone on the F1 wheel. With no phone item it says "You need a phone".

**Calls:** they ring, connect and end between players, and show in Recents.
- **Sound:** whip_voice carries the call. Talk with your normal key; the people around you still hear you.
- **Speaker:** on speaker, the people near the phone hear the other side, and the other side hears them too.
- **Mute:** the other side stops hearing you.
- **Tuning:** `Config.CallSound` and `Config.SpeakerRange`.
- **Without a voice system:** the phone shows "Voice connection failed, is the voice resource started?" until one runs.

## Modes

The phone has four ways of being on screen:

| Mode | When |
|---|---|
| **Hidden** | out of sight below the bottom-right corner. This is where it starts. |
| **Peek** | while hidden, notifications raise it just enough to show them: up to 3, then the oldest makes way. It drops away again when they expire. An incoming call peeks as a capsule with Decline / Answer until it is answered, declined or missed. |
| **Phone** | the folded Duo in the bottom-right, using the cover display. |
| **Tablet** | unfolded in the middle. `exports.whip_phone:Open('tablet')` goes there straight from hidden. |

Fold or unfold with Y on a controller, or with Control Centre (the status-bar icons).

## Controls

| Input | Controls |
|---|---|
| Mouse | everything; the phone has NUI focus while it's open |
| Keyboard | arrows to move, Enter to select, Esc / Backspace for back. Back at the top level puts the phone away. |
| Controller | D-pad, A, B, X, Y (fold), LB / RB (tabs / pages), Start (Control Centre). Read in Lua (`client/controller.lua`), because FiveM's browser has no Gamepad API. |

The keyboard also reaches the game while the phone is open, so you can walk. It doesn't while you type.

## Files

| Path | What |
|---|---|
| `fxmanifest.lua`, `config.lua` | manifest (whip_core satellite) and options |
| `client/main.lua` | open / close, NUI focus, SetUIOpen / BlockControls, module list, request forwarding, exports |
| `client/controller.lua` | gamepad to phone commands |
| `server/main.lua` | Notify / Push / Open / Close / SetSession / ReloadCache exports |
| `server/contract.lua` | the phone's data: session, settings, contacts, messages, the SIM page |
| `server/calls.lua` | calls and Recents |
| `server/people.lua`, `server/bank.lua`, `server/business.lua` | the Bank and Business apps, on whip_core's bank and job exports |
| `html/index.html` | the in-game NUI page (transparent) |
| `html/core/` | OS shell, module runtime, UI kit, bridge, 3D Duo (three.js is vendored in `html/vendor`, MIT) |
| `html/modules/<id>/module.js` | the built-in modules |
| `html/preview.html`, `html/dev/` | browser preview with a mock framework, and example apps from "another resource" (`dev/example`, `dev/example_3d`). Not shipped to players. |
| `docs/FRAMEWORK.md` | every request, push and export, plus the whip_core integration notes |
| `docs/MODULES.md` | how to write a module, built-in or from another resource |

## Performance

Measured in headless Chrome on the mock framework (2026-10-08; not yet in game):
- **Put away:** about 0.5 ms of page work per second. The 3D device's frame loop naps, nothing animates off screen, and no fold snapshots are taken. On the Lua side, the clock thread checks every 2 s and the controller thread every 250 ms.
- **Open and idle:** about 15 ms/s. Only the display in use renders; looping animations run only on the display being looked at.
- **Fold snapshots:** taken after a second of stillness or as a fold starts. They are sized to the display on screen (1.25x / 1.5x at 1080p, up to 2x), about 25 ms each.
- **Reopening:** costs one `whip_phone:session` check. Contacts and app data reload only when the session changed, or on a push.
- **Download:** three.js is the minified r170 build (0.69 MB).
- **Mount-mode / 3D apps:** pause in `presence` while the phone is put away, and draw on demand or capped (docs/MODULES.md).

## Preview in a browser

Serve the `html/` folder (e.g. `python -m http.server` inside it) and open `preview.html`.

- **Dev bar:** switches mode, layout and which modules are installed (try "None"). It also fires an incoming text, an incoming call, money arriving or a framework notification.
- **Mock framework:** calls ring and connect, and contacts text back.
