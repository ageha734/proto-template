#!/usr/bin/env bash
set -euo pipefail

# Proto plugin template initializer
# Usage: ./init.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# -------------------------------------------------------------------
# Prompt for values
# -------------------------------------------------------------------

read -rp "Tool name (display name, e.g. 'AWS CLI', 'Gcloud'): " TOOL_DISPLAY_NAME
read -rp "Plugin ID (snake_case, e.g. 'awscli', 'gcloud'): " PLUGIN_ID
read -rp "GitHub organization or username (e.g. 'ageha734'): " ORGANIZATION
read -rp "Author name (e.g. 'ageha734'): " USERNAME

# Derive names
PLUGIN_ID_UNDERSCORE="${PLUGIN_ID//-/_}"
REPO_NAME="proto-${PLUGIN_ID}"
CRATE_NAME="proto_${PLUGIN_ID_UNDERSCORE}"

echo ""
echo "=== Configuration ==="
echo "  Display name:  ${TOOL_DISPLAY_NAME}"
echo "  Plugin ID:     ${PLUGIN_ID}"
echo "  Crate name:    ${CRATE_NAME}"
echo "  Repo name:     ${REPO_NAME}"
echo "  Organization:  ${ORGANIZATION}"
echo "  Author:        ${USERNAME}"
echo ""
read -rp "Proceed? [Y/n] " confirm
if [[ "${confirm:-Y}" =~ ^[Nn] ]]; then
  echo "Aborted."
  exit 0
fi

# -------------------------------------------------------------------
# Replace placeholders in all files
# -------------------------------------------------------------------

echo "Replacing placeholders..."

find "$SCRIPT_DIR" -type f \
  -not -path '*/.git/*' \
  -not -name 'init.sh' \
  | while IFS= read -r file; do
    if file "$file" | grep -q text; then
      # TOOL_NAME in workflows (proto_TOOL_NAME.wasm, proto install TOOL_NAME, etc.)
      # must be replaced with the correct form per context

      # Replace proto_TOOL_NAME (crate/artifact name) -> proto_<plugin_id>
      sed -i'' -e "s/proto_TOOL_NAME/${CRATE_NAME}/g" "$file"

      # Replace TOOL_NAME (display name in source code and docs)
      sed -i'' -e "s/TOOL_NAME/${TOOL_DISPLAY_NAME}/g" "$file"

      # Replace ORGANIZATION
      sed -i'' -e "s/ORGANIZATION/${ORGANIZATION}/g" "$file"

      # Replace USERNAME
      sed -i'' -e "s/USERNAME/${USERNAME}/g" "$file"
    fi
  done

# -------------------------------------------------------------------
# Rename README title
# -------------------------------------------------------------------

sed -i'' -e "s/^# proto-TOOL_NAME$/# ${REPO_NAME}/" "$SCRIPT_DIR/README.md" 2>/dev/null || true

# -------------------------------------------------------------------
# Fix E2E workflow: proto install/run uses plugin ID (snake_case)
# -------------------------------------------------------------------

E2E_FILE="$SCRIPT_DIR/.github/workflows/_reusable-e2e.yaml"
if [[ -f "$E2E_FILE" ]]; then
  # The prototools content lines and proto commands should use PLUGIN_ID
  sed -i'' -e "s/proto install ${TOOL_DISPLAY_NAME}/proto install ${PLUGIN_ID}/g" "$E2E_FILE"
  sed -i'' -e "s/proto run ${TOOL_DISPLAY_NAME}/proto run ${PLUGIN_ID}/g" "$E2E_FILE"
  # Fix prototools entries: 'DISPLAY_NAME = "..."' -> 'plugin_id = "..."'
  sed -i'' -e "s/'${TOOL_DISPLAY_NAME} = \"VERSION\"'/'${PLUGIN_ID} = \"VERSION\"'/g" "$E2E_FILE"
  sed -i'' -e "s/\`${TOOL_DISPLAY_NAME} = /\`${PLUGIN_ID} = /g" "$E2E_FILE"
fi

# -------------------------------------------------------------------
# Fix README: proto install and prototools entries use plugin ID
# -------------------------------------------------------------------

README_FILE="$SCRIPT_DIR/README.md"
if [[ -f "$README_FILE" ]]; then
  sed -i'' -e "s/proto install ${TOOL_DISPLAY_NAME}/proto install ${PLUGIN_ID}/g" "$README_FILE"
  # Fix toml entries in README
  sed -i'' -e "s/^${TOOL_DISPLAY_NAME} = \"x.y.z\"/${PLUGIN_ID} = \"x.y.z\"/" "$README_FILE"
  sed -i'' -e "s/^${TOOL_DISPLAY_NAME} = \"github:/${PLUGIN_ID} = \"github:/" "$README_FILE"
fi

# -------------------------------------------------------------------
# Clean up sed backup files (macOS creates -e suffixed files)
# -------------------------------------------------------------------

find "$SCRIPT_DIR" -name '*-e' -type f -delete 2>/dev/null || true

# -------------------------------------------------------------------
# Remove this script
# -------------------------------------------------------------------

echo ""
read -rp "Remove init.sh from the project? [Y/n] " remove_self
if [[ "${remove_self:-Y}" =~ ^[Yy]|^$ ]]; then
  rm -f "$SCRIPT_DIR/init.sh"
  echo "init.sh removed."
fi

echo ""
echo "Done! Your proto plugin '${REPO_NAME}' is ready."
echo ""
echo "Next steps:"
echo "  1. Update src/proto.rs with your tool's version source and download URLs"
echo "  2. Update src/config.rs with your tool's dist-url pattern"
echo "  3. Update .github/workflows/_reusable-e2e.yaml with a valid test version"
echo "  4. Run: cargo build --target wasm32-wasip1 --release --features wasm"
