#!/usr/bin/env sh
set -e
set -x

# colemickens's working public VHDs:
# - https://cmpersist2.blob.core.windows.net/vhds3/nixos-base-606w5xr801ng16nr84fq9whcl1m21jwd.vhd
#   (30GB) nixos-untsable same rev, w/ verboseLogging=true, regeneratesshhostkeypair=false

i="https://cmpersist2.blob.core.windows.net/vhds3/nixos-base-606w5xr801ng16nr84fq9whcl1m21jwd.vhd"
export AZURE_NIXOPS_BASE_IMAGE="${AZURE_NIXOPS_BASE_IMAGE:-"${i}"}"

: ${1?"Usage: $0 <nixops deployment name> [nixops create args]"}
deployment_name="${1}"
shift 1

nixops create -d "$deployment_name" "$@"

nixops "set-args" \
	--deployment "${deployment_name}" \
	--argstr azure-image-url "${AZURE_NIXOPS_BASE_IMAGE}"

