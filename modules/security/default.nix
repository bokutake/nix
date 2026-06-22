{ pkgs, ... }:

{
  imports = [
    ./openssh.nix
    ./tpm2.nix
    ./integrity-scan.nix
    ./github-authorized-keys.nix
  ];
}
