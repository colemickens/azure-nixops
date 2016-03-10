#!/usr/bin/env sh

set -x

export azlocation="westus"
export azname="colemick-windev-$(date +"%Y%m%d-%H%M%S")"
export azvmsize="Standard_D1"

export azusername="$(source /secrets/azure/azurevm_credentials; echo $AZUREVM_USERNAME)"
export azpassword="$(source /secrets/azure/azurevm_credentials; echo $AZUREVM_PASSWORD)"

paramFile="$(mktemp)"

envsubst < "./parameters.json" > "${paramFile}"

azure group create "${azname}" \
	--location "${azlocation}" \
	--template-file "./azuredeploy.json" \
	--parameters-file "${paramFile}"
