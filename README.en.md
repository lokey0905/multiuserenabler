# Android Multi-User Enabler (Magisk Module)

This is a Magisk module that enables the Android multi-user UI and attempts to auto-start existing secondary users after boot.

## Features

- Enables Android multi-user UI (`fw.show_multiuserui=1`)
- Sets max user count (default: `fw.max_users=5`)
- After boot completion, lists all users and tries to start non-owner users
- Writes simple logs for troubleshooting

## Project Structure

- `module.prop`: Module metadata (name, version, author)
- `system.prop`: System property overrides (multi-user UI and max users)
- `service.sh`: Boot-time script that starts other users
- `META-INF/com/google/android/*`: Files required for Magisk flashing/install

## Requirements

- Android device with Magisk module support
- Magisk v20.4 or newer (checked by installer script)
- ROM/device that actually supports multi-user functionality

## Installation

1. Package this project as a Magisk flashable ZIP (keep the current folder structure).
2. Open Magisk app and go to module installation.
3. Select and install the ZIP.
4. Reboot the device.

## Usage

1. After reboot, go to system settings for Users / Multiple users.
2. Create the secondary users you need.
3. On each boot, the module will try to start all non-owner users automatically.

## Logging & Troubleshooting

- Log file: `/data/local/tmp/multiuseruienabler.log`
- Log tag: `MultiUserUIEnabler`

If auto-start fails, check logs first and verify whether your ROM allows starting secondary users in the background.

## Customization

You can edit `system.prop` to tune limits:

- `fw.max_users=50` -> change to your preferred limit
- `fw.show_multiuserui=1` -> keep this as 1 to show multi-user UI

## Notes

- Multi-user support varies across vendors and Android versions.
- `fw.max_users` is the creation limit, not the number of users that can run at the same time.
- The real concurrent running-user limit is system-defined; use `pm get-max-running-users` as the source of truth.
- If you try to start more users than `pm get-max-running-users` allows, `am start-user` may fail or be rejected.
- Enabling more users can increase memory and battery usage.
- This module is not guaranteed to work on every ROM.

You can check the device limit with:

```sh
pm get-max-running-users
```
