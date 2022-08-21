{
  description = "Escape from anduril user hell";
  
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = nixpkgs.legacyPackages.${system}; 
    in {
      devShells.default = pkgs.mkShell {
        name = "the-great-escape";
        shellHook = ''
           echo "Hello from nix!"
           exec zsh
        '';
      };
    }
  );
}
