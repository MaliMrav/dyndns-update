#!/usr/bin/env zsh
#
# bootstrap.zsh

###############################################################################
# dyndns-update Project Bootstrap
#
# Contributors: Vladimir Lekic & ChatGPT (OpenAI)
###############################################################################

set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"

###############################################################################
# Pretty printing
###############################################################################

info() {
    printf "\033[1;34m==>\033[0m %s\n" "$1"
}

success() {
    printf "\033[1;32m✔\033[0m %s\n" "$1"
}

warn() {
    printf "\033[1;33m⚠\033[0m %s\n" "$1"
}

###############################################################################
# Helpers
###############################################################################

create_dir() {

    local dir="$PROJECT_ROOT/$1"

    if [[ -d "$dir" ]]; then
        warn "Directory exists : $1"
    else
        mkdir -p "$dir"
        success "Created directory : $1"
    fi
}

create_file() {

    local file="$PROJECT_ROOT/$1"

    if [[ -f "$file" ]]; then
        warn "File exists      : $1"
    else
        touch "$file"
        success "Created file     : $1"
    fi
}

create_file_with_header() {
    local file="$PROJECT_ROOT/$1"

    if [[ ! -f "$file" ]]; then
        cat > "$file" <<EOF
###############################################################################
# $2
# Copyright (c) 2026 Vladimir Lekic
#
# Contributors:
#   Vladimir Lekic
#   ChatGPT (OpenAI)
###############################################################################
EOF
        success "Created file     : $1"
    else
        warn "File exists      : $1"
    fi
}

###############################################################################
# Main
###############################################################################

info "Project root"

echo "    $PROJECT_ROOT"
echo

###############################################################################
# Directories
###############################################################################

info "Creating directories"

create_dir "config"
create_dir "systemd"
create_dir "dyndns_update"

echo

###############################################################################
# Top-level files
###############################################################################

info "Creating top-level files"

create_file ".gitignore"
create_file "LICENSE"
create_file "README.md"
create_file "VERSION"

create_file_with_header "install.sh" "Installation script"

create_file_with_header "dyndns-update" "Main executable"

echo

###############################################################################
# Python package
###############################################################################

info "Creating Python package"

create_file_with_header "dyndns_update/__init__.py" "Python package initializer"

create_file_with_header "dyndns_update/config.py" "Configuration loading and !secret resolution."
create_file_with_header "dyndns_update/dns.py" "DNS-related functionality"
create_file_with_header "dyndns_update/network.py" "Network-related functionality"
create_file_with_header "dyndns_update/updater.py" "Dynamic DNS updater logic"
create_file_with_header "dyndns_update/output.py" "Output handling"
create_file_with_header "dyndns_update/main.py" "Main application logic"

echo

###############################################################################
# Configuration
###############################################################################

info "Creating configuration examples"

create_file_with_header "config/config.yaml.example" "Configuration file example"

create_file_with_header "config/secrets.yaml.example" "Secrets file example"

echo

###############################################################################
# systemd
###############################################################################

info "Creating systemd units"

create_file_with_header "systemd/dyndns-update.service" "systemd service file"
create_file_with_header "systemd/dyndns-update.timer" "systemd timer file"

echo

###############################################################################
# Initialise files
###############################################################################

info "Initialising VERSION"

VERSION_FILE="$PROJECT_ROOT/VERSION"

if [[ ! -s "$VERSION_FILE" ]]; then
    echo "0.1.0" > "$VERSION_FILE"
    success "Initialised VERSION"
else
    warn "VERSION already initialised"
fi

echo

###############################################################################
# Make scripts executable
###############################################################################

info "Making scripts executable"

chmod +x "$PROJECT_ROOT/bootstrap.zsh" 2>/dev/null || true
chmod +x "$PROJECT_ROOT/install.sh" 2>/dev/null || true
chmod +x "$PROJECT_ROOT/dyndns-update" 2>/dev/null || true

success "Executable permissions set"

echo
success "Bootstrap complete."
echo

cat <<EOF
Project structure:

dyndns-update/
│
├── .gitignore
├── LICENSE
├── README.md
├── VERSION
├── bootstrap.zsh
├── install.sh
├── dyndns-update
│
├── config/
│   ├── config.yaml.example
│   └── secrets.yaml.example
│
├── systemd/
│   ├── dyndns-update.service
│   └── dyndns-update.timer
│
└── dyndns_update/
    ├── __init__.py
    ├── config.py
    ├── dns.py
    ├── network.py
    ├── updater.py
    ├── output.py
    └── main.py

EOF

echo
success "Next steps:"
echo
echo "  1. Edit config/config.yaml.example"
echo "  2. Edit config/secrets.yaml.example"
echo "  3. Begin implementing dyndns_update/config.py"
echo