#!/usr/bin/env bash
set -euo pipefail

# Path to the Dockerfile passed as first arg
DOCKERFILE_PATH="$1"

# Check that path was provided
if [[ -z "$DOCKERFILE_PATH" ]]; then
  echo "Error: no Dockerfile path provided." >&2
  exit 1
fi

# Declare associative array: binary -> JSON array string
declare -A versions_map

# Find all unique binaries installed via install-tool
binaries=$(grep -E '^RUN install-tool ' "$DOCKERFILE_PATH" | awk '{print $3}' | sort -u)

for bin in $binaries; do
  # 1) build the ARG name: replace hyphens with underscores, uppercase, then add _VERSION
  arg_name="${bin//-/_}"
  arg_name="${arg_name^^}_VERSION"

  # collect versions from ARG declarations: ARG BIN_VERSION=...
  mapfile -t arg_vals < <(
    grep -E "^ARG ${arg_name}=" "$DOCKERFILE_PATH" \
    | cut -d'=' -f2
  )

  # 2) collect inline versions from RUN install-tool bin VERSION
  mapfile -t raw_inline_vals < <(
    grep -E "^RUN install-tool ${bin} " "$DOCKERFILE_PATH" \
    | awk '{print $4}'
  )
  # filter only those that look like a version (start with digit)
  inline_vals=()
  for v in "${raw_inline_vals[@]}"; do
    if [[ $v =~ ^[0-9] ]]; then
      inline_vals+=("$v")
    fi
  done

  # merge and dedupe
  all_vals=("${arg_vals[@]}" "${inline_vals[@]}")
  unique_vals=()
  declare -A seen
  for v in "${all_vals[@]}"; do
    [[ -z "$v" ]] && continue
    if [[ -z "${seen[$v]:-}" ]]; then
      unique_vals+=("$v")
      seen[$v]=1
    fi
  done

  # build JSON array
  if [ "${#unique_vals[@]}" -eq 0 ]; then
    json_array="[]"
  else
    json_items=$(printf '"%s",' "${unique_vals[@]}")
    json_array="[${json_items%,}]"
  fi

  versions_map["$bin"]="$json_array"
done

# emit sorted JSON object
echo "{"
first=true
for bin in $(printf '%s\n' "${!versions_map[@]}" | sort); do
  if $first; then
    first=false
  else
    echo ","
  fi
  echo -n "  \"${bin}\": ${versions_map[$bin]}"
done
echo
echo "}"
