let GithubActions = https://regadas.dev/github-actions-dhall/package.dhall

let checkout =
      GithubActions.Step::{
      , name = Some "Checkout code"
      , uses = Some "actions/checkout@v3"
      }

let installNix =
      GithubActions.Step::{
      , name = Some "Install Nix"
      , uses = Some "cachix/install-nix-action@v22"
      , `with` = Some
          ( toMap
              { nix_path = "nixpkgs=channel:nixos-unstable"
              , extra_nix_config =
                  ''
                    allow-import-from-derivation = true
                  ''
              }
          )
      }

let cachix =
      GithubActions.Step::{
      , name = Some "Use Cachix store"
      , uses = Some "cachix/cachix-action@v12"
      , `with` = Some
          ( toMap
              { name = "e10"
              , authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}"
              , extraPullNames = "e10,nix-community"
              }
          )
      }

let check =
      GithubActions.Step::{
      , run = Some
          ''
            nix flake check --impure --show-trace
          ''
      }

let build =
      GithubActions.Step::{
      , run = Some
          ''
            nix -Lv build .#nixosConfigurations.''${{ matrix.host }}.config.system.build.toplevel
          ''
      }

let setup = [ checkout, installNix, cachix ]

in  GithubActions.Workflow::{
    , name = "CI"
    , on = GithubActions.On::{ push = Some GithubActions.Push::{=} }
    , jobs = toMap
        { check = GithubActions.Job::{
          , runs-on = GithubActions.RunsOn.Type.ubuntu-latest
          , steps = setup # [ check ]
          }
          ,  build = GithubActions.Job::{
          , runs-on = GithubActions.RunsOn.Type.ubuntu-latest
          , strategy = Some GithubActions.Strategy::{
            , matrix = toMap
                { host = [ "gateway", "monitor", "omnibus", "htpc", "matrix", "controller" ] }
            }
          , steps = setup # [ build ]
          }
        }
    }
