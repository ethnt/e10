colmena_flags := "-v"

default:
    @just --choose

build host:
    colmena build --on={{ host }} {{ colmena_flags }}

build-all:
    colmena build {{ colmena_flags }}

image host:
    nom build .#nixosConfigurations.{{ host }}.config.system.build.qemuImage --print-out-paths
    nom build .#nixosConfigurations.{{ host }}.config.system.build.metadata --print-out-paths

apply host *args:
    colmena apply --on={{ host }} {{ colmena_flags }} {{ args }}

apply-all:
    colmena apply

check:
    nix flake check --impure --all-systems

repl:
    nix repl --extra-experimental-features repl-flake .#

format:
    nix fmt

lint:
    statix check . && deadnix .

age-from-host host:
    nix shell nixpkgs#ssh-to-age --command sh -c "ssh-keyscan {{ host }} | ssh-to-age"

update-secret-files:
    find . -regextype egrep -regex '^.*secrets\.(json|yml)' -execdir sops updatekeys {} -y ';'

nixos-anywhere hostname host:
    nixos-anywhere --flake .#{{ hostname }} --build-on-remote root@{{ host }}

render-workflows:
    nix run .#render-workflows

ssh host:
    ssh -F $SSH_CONFIG_FILE root@{{ host }}

mosh host:
    mosh --ssh="ssh -F $SSH_CONFIG_FILE" root@{{ host }}

scp *args:
    scp -F $SSH_CONFIG_FILE {{ args }}

rsync *args:
    rsync -e "ssh -F $SSH_CONFIG_FILE" {{ args }}

sync-e10-land:
    rsync -rtu --delete --progress -e "ssh -F $SSH_CONFIG_FILE" ~/Documents/e10.land/ matrix:/var/www/e10.land/

terraform *args:
    terraform -chdir=./deploy/terraform/ {{ args }}

edit-secret file:
    EDITOR="zeditor --wait" sops {{ file }}

push-result-to-cache:
    cachix push e10 result
    attic push e10 result

# generate-authelia-client-info:
#     authelia crypto rand --length 72 --charset rfc3986
#     authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986

alias fmt := format

mod ansible 'deploy/ansible/Justfile'
