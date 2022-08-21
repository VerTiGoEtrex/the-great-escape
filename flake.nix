{
  description = "Escape from anduril user hell";
  
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = nixpkgs.legacyPackages.${system}; 
      script = pkgs.writeShellScript "escape.sh" ''
        set -euo pipefail
        echo "hello from container"
        TEMPDIR="$(mktemp -d)"
        trap 'rm -rf $TEMPDIR' EXIT

        mkdir -p "$TEMPDIR"/work
        mount -t overlay -o lowerdir="$HOME",upperdir="$HOME"/i-am-homeless/ncrocker,workdir="$TEMPDIR"/work none "$HOME"
        trap 'umount "$HOME" && rm -rf "$TEMPDIR"' EXIT

        touch "$HOME/this_is_an_overlay"
        '';
    in {
      devShells.default = pkgs.mkShell {
        name = "the-great-escape";
        nativeBuildInputs = [ pkgs.bubblewrap ];
        shellHook = ''
           set -euo pipefail
           echo "Escaping hell!"
           echo $HOME
           mkdir -p $HOME/i-am-homeless/ncrocker
           export PATH="/run/current-system/sw/bin:$PATH"
           #exec bwrap --bind / / --dev /dev --ro-bind $HOME $HOME --bind $HOME/sources $HOME/sources --bind $HOME/i-am-homeless $HOME/i-am-homeless bash -c "mount -t overlay overlay -o lowerdir=$HOME,upperdir=$HOME/i-am-homeless,workdir=$(mktemp -d) $(mktemp -d) && zsh"
           exec bwrap --cap-add CAP_SETPCAP --cap-add CAP_DAC_OVERRIDE --cap-add CAP_SYS_ADMIN --bind / / --dev /dev --ro-bind $HOME $HOME --bind $HOME/sources $HOME/sources --bind $HOME/i-am-homeless $HOME/i-am-homeless -- ${script}
        ''; 
      };
    }
  );
}
