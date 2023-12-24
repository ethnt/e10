colmena_flags := "-v"

default:
    @just --list

build:
    colmena build {{ colmena_flags }}

build-host host:
    colmena build --on={{ host }} {{ colmena_flags }}

apply:
    colmena apply {{ colmena_flags }}

apply-host host:
    colmena apply --on={{ host }} {{ colmena_flags }}

update-input input:
    nix flake lock --update-input {{ input }}

check:
    nix flake check --impure --all-systems

repl:
    nix repl --extra-experimental-features repl-flake .#

format:
    nix fmt
