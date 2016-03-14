{ location ? "westus"
, nodeCount ? 1
, ...}:

with (import <nixpkgs> {}).lib;
let

  credentials = { };

  masterDef = { resources, config, pkgs, nodes, ...}: {
    deployment.targetEnv = "azure";

    deployment.azure = credentials // {
      location = "westus";
      size = "Standard_D3_v2";
    };

    # TODO(colemickens): fix this
    networking.firewall.enable = false;

    # TODO: enhance the kubernetes module:
    #  1. open firewall ports
    #  2. figure out where etcd should and shouldn't run
    #  3. useFlannel option

    environment.systemPackages = with pkgs; [ git gist neovim ];
    virtualisation.docker.enable = true;
    services = {
      flannel = {
        enable = true;
        configureDocker = true;
        configureCidr = "10.10.0.0/16";
        etcdEndpoints = [ "http://127.0.0.1:4001" ];
      };
      kubernetes = {
        roles = [ "master" ];
        verbose = true;
        apiserver = {
          address = "0.0.0.0";
        };
      };
    };
  };

  nodeDef = { resources, config, pkgs, nodes, ...}: {
    deployment.targetEnv = "azure";

    deployment.azure = credentials // {
      location = "westus";
      size = "Standard_D3_v2";
    };

    # TODO(colemickens): fix this
    networking.firewall.enable = false;

    environment.systemPackages = with pkgs; [ git gist neovim ];
    virtualisation.docker.enable = true;
    services = {
      flannel = {
        enable = true;
        configureDocker = true;
        etcdEndpoints = [ "http://${nodes.master.config.networking.privateIPv4}:4001" ];
      };
      kubernetes = {
        roles = [ "node" ];
        verbose = true;

        kubelet = {
          apiServers = [ "${nodes.master.config.networking.privateIPv4}:8080" ];
        };

        proxy = {
          master = "${nodes.master.config.networking.privateIPv4}:8080";
        };
      };
    };
  };

  mkNodes = builtins.listToAttrs (builtins.map (nodeid: {
      name = "node${toString nodeid}";
      value = nodeDef;
  }) (range 1 nodeCount));

in {
  "master" = masterDef;
} // mkNodes
