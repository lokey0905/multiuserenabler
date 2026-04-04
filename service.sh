#!/system/bin/sh
MODTAG="MultiUserUIEnabler"
LOGFILE="/data/local/tmp/multiuseruienabler.log"

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

# Give framework/user services extra time to settle
sleep 10

CURRENT_USER="$(am get-current-user 2>/dev/null | tr -d '\r')"
log_msg "Boot completed. Current user: ${CURRENT_USER}"

# Parse user IDs from `pm list users`
USER_IDS="$(pm list users 2>/dev/null \
  | sed -n 's/.*{\([0-9][0-9]*\):.*/\1/p' \
  | sort -n \
  | uniq)"

if [ -z "$USER_IDS" ]; then
  log_msg "No users found from pm list users"
  exit 0
fi

for user_id in $USER_IDS; do
  # Skip system owner user 0
  if [ "$user_id" = "0" ]; then
    continue
  fi

  log_msg "Attempting to start user $user_id"
  OUT="$(am start-user "$user_id" 2>&1)"
  RC=$?
  log_msg "am start-user $user_id => rc=$RC, out=$OUT"
done

exit 0
