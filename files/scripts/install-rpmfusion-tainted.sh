#!/usr/bin/env bash
# Installs rpmfusion-free-release-tainted (enables free-tainted subrepo for libdvdcss).
# RPM Fusion ships a rawhide repo file (for the next Fedora) which dnf picks up
# and resolves to the wrong version; --disablerepo forces the current-release package.
set -euo pipefail

dnf5 install -y --disablerepo='rpmfusion-*-rawhide' rpmfusion-free-release-tainted
