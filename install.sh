#!/usr/bin/env bash
# memctl installer — Linux / macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/vdg-solutions/memctl-releases/master/install.sh | sh
set -euo pipefail

REPO="vdg-solutions/memctl-releases"
PREFIX="${MEMCTL_PREFIX:-$HOME/.local/bin}"

uname_s=$(uname -s | tr '[:upper:]' '[:lower:]')
uname_m=$(uname -m)

case "${uname_s}-${uname_m}" in
  linux-x86_64)   RID=linux-x64   ;;
  darwin-arm64)   RID=osx-arm64   ;;
  darwin-aarch64) RID=osx-arm64   ;;
  darwin-x86_64)  RID=osx-x64     ;;
  *) echo "Unsupported platform: ${uname_s}-${uname_m}" >&2; exit 1 ;;
esac

echo "[memctl] Resolving latest release..."
LATEST=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | head -1 | cut -d'"' -f4)
if [[ -z "$LATEST" ]]; then
  echo "Failed to resolve latest release. Check https://github.com/${REPO}/releases" >&2
  exit 1
fi

VER="${LATEST#v}"
ASSET="memctl-${RID}-${VER}.tar.gz"
URL="https://github.com/${REPO}/releases/download/${LATEST}/${ASSET}"

TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

echo "[memctl] Downloading ${ASSET}..."
curl -fL --progress-bar -o "${TMP}/${ASSET}" "${URL}"

mkdir -p "${PREFIX}"
echo "[memctl] Extracting to ${PREFIX}..."
tar -xzf "${TMP}/${ASSET}" -C "${TMP}"
mv "${TMP}/memctl" "${PREFIX}/memctl"
chmod +x "${PREFIX}/memctl"

if [[ -f "${TMP}/SKILL.md" ]]; then
  mkdir -p "${HOME}/.claude/skills/memctl"
  cp "${TMP}/SKILL.md" "${HOME}/.claude/skills/memctl/SKILL.md"
  echo "[memctl] Installed Claude Code skill at ~/.claude/skills/memctl/SKILL.md"
fi

echo ""
echo "[memctl] Installed: ${PREFIX}/memctl (${LATEST})"
case ":$PATH:" in
  *":${PREFIX}:"*) ;;
  *) echo "[memctl] WARN: ${PREFIX} not on PATH. Add to your shell rc:"
     echo "  export PATH=\"${PREFIX}:\$PATH\"" ;;
esac

"${PREFIX}/memctl" --version || true
