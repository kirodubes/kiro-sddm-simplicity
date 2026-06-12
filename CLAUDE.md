# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

An SDDM login screen theme named **edu-simplicity**, forked/derived from the upstream `arcolinux-simplicity` theme (original author: Gabriel Ibáñez). Written in QML targeting **Qt6** (unversioned imports — requires Qt6 SDDM).

## Install path

The `usr/` directory mirrors the live filesystem — deploying means copying it to `/`:

```bash
sudo cp -r usr/ /
```

Theme lands at `/usr/share/sddm/themes/edu-simplicity/`.

## Test without rebooting

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/edu-simplicity
```

Or point directly at the repo while developing:

```bash
sddm-greeter-qt6 --test-mode --theme /home/erik/EDU/kiro-sddm-simplicity-qt6/usr/share/sddm/themes/edu-simplicity
```

Note: test mode requires a running X11/Wayland session — does not work from TTY.

## Architecture

```
usr/share/sddm/themes/edu-simplicity/
├── Main.qml              # Root component — layout, SDDM signal handlers, timer
├── theme.conf            # Single key: background=images/background.jpg
├── metadata.desktop      # Theme metadata (name, version, entry point)
├── SimpleControls/
│   ├── Button.qml        # Styled Button — white text, semi-transparent dark bg
│   └── ComboBox.qml      # Styled ComboBox — includes getValue() helper
├── images/
│   └── background.jpg    # Background image (referenced by theme.conf)
└── faces/
    └── .face.icon        # Default user avatar
```

**Main.qml** is the only entry point. It:
- Connects to SDDM signals (`onLoginFailed` clears password, shows error rect)
- Lays out: session picker (top-left) → user+password+login column (center) → power buttons (bottom-center) → clock (top-right)
- Drives the clock with a 500ms repeating `Timer`

**SimpleControls** are imported with `import "SimpleControls" as Simple` and used as `Simple.Button` / `Simple.ComboBox`. They are thin style wrappers — no logic except `ComboBox.getValue()` which safely returns the selected session/user name with index-bounds fallback.

## Visual constants

All controls share the same palette — edit `Main.qml` properties to retheme globally:

| Property               | Value                |
|------------------------|----------------------|
| `backgroundColor`      | `Qt.rgba(0,0,0,0.4)` |
| `hoverBackgroundColor` | `Qt.rgba(0,0,0,0.6)` |
| Border                 | `Qt.rgba(1,1,1,0.4)` |
| Text                   | `"white"`            |
| Radius                 | `3`                  |

## SDDM bindings available in QML

`sddm.login(user, password, sessionIndex)`, `sddm.suspend()`, `sddm.reboot()`, `sddm.powerOff()`, `sddm.hibernate()`, `sddm.canSuspend`, `sddm.canHibernate`, `sddm.canReboot`, `sddm.canPowerOff`. Models: `userModel`, `sessionModel`.

## Current state (2026.05.10)

Theme is fully working with both Qt5.15 (`sddm-greeter`, X11) and Qt6 (`sddm-greeter-qt6`, Wayland). Key files: `Main.qml` (root `Item`, `Repeater+screenModel` background), `SceneBackground.qml` (breeze-derived, pure QtQuick). All imports at `2.15`.

Next: consider merging this repo's code back into the original `kiro-sddm-simplicity` (non-qt6) repo, since the Qt5/Qt6 distinction is now moot.

## Git helpers

- `up.sh` — stages everything, commits with message "update", pushes to origin
- `setup-edu.sh` — configures git remote to use SSH key alias `git@github.com-edu`
