{ pkgs
, ...
}:
{
  home = {
    packages = with pkgs; [
      ocaml
      ocamlPackages.ocaml-lsp
      ocamlPackages.ocamlformat
    ];
  };
}
