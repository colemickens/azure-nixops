# This is a geo-distributed load-balanced HTTP server farm example
# implemented using Azure TrafficManager

# the service will be available at service_name.trafficmanager.net
{ service_name ? "nixos-test-cloud"

# datacenter locations to deploy servers in
, locations ? [ "westus" "northeurope" ]

# the number of HTTP servers to deploy per location
, backendCount ? 2
, ...}:

with (import <nixpkgs> {}).lib;
let

  # specify credentials here or via env vars
  credentials = {
  };

  backend =
    location:
    { config, pkgs, resources, ... }:
    { imports = [ ./nix-homepage.nix ];
      networking.firewall.allowedTCPPorts = [ 80 ];
      deployment.targetEnv = "azure";
      deployment.azure = credentials // {
        location = location;
        size = "Standard_A0"; # minimal size that supports load balancing
        availabilitySet = resources.azureAvailabilitySets."set-${location}";
        networkInterfaces.default.backendAddressPools =
          [ { loadBalancer = resources.azureLoadBalancers."lb-${location}"; } ];
      };
    };

  mkResources = prefix: fn:
    listToAttrs (map (l: nameValuePair "${prefix}${l}" (fn l)) locations);

  mkBackendsInLocation = location:
    listToAttrs (map (n: nameValuePair "b-${location}-${toString n}" (backend location)) (range 1 backendCount));

  mkBackends = fold mergeAttrs {} (map (l: mkBackendsInLocation l) locations);

in {

  resources.azureReservedIPAddresses = mkResources "ip-" (location: credentials // {
    inherit location;
    domainNameLabel = service_name;
  });

  resources.azureAvailabilitySets = mkResources "set-" (location: credentials // {
    inherit location;
  });

  resources.azureLoadBalancers = mkResources "lb-" (location: {resources,...}: credentials // {
    inherit location;
    frontendInterfaces.default.publicIpAddress = resources.azureReservedIPAddresses."ip-${location}";
    loadBalancingRules.web = {
      frontendPort = 80;
      backendPort = 80;
      probe = "site";
    };
    probes.site ={
      port = 80;
      path = "/";
      protocol = "Http";
    };
  });

  resources.azureTrafficManagerProfiles.tm = credentials //{
    dns.relativeName = service_name;
    dns.ttl = 30;
    trafficRoutingMethod = "Performance";
    endpoints = mkResources "" (location: { target = "${service_name}.${location}.cloudapp.azure.com"; inherit location; });
  };

} // mkBackends
