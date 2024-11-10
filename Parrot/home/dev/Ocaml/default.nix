{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      opam
      ocaml
      ocamlPackages.findlib
      ocamlPackages.lablgl
      ocamlPackages.ocaml-lsp
      ocamlPackages.ocamlformat
      ocamlPackages.tsdl
      ocamlPackages.tsdl-image
    ];
  };
}
