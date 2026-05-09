#!/bin/bash

set -ouex pipefail

# Ensure the rtkit system user exists at runtime after bootc upgrades.
# systemd-sysusers.service has ConditionNeedsUpdate=/etc and is skipped on
# subsequent boots of the same deployment, leaving the rtkit user absent and
# causing rtkit-daemon to fail. A drop-in runs sysusers unconditionally before
# rtkit-daemon starts.

DROPIN_DIR=/usr/lib/systemd/system/rtkit-daemon.service.d
mkdir -p "${DROPIN_DIR}"
cat > "${DROPIN_DIR}/10-ensure-sysusers.conf" << 'EOF'
[Service]
ExecStartPre=/usr/bin/systemd-sysusers /usr/lib/sysusers.d/rtkit.conf
EOF
