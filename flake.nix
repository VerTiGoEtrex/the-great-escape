{
  description = "Escape from anduril user hell";
  
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = nixpkgs.legacyPackages.${system}; 
      setupMountsScript = pkgs.writeShellScript "escape.sh" ''
        set -euo pipefail
        WORKDIR=$HOME/i-am-homeless/ncrocker
        mkdir -p $WORKDIR/sources
        mount --bind -o rw $HOME/sources $WORKDIR/sources
        mount --rbind -o rw $WORKDIR $HOME
        exec unshare -U zsh
        '';
    in {
      devShells.default = pkgs.mkShell {
        name = "the-great-escape";
        nativeBuildInputs = [ pkgs.bubblewrap pkgs.tree ];
        shellHook = ''
           set -euo pipefail
           echo "Escaping hell!"
           echo $HOME
           export PATH="/run/current-system/sw/bin:$PATH"
           exec unshare -rm ${setupMountsScript}
        ''; 
      };
    }
  );
}
