colmena_flags := "-v"

default:
    @just --choose

build host:
    colmena build --on={{ host }} {{ colmena_flags }}

build-all:
    colmena build {{ colmena_flags }}

apply host:
    colmena apply --on={{ host }} {{ colmena_flags }}

apply-all:
    colmena apply

update-input input:
    nix flake lock --update-input {{ input }}
    git commit -m 'Update `{{ input }}`'

check:
    nix flake check --impure --all-systems

repl:
    nix repl --extra-experimental-features repl-flake .#

format:
    nix fmt

age-from-host host:
    nix shell nixpkgs#ssh-to-age --command sh -c "ssh-keyscan {{ host }} | ssh-to-age"

update-secret-files:
    find . -regextype egrep -regex '^.*secrets\.(json|yml)' -execdir sops updatekeys {} -y ';'

nixos-anywhere hostname host:
    nixos-anywhere --flake .#{{ hostname }} --build-on-remote root@{{ host }}

generate-ci:
    nix run .#generate-ci

ansible playbook:
    ansible-playbook -i deploy/ansible/inventory.yml deploy/ansible/{{ playbook }}.yml

ssh host:
    ssh -F $SSH_CONFIG_FILE root@{{ host }}

image name:
    nom build .#packages.x86_64-linux.{{ name }}-image

terraform *args:
    terraform -chdir=./deploy/terraform/ {{ args }}

edit-secret file:
    EDITOR="code --wait" sops {{ file }}
