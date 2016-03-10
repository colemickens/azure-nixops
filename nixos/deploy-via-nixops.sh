#!/usr/bin/env sh

# colemickens's public VHDs:
# - https://cmpersist2.blob.core.windows.net/vhds/nixos-base-igjb0w7jpjk43sxwk53l21mz118ivghn.vhd 
#   (30GB) nixos-unstable rev:0bf8a1a86df67649893726d50761567121330006

set -x

export AZURE_NIXOPS_BASE_IMAGE="${AZURE_NIXOPS_BASE_IMAGE:-"https://cmpersist2.blob.core.windows.net/vhds/nixos-base-igjb0w7jpjk43sxwk53l21mz118ivghn.vhd"}"

export AZURE_AUTHORITY_URL="${AZURE_AUTHORITY_URL:-"https://login.microsoftonline.com/${AZURE_TENANT_ID}"}"
export AZURE_USER="${AZURE_USER:-"${AZURE_CLIENT_ID}"}"
export AZURE_PASSWORD="${AZURE_PASSWORD:-"${AZURE_CLIENT_SECRET}"}"

export AZURE_NIXOPS_DEPLOYMENT_NAME="${AZURE_NIXOPS_DEPLOYMENT_NAME:-"azuredeploy-$(date +"%Y%m%d-%H%M%S")"}"
export NIXOPS="/home/cole/code/phreedom/nixops/result/bin/nixops"
export DEPLOY_TARGET="/home/cole/code/phreedom/nixops/examples/trivial-azure.nix"

deploy() {
	"${NIXOPS}" create \
		-d "${AZURE_NIXOPS_DEPLOYMENT_NAME}" \
		"${DEPLOY_TARGET}"

	# does this set per-deployment? can I make it?
	"${NIXOPS}" "set-args" \
		--deployment "${AZURE_NIXOPS_DEPLOYMENT_NAME}" \
		--argstr azure-image-url "${AZURE_NIXOPS_BASE_IMAGE}"

	"${NIXOPS}" deploy \
		--debug \
		--deployment "${AZURE_NIXOPS_DEPLOYMENT_NAME}"
}

deploy
