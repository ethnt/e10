# E10

## Usage

### Adding new hosts

1. Create with Terraform
2. Grab public IP
3. Get age key with `nix-shell -p ssh-to-age --run 'ssh-keyscan monitor.e10.camp | ssh-to-age'
4. Update sops file and `updatekeys`
5. Deploy
6. Update private IP
