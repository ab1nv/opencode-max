#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# OpenCode MAX — Installation Script
# https://github.com/ab1nv/opencode-max
# Author: Abhinav Singh (ab1nv)
#
# Copies the entire configuration to your project or global config.
# Supports smart manifest-based updates that preserve your customizations.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ─── Version ──────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(cat "${SCRIPT_DIR}/VERSION" 2>/dev/null || echo "unknown")"

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'

# ─── Manifest helpers ─────────────────────────────────────────────────────────
# The manifest stores: version + sha256 hash of every file at install time.
# This enables true 3-way merge on update:
#   base  = hash in manifest (what was installed)
#   ours  = current file on disk
#   theirs = new upstream file
#
# If ours == base  → user never touched it  → safe to overwrite
# If ours != base && theirs == base → user edited, upstream didn't → keep ours
# If ours != base && theirs != base → both changed → conflict

sha256_file() {
    sha256sum "$1" 2>/dev/null | awk '{print $1}'
}

manifest_path() {
    # $1 = install root (project dir or global config dir)
    echo "$1/.opencode-max.manifest"
}

manifest_write() {
    local root="$1"
    local version="$2"
    local manifest
    manifest="$(manifest_path "$root")"

    echo "# OpenCode MAX manifest — do not edit manually" > "$manifest"
    echo "VERSION=${version}" >> "$manifest"
    echo "TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$manifest"
}

manifest_add_file() {
    local root="$1"
    local abs_path="$2"
    local rel_key="$3"
    local manifest
    manifest="$(manifest_path "$root")"
    local hash
    hash="$(sha256_file "$abs_path")"
    echo "FILE:${rel_key}=${hash}" >> "$manifest"
}

manifest_get_hash() {
    # Returns the hash stored in the manifest for a given file key
    local root="$1"
    local rel_key="$2"
    local manifest
    manifest="$(manifest_path "$root")"
    [[ -f "$manifest" ]] || { echo ""; return; }
    grep "^FILE:${rel_key}=" "$manifest" 2>/dev/null | cut -d= -f2 || echo ""
}

manifest_get_version() {
    local root="$1"
    local manifest
    manifest="$(manifest_path "$root")"
    [[ -f "$manifest" ]] || { echo "none"; return; }
    grep "^VERSION=" "$manifest" 2>/dev/null | cut -d= -f2 || echo "none"
}

# ─── Update tracking ──────────────────────────────────────────────────────────
declare -a UPDATE_CONFLICTS=()
declare -a UPDATE_SKIPPED=()
UPDATE_ADDED=0
UPDATE_OVERWRITTEN=0
UPDATE_UNCHANGED=0

# ─── Smart merge: copy src→dst using 3-way logic ──────────────────────────────
smart_update_file() {
    local src="$1"
    local dst="$2"
    local rel_key="$3"
    local install_root="$4"

    mkdir -p "$(dirname "$dst")"

    # File doesn't exist at destination → always add
    if [[ ! -f "$dst" ]]; then
        cp "$src" "$dst"
        manifest_add_file "$install_root" "$dst" "$rel_key"
        ((UPDATE_ADDED++))
        echo -e "${GREEN}  [ADD]       ${rel_key}${NC}"
        return
    fi

    local hash_theirs hash_ours hash_base
    hash_theirs="$(sha256_file "$src")"
    hash_ours="$(sha256_file "$dst")"
    hash_base="$(manifest_get_hash "$install_root" "$rel_key")"

    # Files are identical → nothing to do
    if [[ "$hash_theirs" == "$hash_ours" ]]; then
        ((UPDATE_UNCHANGED++))
        return
    fi

    # No manifest entry for this file — treat it as a conflict (unknown baseline)
    if [[ -z "$hash_base" ]]; then
        UPDATE_CONFLICTS+=("${rel_key} [no baseline — run install first]")
        echo -e "${YELLOW}  [CONFLICT]  ${rel_key} ${DIM}(no baseline in manifest)${NC}"
        return
    fi

    if [[ "$hash_ours" == "$hash_base" ]]; then
        # User never modified this file → safe to overwrite with upstream changes
        cp "$src" "$dst"
        manifest_add_file "$install_root" "$dst" "$rel_key"
        ((UPDATE_OVERWRITTEN++))
        echo -e "${CYAN}  [UPDATE]    ${rel_key}${NC}"
    elif [[ "$hash_theirs" == "$hash_base" ]]; then
        # Upstream didn't change this file, but user did → keep user's version
        UPDATE_SKIPPED+=("$rel_key")
        echo -e "${BLUE}  [KEPT]      ${rel_key} ${DIM}(your customization preserved)${NC}"
    else
        # Both user AND upstream changed the file → true conflict
        # We use git merge-file for text files, but for JSON files we use a custom
        # Node.js 3-way deep merge algorithm to preserve structure and AI settings without breaking JSON.
        local tmp_base tmp_merged
        tmp_base="$(mktemp)"
        tmp_merged="$(mktemp)"
        
        # Reconstruct base from git if possible, else fallback to src
        if git -C "$SCRIPT_DIR" cat-file -e HEAD:"${src#$SCRIPT_DIR/}" 2>/dev/null; then
            git -C "$SCRIPT_DIR" show "HEAD~1:${src#$SCRIPT_DIR/}" > "$tmp_base" 2>/dev/null || cp "$src" "$tmp_base"
        else
            cp "$src" "$tmp_base"
        fi
        
        local merge_status=0
        if [[ "$src" == *.json ]] && command -v node &>/dev/null; then
            # Smart JSON deep merge
            cat << 'EOF' > "$tmp_merged.js"
const fs = require('fs');
function strip(s) { return s.replace(/\\"|"(?:\\"|[^"])*"|(\/\/.*|\/\*[\s\S]*?\*\/)/g, (m, g) => g ? "" : m); }
try {
  const bStr = fs.readFileSync(process.argv[2], 'utf8');
  const oStr = fs.readFileSync(process.argv[3], 'utf8');
  const tStr = fs.readFileSync(process.argv[4], 'utf8');
  const base = JSON.parse(strip(bStr));
  const ours = JSON.parse(strip(oStr));
  const theirs = JSON.parse(strip(tStr));
  function merge(b, o, t) {
    if (o !== null && typeof o === 'object' && !Array.isArray(o) &&
        t !== null && typeof t === 'object' && !Array.isArray(t)) {
      const res = {};
      const keys = new Set([...Object.keys(b||{}), ...Object.keys(o), ...Object.keys(t)]);
      for (let k of keys) {
        const v = merge(b ? b[k] : undefined, o[k], t[k]);
        if (v !== undefined) res[k] = v;
      }
      return res;
    } else {
      if (JSON.stringify(o) !== JSON.stringify(b)) return o === undefined ? undefined : o;
      if (JSON.stringify(t) !== JSON.stringify(b)) return t === undefined ? undefined : t;
      return b;
    }
  }
  const merged = merge(base, ours, theirs);
  let header = "";
  const lines = tStr.split('\n');
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (line.trim() === '{') {
      header += '{\n';
      for (let j = i + 1; j < lines.length; j++) {
        if (lines[j].trim().startsWith('//') || lines[j].trim() === '') header += lines[j] + '\n';
        else break;
      }
      break;
    } else {
      header += line + '\n';
    }
  }
  let outJson = JSON.stringify(merged, null, 2);
  outJson = outJson.replace(/^\{\n/, header);
  fs.writeFileSync(process.argv[5], outJson);
  process.exit(0);
} catch (e) {
  process.exit(1);
}
EOF
            node "$tmp_merged.js" "$tmp_base" "$dst" "$src" "$tmp_merged"
            merge_status=$?
            rm -f "$tmp_merged.js"
            
            if [[ $merge_status -eq 0 ]]; then
                cp "$tmp_merged" "$dst"
                manifest_add_file "$install_root" "$dst" "$rel_key"
                ((UPDATE_OVERWRITTEN++))
                echo -e "${GREEN}  [MERGED]    ${rel_key} ${DIM}(smart JSON deep merge)${NC}"
            else
                UPDATE_CONFLICTS+=("$rel_key")
                echo -e "${RED}  [ERROR]     ${rel_key} ${DIM}(JSON merge failed)${NC}"
            fi
        else
            # Standard text-based 3-way merge
            git merge-file -q -p "$dst" "$tmp_base" "$src" > "$tmp_merged" 2>/dev/null
            merge_status=$?
            
            if [[ $merge_status -eq 0 ]]; then
                cp "$tmp_merged" "$dst"
                manifest_add_file "$install_root" "$dst" "$rel_key"
                ((UPDATE_OVERWRITTEN++))
                echo -e "${GREEN}  [MERGED]    ${rel_key} ${DIM}(auto-merged cleanly)${NC}"
            elif [[ $merge_status -eq 1 ]]; then
                cp "$tmp_merged" "$dst"
                manifest_add_file "$install_root" "$dst" "$rel_key"
                UPDATE_CONFLICTS+=("$rel_key")
                echo -e "${YELLOW}  [CONFLICT]  ${rel_key} ${DIM}(merged 99%, added conflict markers)${NC}"
            else
                UPDATE_CONFLICTS+=("$rel_key")
                echo -e "${RED}  [ERROR]     ${rel_key} ${DIM}(merge algorithm failed)${NC}"
            fi
        fi
        
        rm -f "$tmp_base" "$tmp_merged"
    fi
}

smart_update_tree() {
    local src_root="$1"
    local dst_root="$2"
    local label_root="$3"
    local install_root="$4"

    [[ -d "$src_root" ]] || return 0

    while IFS= read -r -d '' src_file; do
        local rel_path="${src_file#$src_root/}"
        smart_update_file "$src_file" "$dst_root/$rel_path" "$label_root/$rel_path" "$install_root"
    done < <(find "$src_root" -type f -print0)
}

print_update_summary() {
    echo ""
    echo -e "${BOLD}${GREEN}══════════════════════════════════════════${NC}"
    echo -e "${BOLD}${GREEN}        OpenCode MAX — Update Summary${NC}"
    echo -e "${BOLD}${GREEN}══════════════════════════════════════════${NC}"
    echo -e "  ${GREEN}Added:${NC}      ${UPDATE_ADDED} new files"
    echo -e "  ${CYAN}Updated:${NC}    ${UPDATE_OVERWRITTEN} files (upstream changes applied)"
    echo -e "  ${BLUE}Kept:${NC}       ${#UPDATE_SKIPPED[@]} files (your customizations preserved)"
    echo -e "  ${DIM}Unchanged:${NC}  ${UPDATE_UNCHANGED} files"
    echo -e "  ${YELLOW}Conflicts:${NC}  ${#UPDATE_CONFLICTS[@]} files need manual review"

    if (( ${#UPDATE_SKIPPED[@]} > 0 )); then
        echo ""
        echo -e "${BLUE}Your customized files (not overwritten):${NC}"
        for f in "${UPDATE_SKIPPED[@]}"; do
            echo -e "  ${BLUE}✎ ${f}${NC}"
        done
    fi

    if (( ${#UPDATE_CONFLICTS[@]} > 0 )); then
        echo ""
        echo -e "${YELLOW}Conflicts — both you and upstream changed these files:${NC}"
        for f in "${UPDATE_CONFLICTS[@]}"; do
            echo -e "  ${YELLOW}⚠ ${f}${NC}"
        done
        echo ""
        echo -e "${YELLOW}To resolve: compare your version with the new upstream version in${NC}"
        echo -e "${YELLOW}${SCRIPT_DIR} and manually merge the changes you want to keep.${NC}"
    fi
}

# ─── Version check ────────────────────────────────────────────────────────────
check_for_update() {
    echo -e "${CYAN}Checking for updates...${NC}"

    # Fetch remote tags silently
    if ! git -C "$SCRIPT_DIR" fetch origin --tags --quiet 2>/dev/null; then
        echo -e "${YELLOW}  Could not reach GitHub — proceeding with local version.${NC}"
        return 1
    fi

    local remote_version
    # Try origin/master first, then main, then HEAD
    remote_version="$(git -C "$SCRIPT_DIR" show origin/master:VERSION 2>/dev/null | tr -d '[:space:]' || echo "")"
    if [[ -z "$remote_version" ]]; then
        remote_version="$(git -C "$SCRIPT_DIR" show origin/main:VERSION 2>/dev/null | tr -d '[:space:]' || echo "")"
    fi
    if [[ -z "$remote_version" ]]; then
        remote_version="$(git -C "$SCRIPT_DIR" show origin/HEAD:VERSION 2>/dev/null | tr -d '[:space:]' || echo "")"
    fi

    if [[ -z "$remote_version" ]]; then
        # No remote VERSION yet (likely initial push pending). Silently proceed.
        return 1
    fi

    if [[ "$remote_version" == "$VERSION" ]]; then
        echo -e "${GREEN}  ✓ You're on the latest version (v${VERSION})${NC}"
        return 1
    fi

    # Simple semver compare: treat version as dot-separated integers
    local local_ver remote_ver
    local_ver="$(echo "$VERSION" | tr '.' ' ')"
    remote_ver="$(echo "$remote_version" | tr '.' ' ')"

    local lmaj lmin lpat rmaj rmin rpat
    read -r lmaj lmin lpat <<< "$local_ver"
    read -r rmaj rmin rpat <<< "$remote_ver"

    if (( rmaj > lmaj || (rmaj == lmaj && rmin > lmin) || (rmaj == lmaj && rmin == lmin && rpat > lpat) )); then
        echo ""
        echo -e "${BOLD}${YELLOW}  ✦ New version available: v${remote_version} (you have v${VERSION})${NC}"
        echo ""
        read -rp "  Update now? (y/n) " -n 1 DO_UPDATE
        echo ""
        if [[ $DO_UPDATE =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}  Pulling changes from GitHub...${NC}"
            git -C "$SCRIPT_DIR" pull --ff-only origin HEAD 2>&1 | sed 's/^/  /'
            # Reload VERSION after pull
            VERSION="$(cat "${SCRIPT_DIR}/VERSION" 2>/dev/null || echo "unknown")"
            echo -e "${GREEN}  ✓ Updated to v${VERSION}${NC}"
            return 0
        else
            echo -e "${BLUE}  Keeping local version v${VERSION}${NC}"
            return 1
        fi
    else
        echo -e "${BLUE}  Local version v${VERSION} is ahead of remote — no update needed.${NC}"
        return 1
    fi
}

# ─── Install functions ────────────────────────────────────────────────────────
tracked_files() {
    # Emit all managed file paths relative to SCRIPT_DIR
    echo "opencode.json"
    echo "tui.json"
    echo "AGENTS.md"
    find "${SCRIPT_DIR}/.opencode" -type f | sed "s|${SCRIPT_DIR}/||"
    find "${SCRIPT_DIR}/prompts"   -type f | sed "s|${SCRIPT_DIR}/||"
}

install_project() {
    local target_dir="$1"
    echo -e "\n${CYAN}Installing to project: ${target_dir}${NC}"

    manifest_write "$target_dir" "$VERSION"

    cp "${SCRIPT_DIR}/opencode.json" "${target_dir}/opencode.json"
    manifest_add_file "$target_dir" "${target_dir}/opencode.json" "opencode.json"
    echo -e "${GREEN}  ✓ opencode.json${NC}"

    cp "${SCRIPT_DIR}/tui.json" "${target_dir}/tui.json"
    manifest_add_file "$target_dir" "${target_dir}/tui.json" "tui.json"
    echo -e "${GREEN}  ✓ tui.json${NC}"

    cp "${SCRIPT_DIR}/AGENTS.md" "${target_dir}/AGENTS.md"
    manifest_add_file "$target_dir" "${target_dir}/AGENTS.md" "AGENTS.md"
    echo -e "${GREEN}  ✓ AGENTS.md${NC}"

    mkdir -p "${target_dir}/.opencode"
    while IFS= read -r -d '' src_file; do
        local rel_path="${src_file#$SCRIPT_DIR/.opencode/}"
        local dst="${target_dir}/.opencode/${rel_path}"
        mkdir -p "$(dirname "$dst")"
        cp "$src_file" "$dst"
        manifest_add_file "$target_dir" "$dst" ".opencode/${rel_path}"
    done < <(find "${SCRIPT_DIR}/.opencode" -type f -print0)
    echo -e "${GREEN}  ✓ .opencode/ (agents, commands, skills, themes, tools)${NC}"

    mkdir -p "${target_dir}/prompts"
    while IFS= read -r -d '' src_file; do
        local rel_path="${src_file#$SCRIPT_DIR/prompts/}"
        local dst="${target_dir}/prompts/${rel_path}"
        mkdir -p "$(dirname "$dst")"
        cp "$src_file" "$dst"
        manifest_add_file "$target_dir" "$dst" "prompts/${rel_path}"
    done < <(find "${SCRIPT_DIR}/prompts" -type f -print0)
    echo -e "${GREEN}  ✓ prompts/ (agent system prompts)${NC}"

    echo -e "${DIM}  Manifest written: ${target_dir}/.opencode-max.manifest${NC}"
}

install_global() {
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
    echo -e "\n${CYAN}Installing globally to: ${config_dir}${NC}"
    mkdir -p "${config_dir}"

    manifest_write "$config_dir" "$VERSION"

    cp "${SCRIPT_DIR}/opencode.json" "${config_dir}/opencode.json"
    manifest_add_file "$config_dir" "${config_dir}/opencode.json" "opencode.json"
    echo -e "${GREEN}  ✓ opencode.json${NC}"

    cp "${SCRIPT_DIR}/tui.json" "${config_dir}/tui.json"
    manifest_add_file "$config_dir" "${config_dir}/tui.json" "tui.json"
    echo -e "${GREEN}  ✓ tui.json${NC}"

    cp "${SCRIPT_DIR}/AGENTS.md" "${config_dir}/AGENTS.md"
    manifest_add_file "$config_dir" "${config_dir}/AGENTS.md" "AGENTS.md"
    echo -e "${GREEN}  ✓ AGENTS.md (global rules)${NC}"

    for subdir in themes agents commands skills tools; do
        mkdir -p "${config_dir}/${subdir}"
        [[ -d "${SCRIPT_DIR}/.opencode/${subdir}" ]] || continue
        while IFS= read -r -d '' src_file; do
            local rel_path="${src_file#$SCRIPT_DIR/.opencode/$subdir/}"
            local dst="${config_dir}/${subdir}/${rel_path}"
            mkdir -p "$(dirname "$dst")"
            cp "$src_file" "$dst"
            manifest_add_file "$config_dir" "$dst" "${subdir}/${rel_path}"
        done < <(find "${SCRIPT_DIR}/.opencode/${subdir}" -type f -print0)
        echo -e "${GREEN}  ✓ ${subdir}/${NC}"
    done

    mkdir -p "${config_dir}/prompts"
    while IFS= read -r -d '' src_file; do
        local rel_path="${src_file#$SCRIPT_DIR/prompts/}"
        local dst="${config_dir}/prompts/${rel_path}"
        mkdir -p "$(dirname "$dst")"
        cp "$src_file" "$dst"
        manifest_add_file "$config_dir" "$dst" "prompts/${rel_path}"
    done < <(find "${SCRIPT_DIR}/prompts" -type f -print0)
    echo -e "${GREEN}  ✓ prompts/ (agent system prompts)${NC}"

    echo -e "${DIM}  Manifest written: ${config_dir}/.opencode-max.manifest${NC}"
}

update_project() {
    local target_dir="$1"
    local installed_version
    installed_version="$(manifest_get_version "$target_dir")"
    echo -e "\n${CYAN}Smart-updating project (v${installed_version} → v${VERSION}): ${target_dir}${NC}"

    smart_update_file "${SCRIPT_DIR}/opencode.json" "${target_dir}/opencode.json" "opencode.json" "$target_dir"
    smart_update_file "${SCRIPT_DIR}/tui.json"      "${target_dir}/tui.json"      "tui.json"      "$target_dir"
    smart_update_file "${SCRIPT_DIR}/AGENTS.md"     "${target_dir}/AGENTS.md"     "AGENTS.md"     "$target_dir"

    while IFS= read -r -d '' src_file; do
        local rel_path="${src_file#$SCRIPT_DIR/.opencode/}"
        smart_update_file "$src_file" "${target_dir}/.opencode/${rel_path}" ".opencode/${rel_path}" "$target_dir"
    done < <(find "${SCRIPT_DIR}/.opencode" -type f -print0)

    while IFS= read -r -d '' src_file; do
        local rel_path="${src_file#$SCRIPT_DIR/prompts/}"
        smart_update_file "$src_file" "${target_dir}/prompts/${rel_path}" "prompts/${rel_path}" "$target_dir"
    done < <(find "${SCRIPT_DIR}/prompts" -type f -print0)

    # Update version in manifest
    sed -i "s/^VERSION=.*/VERSION=${VERSION}/" "$(manifest_path "$target_dir")" 2>/dev/null || true
    sed -i "s/^TIMESTAMP=.*/TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)/" "$(manifest_path "$target_dir")" 2>/dev/null || true
}

update_global() {
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
    local installed_version
    installed_version="$(manifest_get_version "$config_dir")"
    echo -e "\n${CYAN}Smart-updating global config (v${installed_version} → v${VERSION}): ${config_dir}${NC}"

    smart_update_file "${SCRIPT_DIR}/opencode.json" "${config_dir}/opencode.json" "opencode.json" "$config_dir"
    smart_update_file "${SCRIPT_DIR}/tui.json"      "${config_dir}/tui.json"      "tui.json"      "$config_dir"
    smart_update_file "${SCRIPT_DIR}/AGENTS.md"     "${config_dir}/AGENTS.md"     "AGENTS.md"     "$config_dir"

    for subdir in themes agents commands skills tools; do
        [[ -d "${SCRIPT_DIR}/.opencode/${subdir}" ]] || continue
        while IFS= read -r -d '' src_file; do
            local rel_path="${src_file#$SCRIPT_DIR/.opencode/$subdir/}"
            smart_update_file "$src_file" "${config_dir}/${subdir}/${rel_path}" "${subdir}/${rel_path}" "$config_dir"
        done < <(find "${SCRIPT_DIR}/.opencode/${subdir}" -type f -print0)
    done

    while IFS= read -r -d '' src_file; do
        local rel_path="${src_file#$SCRIPT_DIR/prompts/}"
        smart_update_file "$src_file" "${config_dir}/prompts/${rel_path}" "prompts/${rel_path}" "$config_dir"
    done < <(find "${SCRIPT_DIR}/prompts" -type f -print0)

    sed -i "s/^VERSION=.*/VERSION=${VERSION}/" "$(manifest_path "$config_dir")" 2>/dev/null || true
    sed -i "s/^TIMESTAMP=.*/TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)/" "$(manifest_path "$config_dir")" 2>/dev/null || true
}

# ─── Banner ───────────────────────────────────────────────────────────────────
echo -e "${BOLD}${PURPLE}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║         OpenCode MAX Installer           ║"
echo "  ║     God-Tier AI Coding Configuration     ║"
printf "║          %-34s║\n" "Version v${VERSION}" ║
echo "  ║   github.com/ab1nv/opencode-max          ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ─── Check for updates from GitHub ────────────────────────────────────────────
check_for_update || true
echo ""

# ─── Check prerequisites ──────────────────────────────────────────────────────
check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo -e "${RED}[ERR] $1 is not installed${NC}"
        return 1
    else
        echo -e "${GREEN}[OK] $1 found${NC}"
        return 0
    fi
}

echo -e "${CYAN}Checking prerequisites...${NC}"
check_command "opencode" || {
    echo -e "${YELLOW}Warning: OpenCode is not installed. Install it first:${NC}"
    echo -e "  ${BOLD}curl -fsSL https://opencode.ai/install | bash${NC}"
    echo ""
    echo -e "${YELLOW}Or via npm:${NC}"
    echo -e "  ${BOLD}npm i -g opencode${NC}"
    echo ""
    read -rp "Continue without OpenCode? (y/n) " -n 1
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
}

# ─── Installation mode ────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}What do you want to do?${NC}"
echo ""
echo -e "  ${BOLD}1)${NC} ${GREEN}Current project${NC} — Install to ./opencode.json & ./.opencode/"
echo -e "  ${BOLD}2)${NC} ${BLUE}Global config${NC}   — Install to ~/.config/opencode/"
echo -e "  ${BOLD}3)${NC} ${PURPLE}Both${NC}            — Install globally + copy to current project"
echo -e "  ${BOLD}4)${NC} ${YELLOW}Update${NC}          — Smart update (preserves your customizations)"
echo ""
read -rp "Choose (1/2/3/4): " -n 1 INSTALL_MODE
echo ""

case $INSTALL_MODE in
    1)
        install_project "$(pwd)"
        ;;
    2)
        install_global
        ;;
    3)
        install_global
        install_project "$(pwd)"
        ;;
    4)
        echo ""
        echo -e "${CYAN}Smart update mode — your customized files will NOT be overwritten${NC}"
        echo -e "${CYAN}Which location should be updated?${NC}"
        echo ""
        echo -e "  ${BOLD}1)${NC} ${GREEN}Current project${NC}"
        echo -e "  ${BOLD}2)${NC} ${BLUE}Global config${NC}"
        echo -e "  ${BOLD}3)${NC} ${PURPLE}Both${NC}"
        echo ""
        read -rp "Choose (1/2/3): " -n 1 UPDATE_CHOICE
        echo ""

        case $UPDATE_CHOICE in
            1)
                update_project "$(pwd)"
                ;;
            2)
                update_global
                ;;
            3)
                update_global
                update_project "$(pwd)"
                ;;
            *)
                echo -e "${RED}Invalid option. Exiting.${NC}"
                exit 1
                ;;
        esac

        print_update_summary
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Exiting.${NC}"
        exit 1
        ;;
esac

# ─── Post-install ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}══════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}   OpenCode MAX v${VERSION} installed! 🚀${NC}"
echo -e "${BOLD}${GREEN}══════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Quick Start:${NC}"
echo -e "  ${BOLD}opencode${NC}                    — Launch OpenCode"
echo -e "  ${BOLD}Tab${NC}                         — Cycle agents (Build → Plan → Architect)"
echo -e "  ${BOLD}/review${NC}                     — Code review staged changes"
echo -e "  ${BOLD}/test${NC}                       — Run tests & analyze failures"
echo -e "  ${BOLD}/plan <task>${NC}                — Create implementation plan"
echo -e "  ${BOLD}/debug <issue>${NC}              — Systematic debugging"
echo -e "  ${BOLD}/security${NC}                   — Security audit"
echo -e "  ${BOLD}/commit${NC}                     — Generate commit message"
echo -e "  ${BOLD}@grill-me${NC}                   — Challenge your design decisions"
echo -e "  ${BOLD}@perf-profiler${NC}              — Performance analysis"
echo ""
echo -e "${CYAN}Stay updated:${NC}"
echo -e "  ${BOLD}./install.sh${NC}                — Re-run to check for updates & smart-update"
echo ""
echo -e "${YELLOW}Tip: Run ${BOLD}/help${NC}${YELLOW} inside OpenCode to see all commands.${NC}"
echo ""
