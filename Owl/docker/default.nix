{ pkgs ? import <nixpkgs> { system = "aarch64-darwin"; } }:

pkgs.dockerTools.buildLayeredImage {
  name = "hello";
  tag = "latest";

  contents = [ pkgs.hello ];

  config.Cmd = [ "/bin/hello" ];
}
