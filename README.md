# azure nixops examples

Overview:
- Create a custom Azure NixOS image
- Create a NixOps deployments.

## Requirements

0. A NixOS machine to run from. Presumably this should be fine from Linux and OS X
   but it's untested. You should use `channels/nixos-unstable`.
1. NixOps ~~(specifically @phreedom's `nixos-master` branch of it)~~
   (specifically my `azure` branch of it)
2. `azure-vhd-utils-for-go` is used for uploading vhds to azure storage quickly
   and efficiently.

## Usage

`./vhd-create-and-upload.sh` will create an azure-image instance with your current NIX\_PATH.

`./nixops-create.sh` will create a new nixops deployment with the custom base image
specified in the script. You can override by setting `AZURE_NIXOPS_BASE_IMAGE` or
editing the script.

## Example

You can skip straight to the `nixops-create` step. You can use my VHD, it's just the standard
azure-image built against the current `nixos-unstable`.

First, build the vhd and upload it.
```
$ ./vhd-create-and-upload.sh
 ... blah blah
 ...
 ===> https://cmpersist2.blob.core.windows.net/vhds3/nixos-base-606w5xr801ng16nr84fq9whcl1m21jwd.vhd
```

Second, export that URL. (I prefer editing the script so I don't forget later.)
```
export AZURE_NIXOPS_BASE_IMAGE="https://cmpersist2.blob.core.windows.net/vhds3/nixos-base-606w5xr801ng16nr84fq9whcl1m21jwd.vhd"
```

Third, create the nixops deployment:
```
$ ./nixops-create.sh testdeploy02 ./deployable/trivial/trivial-azure.nix
created deployment ‘a8d2b8e3-e763-11e5-935a-3085a9400935’
a8d2b8e3-e763-11e5-935a-3085a9400935
```

Fourth, do the actual deployment:
```
$ nixops deploy -d testdeploy02
def-group....................> creating Azure resource group 'nixops-a8d2b8e3-e763-11e5-935a-3085a9400935-def-group' in westus...
def-storage-westus...........> creating Azure storage 'a8d2b8e3e763westus' in westus...
dn-westus....................> creating Azure virtual network 'nixops-a8d2b8e3-e763-11e5-935a-3085a9400935-dn-westus' in westus...
def-storage-westus...........> waiting for the storage to settle; this may take several minutes...
def-storage-westus...........> updating BLOB service properties of Azure storage 'a8d2b8e3e763westus'...
def-storage-westus...........> updating queue service properties of Azure storage 'a8d2b8e3e763westus'...
def-storage-westus...........> updating table service properties of Azure storage 'a8d2b8e3e763westus'...
def-storage-westus-vhds......> creating Azure BLOB container 'nixops-a8d2b8e3-e763-11e5-935a-3085a9400935-vhds' in a8d2b8e3e763westus...
def-storage-westus-vhds-image> creating Azure BLOB 'nixops-a8d2b8e3-e763-11e5-935a-3085a9400935-unstable-image.vhd' in nixops-a8d2b8e3-e763-11e5-935a-3085a9400935-vhds...
def-storage-westus-vhds-image> updating properties of Azure BLOB 'nixops-a8d2b8e3-e763-11e5-935a-3085a9400935-unstable-image.vhd'...
machine......................> getting an IP address
machine......................> creating a network interface
machine......................> got IP: 104.40.87.183
machine......................> creating Azure machine 'nixops-a8d2b8e3-e763-11e5-935a-3085a9400935-machine'...
machine......................> got IP: 104.40.87.183
machine......................> could not connect to ‘root@104.40.87.183’, retrying in 1 seconds...
machine......................> setting state version to 16.09
machine......................> waiting for SSH...
building all machine configurations...
these derivations will be built:
  /nix/store/084lqky3dxl27bsdppdsigchww33jdja-etc-ssh_known_hosts.drv
  /nix/store/25l5ck2vf90vx09gv6r9n79hs5vhxzam-etc-hosts.drv
  /nix/store/d4dy529c4ci8qan3rr4xavcmli3ws22q-unit-nscd.service.drv
  /nix/store/kgf93df77cmgahnhm29qfwah8zflnx5n-system-units.drv
  /nix/store/yf6khrdy9477vck2ii1h3qab36jv7c82-etc.drv
  /nix/store/lwiqqilcjngnwlm77vhxl9ag26bgq8nm-nixos-system-machine-16.09.git.4603df0.drv
  /nix/store/0sqzb0gfw11qzyfcgx5cr6kmzw4rj4ln-nixops-machines.drv
building path(s) ‘/nix/store/04zrg8jkan0gklp0pxc0k33xd8v45n92-etc-hosts’
building path(s) ‘/nix/store/adp9hli347hbih7a5i0z8dmnpcprzdj1-etc-ssh_known_hosts’
building path(s) ‘/nix/store/6sm26jis6igj0lyy21fb4lak728df47b-unit-nscd.service’
building path(s) ‘/nix/store/y63kbvgwa5722kkmn6bfjjdb3h1mcpl8-system-units’
building path(s) ‘/nix/store/sdb3bc3bd6f6wzgn5f553lx6r8lwm1xj-etc’
building path(s) ‘/nix/store/m4nwgd43nl9s509bnn6cg8lil46qjwjh-nixos-system-machine-16.09.git.4603df0’
building path(s) ‘/nix/store/az2ikrrrlp6c80k2lps6q3282qfnla3p-nixops-machines’
machine......................> copying closure...
machine......................> these paths will be fetched (0.00 MiB download, 0.00 MiB unpacked):
machine......................>   /nix/store/zgv87173ayg5arx7i1mcacbwr23plkxg-etc-fstab
machine......................> fetching path ‘/nix/store/zgv87173ayg5arx7i1mcacbwr23plkxg-etc-fstab’...
machine......................> 
machine......................> *** Downloading ‘https://cache.nixos.org/nar/1ggwdw28w5b9j812fhphqgy3cmbcxhf1cvx4waf7w7fk4j8d91vh.nar.xz’ (signed by ‘cache.nixos.org-1’) to ‘/nix/store/zgv87173ayg5arx7i1mcacbwr23plkxg-etc-fstab’...
machine......................>   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
machine......................>                                  Dload  Upload   Total   Spent    Left  Speed
machine......................>   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0100   232  100   232    0     0  11331      0 --:--:-- --:--:-- --:--:-- 11600
machine......................> 
machine......................> copying 8 missing paths (0.14 MiB) to ‘root@104.40.87.183’...
machine......................> updating GRUB 2 menu...
machine......................> stopping the following units: fetch-ssh-keys.service, metadata.mount, nscd.service
machine......................> activating the configuration...
machine......................> setting up /etc...
machine......................> starting the following units: nscd.service
machine......................> the following new units were started: logrotate.service
machine......................> activation finished successfully
testdeploy02> deployment finished successfully
```

Finally, enjoy:
```
$ nixops ssh -d testdeploy02 machine

[root@nixops-a8d2b8e3-e763-11e5-935a-3085a9400935-machine:~]# 
```

## Credit

credit goes to github.com/phreedom for the azure nixos/nixops goodness

