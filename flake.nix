{
  description = "Simple snake game";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = { nixpkgs, zig, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ 
          zig.packages.${system}."0.14.0" 
          pkgs.clang
          pkgs.nodejs
          pkgs.alsa-lib
          pkgs.libGL
          pkgs.wayland
          pkgs.libxkbcommon
          pkgs.xorg.libX11
          pkgs.xorg.libXi
          pkgs.xorg.libXcursor
        ];
      };
    };
}
