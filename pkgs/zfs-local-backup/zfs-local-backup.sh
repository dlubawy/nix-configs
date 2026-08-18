# ==========================================
# USAGE & ARGUMENTS
# ==========================================
usage() {
    echo "Usage: $0 <source_pool> <target_pool> [dry_run]"
    echo ""
    echo "Arguments:"
    echo "  source_pool   The ZFS pool to sync FROM (e.g., tank)"
    echo "  target_pool   The ZFS pool to sync TO (e.g., backup)"
    echo "  dry_run       0 to execute, 1 to dry-run (Default: 1)"
    exit 1
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage
fi

SOURCE_POOL="$1"
TARGET_POOL="$2"
DRY_RUN="${3:-1}"

# ==========================================
# CONFIGURATION
# ==========================================
SNAP_PATTERN="zfs-auto-snap_monthly-"

log() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

run_send() {
    local type="$1"
    local dataset="$2"
    local snap1="$3"
    local snap2="$4"

    if [ "$DRY_RUN" -eq 1 ]; then
        if [ "$type" = "full" ]; then
            log "[DRY RUN] zfs send \"${dataset}@${snap2}\" | zfs receive -F -d \"${TARGET_POOL}\""
        else
            log "[DRY RUN] zfs send -i \"${dataset}@${snap1}\" \"${dataset}@${snap2}\" | zfs receive -F -d \"${TARGET_POOL}\""
        fi
    else
        if [ "$type" = "full" ]; then
            log "[EXEC] Sending full: ${dataset}@${snap2}"
            zfs send "${dataset}@${snap2}" | zfs receive -F -d "${TARGET_POOL}"
        else
            log "[EXEC] Sending incremental: ${dataset}@${snap1} -> ${snap2}"
            zfs send -i "${dataset}@${snap1}" "${dataset}@${snap2}" | zfs receive -F -d "${TARGET_POOL}"
        fi
    fi
}

run_destroy() {
    local target="$1"
    if [ "$DRY_RUN" -eq 1 ]; then
        log "[DRY RUN] zfs destroy \"$target\""
    else
        log "[EXEC] zfs destroy \"$target\""
        zfs destroy "$target"
    fi
}

# ------------------------------------------
# STEP 1: ZFS Send (Source -> Target)
# ------------------------------------------
log "Starting ZFS sync phase..."

# Get all matching snapshots on SOURCE_POOL recursively
SNAPS_A=$(zfs list -t snapshot -H -o name -s creation -r "$SOURCE_POOL" 2>/dev/null | grep "@${SNAP_PATTERN}" || true)

if [ -z "$SNAPS_A" ]; then
    zfs list -H -o name "$SOURCE_POOL" >/dev/null 2>&1 || { log "ERROR: ${SOURCE_POOL} not available/imported."; exit 1; }
    log "No monthly snapshots found on ${SOURCE_POOL}. Exiting."
    exit 0
fi

# Extract unique dataset names on SOURCE_POOL
DATASETS=$(echo "$SNAPS_A" | awk -F'@' '{print $1}' | sort -u)

# Iterate over each dataset independently
while IFS= read -r src_ds; do
    [ -z "$src_ds" ] && continue

    # Derive the equivalent target dataset name
    if [ "$src_ds" = "$SOURCE_POOL" ]; then
        tgt_ds="$TARGET_POOL"
    else
        tgt_ds="${TARGET_POOL}${src_ds#"$SOURCE_POOL"}"
    fi

    log "Processing dataset: $src_ds"

    # Exact match awk filter to safely grab snaps for THIS source dataset only
    ds_snaps_A=$(echo "$SNAPS_A" | awk -F'@' -v ds="$src_ds" '$1 == ds {print $2}')

    # Check what snaps exist on THIS target dataset (suppressing error if target dataset isn't created yet)
    ds_snaps_B=$(zfs list -t snapshot -H -o name -s creation -d 1 "$tgt_ds" 2>/dev/null | grep "@${SNAP_PATTERN}" | awk -F'@' '{print $2}' || true)

    PREV_SNAP=""
    for snap in $ds_snaps_A; do
        if echo "$ds_snaps_B" | grep -qFx "$snap"; then
            # Exists on target. We can use it as a base for the next incremental send.
            PREV_SNAP="$snap"
        else
            # Does not exist on target. Send it.
            if [ -n "$PREV_SNAP" ]; then
                run_send "incremental" "$src_ds" "$PREV_SNAP" "$snap"
            else
                run_send "full" "$src_ds" "" "$snap"
            fi
            PREV_SNAP="$snap"
        fi
    done
done <<< "$DATASETS"

# ------------------------------------------
# STEP 2: ZFS Cleanup (Remove from Target if not on Source)
# ------------------------------------------
log "Starting ZFS cleanup phase..."

# Refresh the recursive snapshot lists just in case new ones were successfully transferred
SNAPS_A_POST=$(zfs list -t snapshot -H -o name -s creation -r "$SOURCE_POOL" 2>/dev/null | grep "@${SNAP_PATTERN}" || true)
SNAPS_B_POST=$(zfs list -t snapshot -H -o name -s creation -r "$TARGET_POOL" 2>/dev/null | grep "@${SNAP_PATTERN}" || true)

# Critical safety check: if SOURCE_POOL has zero snapshots now, it might be offline.
if [ -z "$SNAPS_A_POST" ]; then
    log "WARNING: No monthly snapshots found on ${SOURCE_POOL} after sync."
    log "Aborting cleanup phase to prevent accidental mass deletion on ${TARGET_POOL}!"
    exit 1
fi

log "Identifying snapshots on ${TARGET_POOL} that are NOT on ${SOURCE_POOL}..."

while IFS= read -r full_snap_b; do
    [ -z "$full_snap_b" ] && continue

    # Strip the TARGET_POOL prefix to get the relative path
    rel_snap="${full_snap_b#"${TARGET_POOL}"}"

    # Reconstruct what the source snapshot string should look like
    expected_src_snap="${SOURCE_POOL}${rel_snap}"

    # Literal string match (-qFx) against the source list
    if ! echo "$SNAPS_A_POST" | grep -qFx "$expected_src_snap"; then
        log "Snapshot ${expected_src_snap} no longer exists on ${SOURCE_POOL}. Removing from ${TARGET_POOL}..."
        run_destroy "$full_snap_b"
    fi
done <<< "$SNAPS_B_POST"

log "Process completed."
