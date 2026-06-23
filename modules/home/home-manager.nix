{ inputs, ... }:

{
  home-manager.extraSpecialArgs = { inherit inputs; };

  home-manager.users.bokutake = {
    imports = [
      ../../home/bokutake
    ];
  };
}
