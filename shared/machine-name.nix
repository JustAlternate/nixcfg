{ lib, ... }:
{
  options.machineName = lib.mkOption {
    type = lib.types.str;
    default = "unknown";
    description = "The name of the machine (e.g., swordfish, owl, parrot, beaver)";
  };
}
