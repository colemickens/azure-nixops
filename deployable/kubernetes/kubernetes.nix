let
  credentials = { };

  commonDef = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.git pkgs.gist pkgs.neovim ];
  };

  masterDef = { resources, config, pkgs, nodes, ...}: {
    deployment.targetEnv = "azure";

    deployment.azure = credentials // {
      location = "westus";
      size = "Standard_D3_v2";
    };
    environment.systemPackages = [ pkgs.git pkgs.gist pkgs.neovim ];

    services.kubernetes = {
      roles = [ "master" ];
      verbose = true;
    };
  };

  nodeDef = { resources, config, pkgs, nodes, ...}: {
    deployment.targetEnv = "azure";

    deployment.azure = credentials // {
      location = "westus";
      size = "Standard_D3_v2";
    };
    environment.systemPackages = [ pkgs.git pkgs.gist pkgs.neovim ];

    services.kubernetes = {
      roles = [ "node" ];
      verbose = true;

      kubelet = {
        apiServers = [ "${nodes.master.config.networking.privateIPv4}" ];
      };

      proxy = {
        master = "${nodes.master.config.networking.privateIPv4}";
      };
    };
  };

in {
  "master" = masterDef;
  "node1" = nodeDef;
}
