#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# OpenCode MAX — Installation Script
# Copies the entire configuration to your project or global config.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -a UPDATE_CONFLICTS=()
UPDATE_ADDED=0
UPDATE_UNCHANGED=0

safe_update_file() {
    local src="$1"
    local dst="$2"
    local label="$3"

    mkdir -p "$(dirname "$dst")"

    if [[ ! -f "$dst" ]]; then
        cp "$src" "$dst"
        ((UPDATE_ADDED++))
        echo -e "${GREEN}  [ADD] ${label}${NC}"
        return 0
    fi

    if cmp -s "$src" "$dst"; then
        ((UPDATE_UNCHANGED++))
        return 0
    fi

    UPDATE_CONFLICTS+=("$label")
    echo -e "${YELLOW}  [CONFLICT] ${label}${NC}"
    return 1
}

safe_update_tree() {
    local src_root="$1"
    local dst_root="$2"
    local label_root="$3"

    [[ -d "$src_root" ]] || return 0

    while IFS= read -r -d '' src_file; do
        local rel_path="${src_file#$src_root/}"
        safe_update_file "$src_file" "$dst_root/$rel_path" "$label_root/$rel_path"
    done < <(find "$src_root" -type f -print0)
}

print_update_summary() {
    echo ""
    echo -e "${BOLD}${GREEN}══════════════════════════════════════════${NC}"
    echo -e "${BOLD}${GREEN}        OpenCode MAX update summary${NC}"
    echo -e "${BOLD}${GREEN}══════════════════════════════════════════${NC}"
    echo -e "${GREEN}Added files:${NC} ${UPDATE_ADDED}"
    echo -e "${GREEN}Unchanged files:${NC} ${UPDATE_UNCHANGED}"
    echo -e "${YELLOW}Conflicts:${NC} ${#UPDATE_CONFLICTS[@]}"

    if (( ${#UPDATE_CONFLICTS[@]} > 0 )); then
        echo ""
        echo -e "${YELLOW}The following files differ from the new version and were NOT overwritten:${NC}"
        for conflict in "${UPDATE_CONFLICTS[@]}"; do
            echo "  - ${conflict}"
        done
        echo ""
        echo -e "${YELLOW}Please merge these files manually.${NC}"
    fi
}

echo -e "${BOLD}${PURPLE}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║         OpenCode MAX Installer          ║"
echo "  ║     God-Tier AI Coding Configuration     ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ─── Check prerequisites ───────────────────────────────────────────────────
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

install_project() {
    local target_dir="$1"
    echo -e "\n${CYAN}Installing to project: ${target_dir}${NC}"

    # Copy opencode.json
    cp "${SCRIPT_DIR}/opencode.json" "${target_dir}/opencode.json"
    echo -e "${GREEN}  ✓ opencode.json${NC}"

    # Copy tui.json
    cp "${SCRIPT_DIR}/tui.json" "${target_dir}/tui.json"
    echo -e "${GREEN}  ✓ tui.json${NC}"

    # Copy AGENTS.md
    cp "${SCRIPT_DIR}/AGENTS.md" "${target_dir}/AGENTS.md"
    echo -e "${GREEN}  ✓ AGENTS.md${NC}"

    # Copy .opencode directory
    mkdir -p "${target_dir}/.opencode"
    cp -r "${SCRIPT_DIR}/.opencode/"* "${target_dir}/.opencode/" 2>/dev/null || true
    echo -e "${GREEN}  [OK] .opencode/ (agents, commands, skills, themes, tools)${NC}"

    # Copy prompts
    mkdir -p "${target_dir}/prompts"
    cp -r "${SCRIPT_DIR}/prompts/"* "${target_dir}/prompts/" 2>/dev/null || true
    echo -e "${GREEN}  [OK] prompts/ (agent system prompts)${NC}"
}

update_project() {
    local target_dir="$1"
    echo -e "\n${CYAN}Updating project (safe mode): ${target_dir}${NC}"

    safe_update_file "${SCRIPT_DIR}/opencode.json" "${target_dir}/opencode.json" "opencode.json"
    safe_update_file "${SCRIPT_DIR}/tui.json" "${target_dir}/tui.json" "tui.json"
    safe_update_file "${SCRIPT_DIR}/AGENTS.md" "${target_dir}/AGENTS.md" "AGENTS.md"
    safe_update_tree "${SCRIPT_DIR}/.opencode" "${target_dir}/.opencode" ".opencode"
    safe_update_tree "${SCRIPT_DIR}/prompts" "${target_dir}/prompts" "prompts"
}

install_global() {
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
    echo -e "\n${CYAN}Installing globally to: ${config_dir}${NC}"

    mkdir -p "${config_dir}"

    # Copy global config
    cp "${SCRIPT_DIR}/opencode.json" "${config_dir}/opencode.json"
    echo -e "${GREEN}  [OK] opencode.json${NC}"

    # Copy tui.json
    cp "${SCRIPT_DIR}/tui.json" "${config_dir}/tui.json"
    echo -e "${GREEN}  [OK] tui.json${NC}"

    # Copy AGENTS.md as global rules
    cp "${SCRIPT_DIR}/AGENTS.md" "${config_dir}/AGENTS.md"
    echo -e "${GREEN}  [OK] AGENTS.md (global rules)${NC}"

    # Copy themes
    mkdir -p "${config_dir}/themes"
    cp -r "${SCRIPT_DIR}/.opencode/themes/"* "${config_dir}/themes/" 2>/dev/null || true
    echo -e "${GREEN}  [OK] themes/ (Gruvbox MAX)${NC}"

    # Copy agents
    mkdir -p "${config_dir}/agents"
    cp -r "${SCRIPT_DIR}/.opencode/agents/"* "${config_dir}/agents/" 2>/dev/null || true
    echo -e "${GREEN}  [OK] agents/ (grill-me, perf-profiler, changelog)${NC}"

    # Copy commands
    mkdir -p "${config_dir}/commands"
    cp -r "${SCRIPT_DIR}/.opencode/commands/"* "${config_dir}/commands/" 2>/dev/null || true
    echo -e "${GREEN}  [OK] commands/ (pre-commit, overview, explain, diff-summary)${NC}"

    # Copy skills
    mkdir -p "${config_dir}/skills"
    cp -r "${SCRIPT_DIR}/.opencode/skills/"* "${config_dir}/skills/" 2>/dev/null || true
    echo -e "${GREEN}  [OK] skills/ (plan-first, tdd, code-review, git-commit, debug-loop, to-prd)${NC}"

    # Copy custom tools
    mkdir -p "${config_dir}/tools"
    cp -r "${SCRIPT_DIR}/.opencode/tools/"* "${config_dir}/tools/" 2>/dev/null || true
    echo -e "${GREEN}  [OK] tools/ (handoff, run-checks)${NC}"

    # Copy prompts
    mkdir -p "${config_dir}/prompts"
    cp -r "${SCRIPT_DIR}/prompts/"* "${config_dir}/prompts/" 2>/dev/null || true
    echo -e "${GREEN}  [OK] prompts/ (agent system prompts)${NC}"
}

update_global() {
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
    echo -e "\n${CYAN}Updating global config (safe mode): ${config_dir}${NC}"

    safe_update_file "${SCRIPT_DIR}/opencode.json" "${config_dir}/opencode.json" "opencode.json"
    safe_update_file "${SCRIPT_DIR}/tui.json" "${config_dir}/tui.json" "tui.json"
    safe_update_file "${SCRIPT_DIR}/AGENTS.md" "${config_dir}/AGENTS.md" "AGENTS.md"
    safe_update_tree "${SCRIPT_DIR}/.opencode/themes" "${config_dir}/themes" "themes"
    safe_update_tree "${SCRIPT_DIR}/.opencode/agents" "${config_dir}/agents" "agents"
    safe_update_tree "${SCRIPT_DIR}/.opencode/commands" "${config_dir}/commands" "commands"
    safe_update_tree "${SCRIPT_DIR}/.opencode/skills" "${config_dir}/skills" "skills"
    safe_update_tree "${SCRIPT_DIR}/.opencode/tools" "${config_dir}/tools" "tools"
    safe_update_tree "${SCRIPT_DIR}/prompts" "${config_dir}/prompts" "prompts"
}

# ─── Installation mode ─────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}What do you want to do?${NC}"
echo ""
echo -e "  ${BOLD}1)${NC} ${GREEN}Current project${NC} — Install to ./opencode.json & ./.opencode/"
echo -e "  ${BOLD}2)${NC} ${BLUE}Global config${NC}   — Install to ~/.config/opencode/"
echo -e "  ${BOLD}3)${NC} ${PURPLE}Both${NC}            — Install globally + copy to current project"
echo -e "  ${BOLD}4)${NC} ${YELLOW}Update${NC}          — Safe update (won't overwrite modified files)"
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
        echo -e "${CYAN}Safe update mode (non-destructive)${NC}"
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

# ─── Post-install ───────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}══════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}      OpenCode MAX installed!${NC}"
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
echo -e "${CYAN}Updates:${NC}"
echo -e "  ${BOLD}Re-run ./install.sh${NC}            — Choose option 4 for safe updates"
echo ""
echo -e "${YELLOW}Tip: Run ${BOLD}/help${NC}${YELLOW} inside OpenCode to see all commands.${NC}"
echo ""
