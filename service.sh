#!/system/bin/sh
MODTAG="MultiUserEnabler"
LOGFILE="/data/local/tmp/multiuserenabler.log"
OTA_PKG="com.android.updater"

log_msg() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOGFILE"
  log -t "$MODTAG" "$1"
}

# Wait until Android reports boot completed
BOOT_WAIT=0
while [ "$(getprop sys.boot_completed)" != "1" ] && [ $BOOT_WAIT -lt 120 ]; do
  sleep 2
  BOOT_WAIT=$((BOOT_WAIT + 2))
done

# Give framework / settings providers extra time to settle
sleep 15

CURRENT_USER="$(am get-current-user 2>/dev/null | tr -d '\r')"
MANUFACTURER="$(getprop ro.product.manufacturer 2>/dev/null | tr -d '\r')"

log_msg "Boot completed. Current user: ${CURRENT_USER}"
log_msg "Manufacturer: ${MANUFACTURER}"

# Parse user IDs from `pm list users`
USER_IDS="$(pm list users 2>/dev/null \
  | sed -n 's/.*{\([0-9][0-9]*\):.*/\1/p' \
  | sort -n \
  | uniq)"

if [ -z "$USER_IDS" ]; then
  log_msg "No users found from pm list users"
  exit 0
fi

# Xiaomi: disable OTA updater for all normal users
if [ "$MANUFACTURER" = "Xiaomi" ] || [ "$MANUFACTURER" = "xiaomi" ] || [ "$MANUFACTURER" = "XIAOMI" ]; then
  log_msg "Xiaomi device detected, disabling OTA updater: ${OTA_PKG}"
  for user_id in $USER_IDS; do
    # Skip synthetic/high special users such as XSpace 999
    if [ "$user_id" -ge 999 ]; then
      continue
    fi

    OUT="$(pm uninstall -k --user "$user_id" "$OTA_PKG" 2>&1)"
    RC=$?
    log_msg "pm uninstall -k --user $user_id $OTA_PKG => rc=$RC, out=$OUT"
  done
else
  log_msg "Non-Xiaomi device, skip OTA disable"
fi

for user_id in $USER_IDS; do
  # Mark user/profile setup complete so MIUI recents/launcher won't hide its tasks.
  OUT="$(settings --user "$user_id" put secure user_setup_complete 1 2>&1)"
  RC=$?
  log_msg "settings --user $user_id put secure user_setup_complete 1 => rc=$RC, out=$OUT"

  OUT="$(settings --user "$user_id" put global device_provisioned 1 2>&1)"
  RC=$?
  log_msg "settings --user $user_id put global device_provisioned 1 => rc=$RC, out=$OUT"

  # Small delay before starting the user to reduce contention during boot.
  sleep 1
  OUT="$(am start-user "$user_id" 2>&1)"
  RC=$?
  log_msg "am start-user $user_id => rc=$RC, out=$OUT"
done

exit 0