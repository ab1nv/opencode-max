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

# ─── Installation mode ─────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}Where do you want to install OpenCode MAX?${NC}"
echo ""
echo -e "  ${BOLD}1)${NC} ${GREEN}Current project${NC} — Install to ./opencode.json & ./.opencode/"
echo -e "  ${BOLD}2)${NC} ${BLUE}Global config${NC}   — Install to ~/.config/opencode/"
echo -e "  ${BOLD}3)${NC} ${PURPLE}Both${NC}            — Install globally + copy to current project"
echo ""
read -rp "Choose (1/2/3): " -n 1 INSTALL_MODE
echo ""

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
}

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
echo -e "${YELLOW}Tip: Run ${BOLD}/help${NC}${YELLOW} inside OpenCode to see all commands.${NC}"
echo ""
