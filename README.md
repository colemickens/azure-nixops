# azure nixops examples

Overview:
- Create a custom Azure NixOS image
- Create a NixOps deployments.

## Requirements

1. `azure-vhd-utils-for-go` is used for uploading vhds to azure storage quickly
   and efficiently.

## Usage

`./vhd-upload.sh` will create an azure-image instance with your current NIX\_PATH.

`./nixops-create.sh` will create a new nixops deployment with the custom base image
specified in the script. You can override by setting `AZURE_NIXOPS_BASE_IMAGE` or
editting the script.

## Example

First, build the vhd and upload it.
```
$ ./vhd-upload.sh
 ... blah blah
 ...
 ===> https://some/url
```

Second, export that URL. (I prefer editting the script so I don't forget later.)
```
export AZURE_NIXOPS_BASE_IMAGE=https://some/url
```

Third, create the nixops deployment:
```
$ ./nixops-create.sh azure-deploy-test01 ./trivial-azure.nix
created deployment ‘d8c92d99-e75f-11e5-90ae-3085a9400935’
d8c92d99-e75f-11e5-90ae-3085a9400935
```

Fourth, do the actual deployment:
```
$ nixops deploy -d azure-deploy-test01
```

Finally, enjoy:
```
$ nixops ssh -d azure-deploy-test01 machine
```

## Credit

credit goes to github.com/phreedom
