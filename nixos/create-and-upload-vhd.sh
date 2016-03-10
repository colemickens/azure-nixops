#!/usr/bin/env sh

set -x

export NIXOS_CONFIG=/nixpkgs/nixos/modules/virtualisation/azure-image.nix

export AZURE_LOCATION="${AZURE_LOCATION:-"westus"}"
export AZURE_RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-"cmpersist"}"
export AZURE_STORAGE_ACCOUNT="${AZURE_STORAGE_ACCOUNT:-"cmpersist2"}"
export AZURE_STORAGE_CONTAINER="${AZURE_STORAGE_CONTAINER:-"vhds3"}"

export UPLOAD_PARALLELISM=${UPLOAD_PARALLELISM:-1}

create_vhd() {
	export SRC_VHD_DIR="$(nix-build '<nixpkgs/nixos>' \
		-A config.system.build.azureImage \
		--argstr system x86_64-linux \
		-o azure \
		--option extra-binary-caches https://hydra.nixos.org \
		-j 4)"
	export SRC_VHD_PATH="${SRC_VHD_DIR}/disk.vhd"
	export SRC_VHD_HASH="$(echo "${SRC_VHD_DIR}" | sed -e 's|/nix/store/\(.*\)-azure-image|\1|g')"
	export DST_VHD_NAME="nixos-base-${SRC_VHD_HASH}.vhd"
}

create_group() {
	azure group create \
		--location "${AZURE_LOCATION}" \
		"${AZURE_RESOURCE_GROUP}"
}

create_account() {
	azure storage account create -vv \
		--location "${AZURE_LOCATION}" \
		--resource-group "${AZURE_RESOURCE_GROUP}" \
		--type LRS \
		"${AZURE_STORAGE_ACCOUNT}"
}

load_keys() {
	out="$(azure storage account keys list "${AZURE_STORAGE_ACCOUNT}" -g ${AZURE_RESOURCE_GROUP})"
	export AZURE_STORAGE_ACCESS_KEY="$(echo "$out" | grep Primary | awk '{ print $3; }')"
}

create_container() {
	load_keys
	sc="$(azure storage container show "${AZURE_STORAGE_CONTAINER}")"

	if ! azure storage container show "${AZURE_STORAGE_CONTAINER}" ; then
		azure storage container create -vv \
			--permission Blob \
			"${AZURE_STORAGE_CONTAINER}"
	fi
}

upload_blob() {
	load_keys
	azure-vhd-utils-for-go upload \
		--localvhdpath ${SRC_VHD_PATH} \
		--blobname "${DST_VHD_NAME}" \
		--stgaccountname "${AZURE_STORAGE_ACCOUNT}" \
		--stgaccountkey "${AZURE_STORAGE_ACCESS_KEY}" \
		--containername "${AZURE_STORAGE_CONTAINER}" \
		--parallelism ${UPLOAD_PARALLELISM}

	export AZURE_VHD_URL="https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/${AZURE_STORAGE_CONTAINER}/${DST_VHD_NAME}"

	echo "===> ${AZURE_VHD_URL}"
}

create_vhd
create_group
create_account
load_keys
create_container
upload_blob

