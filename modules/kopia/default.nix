# watch for the official nixpkgs kopia module release
# https://github.com/NixOS/nixpkgs/pull/494870

{ ... }:

{
  imports = [
    ./client.nix
    ./server.nix
  ];
}
