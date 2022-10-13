let GithubActions = https://regadas.dev/github-actions-dhall/package.dhall

let checkout =
      GithubActions.Step::{
      , name = Some "Checkout code"
      , uses = Some "actions/checkout@v3"
      }

let installNix =
      GithubActions.Step::{
      , name = Some "Install Nix"
      , uses = Some "cachix/install-nix-action@v18"
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
      , uses = Some "cachix/cachix-action@v10"
      , `with` = Some
          ( toMap
              { name = "camp"
              , authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}"
              , extraPullNames = "camp,nix-community,nrdxp"
              }
          )
      }

let check =
      GithubActions.Step::{
      , run = Some
          ''
            nix flake -Lv check --show-trace
          ''
      }

let setup = [ checkout, installNix, cachix ]

in  GithubActions.Workflow::{
    , name = "CI"
    , on = GithubActions.On::{ push = Some GithubActions.Push::{=} }
    , jobs = toMap
        { code = GithubActions.Job::{
          , runs-on = GithubActions.RunsOn.Type.ubuntu-latest
          , steps = setup # [ check ]
          }
        }
    }
