colmena_flags := "-v"

default:
    @just --list

build host:
    colmena build --on={{ host }} {{ colmena_flags }}

build-all:
    colmena build {{ colmena_flags }}

apply host:
    colmena apply --on={{ host }} {{ colmena_flags }}

apply-all:
    colmena apply {{ colmena_flags }}

update-input input:
    nix flake lock --update-input {{ input }}

check:
    nix flake check --impure --all-systems

repl:
    nix repl --extra-experimental-features repl-flake .#

format:
    nix fmt

alias fmt := format
