# CHANGELOG

## 2026.06.12

### What Changed

Two-part accessibility push for the login greeter:

1. **Low-vision readability** — every control on the greeter (user picker, password field, Login button, error message, power buttons, session picker, clock) now renders at a larger, consistent font size instead of the small Qt default.
2. **On-screen keyboard** — added a Qt VirtualKeyboard `InputPanel` that a mobility-impaired user can raise without a physical keyboard, surfaced via a new **Keyboard** toggle button in the bottom power row. This is the SDDM equivalent of LightDM + Onboard (Onboard is session-only and does nothing at the greeter).

### Technical Details

- Added a single `readonly property int fontSize: 13` on the root `Item` in `Main.qml` — the one knob to retune all greeter text, matching the theme's existing "edit one root property to retheme globally" pattern. Started at 16 for the low-vision bump, then tuned down to 13 via live `sddm-greeter-qt6 --test-mode` previews — 16 was oversized for the control widths, 13 stays clearly larger than the un-set Qt default while keeping the layout tidy.
- Applied `font.pointSize: root.fontSize` to each control instance in `Main.qml`. The `SimpleControls` (Button/ComboBox) propagate it via their existing `font: control.font` content items, so no edits were needed in `SimpleControls/`.
- No height edits required: control backgrounds use `implicitHeight: 30` as a floor, and Qt Quick Controls grow `implicitHeight` to `max(background, content + padding)`, so larger text expands the controls automatically. Error rect (`height: loginButton.height`) and clock (`height: session.height`) already track their neighbours.
- Keyboard: `import QtQuick.VirtualKeyboard` (the unversioned Qt6 module from `qt6-virtualkeyboard` — the live greeter is Qt6 `sddm-git`), a `property bool keyboardVisible`, and an `InputPanel` that slides up from the bottom. Visibility is gated on `keyboardVisible` (driven only by the toggle button) rather than `inputPanel.active`, so the keyboard is **toggle-only** and never auto-pops on field focus. Tab order weaves the new button between `shutdown` and `session`.
- When the keyboard is raised the login column lifts into the space above it via `anchors.verticalCenterOffset: -(inputPanel.height / 2)` (200ms `Behavior`), so the password field is never hidden behind the keyboard. Driven by the panel's own height, so it scales to any screen resolution — no hardcoded offset.
- Password field sets `placeholderTextColor: "white"` so the "Enter your password" hint is legible against the dark translucent background (the default Qt placeholder gray was hard to read).
- Requires `InputMethod=qtvirtualkeyboard` in `sddm.conf` and the `qt6-virtualkeyboard` package on the system/ISO — both wired up in `kiro-iso-next`.

### Files Modified

- `usr/share/sddm/themes/edu-simplicity/Main.qml`

## 2026.05.12

### What Changed

Diagnosed and fixed the edu-simplicity theme showing a black screen on PrismLinux. Root cause was kwin_wayland (the Wayland SDDM compositor) unable to open `/dev/dri/card0` due to missing group membership for the sddm user. Fixed by adding sddm to the `video` group (`sudo usermod -aG video sddm`). Also confirmed that PrismLinux uses xlibre (not xorg-server), so `DisplayServer=x11` is not viable there — must stay on Wayland.

### Technical Details

- `/dev/dri/card0` is owned by group `video` (gid 983) with `0660` perms; sddm (uid 961) had no access
- logind ACL-based seat management was not granting sddm greeter DRM access dynamically
- `DisplayServer=x11` attempted as workaround but X server (xlibre) wouldn't start via SDDM — binary path mismatch
- Correct fix: `usermod -aG video sddm` + keep `DisplayServer=wayland`
- PrismLinux SDDM settings are managed through ATT (hidden section)

### Files Modified

None — theme QML unchanged; system config changes made on PrismLinux.

## 2026.05.10 (session 3)

### What Changed

Confirmed the theme works on real hardware under X11 SDDM (`sddm-greeter`, Qt5.15). Merged `breeze-background` branch into master. Identified that since the theme now works with both Qt5.15 and Qt6 greeters, merging back into the original `edu-sddm-simplicity` repo is worth considering next session.

### Technical Details

- Deployed with `sudo cp -r /home/erik/EDU/edu-sddm-simplicity-qt6/usr/ /` — full path required, running from wrong dir was the earlier failure
- Fast-forward merge from `breeze-background` to master; origin/master already up to date
- Theme now confirmed working: X11 Qt5.15 greeter on dev machine, both test-mode greeters verified

### Files Modified

None — merge and deployment only.

## 2026.05.10 (session 2)

### What Changed

Made the theme compatible with both Qt5.15 (`sddm-greeter`, X11) and Qt6 (`sddm-greeter-qt6`, Wayland). Switched from unversioned imports to `2.15` versioned imports — Qt5.15 requires a version number and Qt6 accepts versioned 2.x imports via its compatibility layer. Updated PKGBUILD depends from `qt6-declarative` to `sddm`.

### Technical Details

- `import QtQuick` (unversioned) is rejected by the Qt5.15 `sddm-greeter` even though Qt 5.15 theoretically supports it — `import QtQuick 2.15` satisfies both greeters
- Qt6 accepts `import QtQuick 2.x` via a compatibility shim that maps them to the current Qt6 version
- `depends=('sddm')` is correct for an SDDM theme — Qt is a transitive dependency through the greeter binary
- Tested with both `sddm-greeter --test-mode` and `sddm-greeter-qt6 --test-mode`

### Files Modified

- `usr/share/sddm/themes/edu-simplicity/Main.qml`
- `usr/share/sddm/themes/edu-simplicity/SimpleControls/Button.qml`
- `usr/share/sddm/themes/edu-simplicity/SimpleControls/ComboBox.qml`
- `usr/share/sddm/themes/edu-simplicity/SceneBackground.qml`

## 2026.05.10 (session 1)

### What Changed

Replaced the broken background rendering with a proper multi-monitor implementation borrowed from the KDE breeze SDDM theme. Root element changed from `Rectangle` to `Item`. Background now uses `Repeater { model: screenModel }` so each physical display gets its own background instance. Work done on branch `breeze-background`.

### Technical Details

- Copied `Background.qml` from `/usr/share/sddm/themes/breeze/` — pure QtQuick, no KDE/Plasma dependencies
- Renamed to `SceneBackground.qml` to avoid name collision with `SddmComponents 2.0`'s own `Background` type
- Background image path passed via `Qt.resolvedUrl("images/background.jpg")` so the URL resolves relative to `Main.qml`
- `SddmComponents 2.0` import kept for `TextConstants` only
- PKGBUILD unchanged — `cp -r usr/` picks up `SceneBackground.qml` automatically

### Files Modified

- `usr/share/sddm/themes/edu-simplicity/Main.qml`
- `usr/share/sddm/themes/edu-simplicity/SceneBackground.qml` (new)

## 2026.05.09

### What Changed

Ported the theme from Qt5 to Qt6. The original QML used versioned imports (`QtQuick 2.12`, `QtQuick.Controls 2.12`) which fail on Qt6 SDDM builds. Replaced with unversioned imports. Also fixed the background image loading — the `SddmComponents` `Background` component resolves relative paths against its own location, not the theme directory. Replaced with a plain `Image` element using a theme-relative path.

### Technical Details

- Qt6 QML modules use unversioned imports; versioned imports are Qt5-only
- `SddmComponents.Background { source: config.background }` silently fails in Qt6 because the relative path resolves against Background.qml's own directory, not the theme root
- `depends` in PKGBUILD updated from `qt5-quickcontrols2 qt5-quickcontrols` to `qt6-declarative`
- Removed duplicate `makedepends=('git')` line from PKGBUILD

### Files Modified

- `usr/share/sddm/themes/edu-simplicity/Main.qml`
- `usr/share/sddm/themes/edu-simplicity/SimpleControls/Button.qml`
- `usr/share/sddm/themes/edu-simplicity/SimpleControls/ComboBox.qml`
