#!/usr/bin/env sh

set -x

export azlocation="brazilsouth"
export azname="cmwinvm06"
export azvmsize="Standard_D1"

export azusername="$(source /secrets/winvm04_credentials; echo $WINVM04_USERNAME)"
export azpassword="$(source /secrets/winvm04_credentials; echo $WINVM04_PASSWORD)"

paramFile="$(mktemp)"

# copy from parameters to paramFile
# replace
envsubst < "./parameters.json" > "${paramFile}"

azure group create "${azname}" \
	--location "${azlocation}" \
	--template-file "./azuredeploy.json" \
	--parameters-file "${paramFile}"
