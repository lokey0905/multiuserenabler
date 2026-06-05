# Android MultiUser Enabler

> 中文版: [README.md](README.md)

A Magisk module that enables Android's multi-user UI on ROMs that still support the feature, raises the user creation limit, and tries to start existing non-owner users after boot.

This module does not create users or work profiles by itself. Its role is to provide the multi-user system properties and the boot-time start flow. User/profile creation, profile management, and creation-limit bypasses should be handled by companion tools when needed.

## Features

- Enables Android multi-user UI: `fw.show_multiuserui=1`
- Raises the user creation limit: default `fw.max_users=50`
- Waits for boot completion, then lists all Android users
- Marks normal non-owner users as setup / provisioned before running `am start-user`
- On Xiaomi devices, removes `com.android.updater` for normal users to reduce OTA interference
- For special high-number users `>=999`, such as Xiaomi Second Space / XSpace, only runs `am start-user` and does not modify setup flags or package state
- Writes a small boot log for verification and troubleshooting

## Recommended Companion Projects

| Project | Purpose | Suggested use |
| --- | --- | --- |
| [lokey0905/Multiisland](https://github.com/lokey0905/Multiisland) | Multi-Island / multiple work-profile scenarios | Let Multiisland handle the profile / Island-side creation and management flow; use this module to expose the multi-user UI and try to start users after boot. |
| [icepony/AlwaysCreateUser](https://github.com/icepony/AlwaysCreateUser) | Xposed module for bypassing Android user / profile creation limits | Recommended when Android reports `Maximum user limit is reached`, `Cannot add more managed profiles`, or similar user/profile creation failures. |

Suggested responsibility split:

1. If you need to bypass user or profile creation limits, prepare an Xposed / LSPosed environment and enable AlwaysCreateUser.
2. If you need multiple Island / work-profile management, use Multiisland for the profile-side flow.
3. Install this Magisk module to expose the multi-user UI and try to start existing users after each boot.

## Requirements

- Rooted Android device
- Magisk v20.4 or newer
- A ROM / framework that still supports Android multi-user functionality
- Xposed / LSPosed or a similar environment if you also want to use AlwaysCreateUser

## Installation

1. Package this project as a Magisk flashable ZIP. The ZIP root must keep `module.prop`, `system.prop`, `service.sh`, and `META-INF/`.
2. Open the Magisk app and go to module installation.
3. Select and install the ZIP.
4. Reboot the device.
5. Create users / profiles through system settings, Multiisland, or another profile manager as needed.

## Verification

From a computer with adb:

```cmd
adb shell su -c "getprop fw.show_multiuserui"
adb shell su -c "getprop fw.max_users"
adb shell su -c "pm list users"
adb shell su -c "pm get-max-running-users"
adb shell su -c "cat /data/local/tmp/multiuserenabler.log"
```

Expected state:

- `fw.show_multiuserui` should be `1`
- `fw.max_users` should match `system.prop`; the default is `50`
- `pm list users` should show the users / profiles that already exist
- The log should show user parsing, Xiaomi OTA handling, and `am start-user` results after boot

## Logging

- Log file: `/data/local/tmp/multiuserenabler.log`
- Log tag: `MultiUserEnabler`

If auto-start fails, check the `am start-user` return code and output for the affected user in the log first.

## Troubleshooting

- Multi-user UI does not appear: verify that `getprop fw.show_multiuserui` returns `1`, then check whether your ROM hides the multi-user entry elsewhere.
- Many users can be created but not started: `fw.max_users` only controls creation. Check the concurrent running-user limit with `pm get-max-running-users`.
- `am start-user` fails: inspect `/data/local/tmp/multiuserenabler.log` and check whether the system running-user limit has been reached.
- More profiles cannot be created: this is usually outside this module's scope. Use AlwaysCreateUser when a creation-limit bypass is needed.
- Apps inside Island / managed profiles remain disabled or suspended: profile-owner / DPM policy can still override root package commands; inspect `dumpsys device_policy`.
- Xiaomi OTA app is missing from normal users: this is the current expected behavior of `service.sh`.

## Project Structure

- `module.prop`: Magisk module metadata
- `system.prop`: Multi-user system property overrides
- `service.sh`: Boot-time user start, Xiaomi OTA handling, and logging script
- `META-INF/com/google/android/*`: Files required for Magisk installation

## Notes

- Multi-user support varies heavily across vendors, Android versions, and ROMs. This module is not guaranteed to work on every device.
- Running more users increases memory usage, background services, and battery drain.
- This module does not bypass every framework or device-policy restriction. Use dedicated tools for user/profile creation limits and managed-profile policy behavior.
