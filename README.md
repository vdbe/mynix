# mynix

## Bootstrap (nixos-anywhere)
### System with luks
```bash
TMPFILE=$(mktemp)
echo -n "<key>" > "${TMPFILE}"
nix run github:numtide/nixos-anywhere -- --flake .#<system> root@<ip> --disk-encryption-keys  /root/secret.key "${TMPFILE}"
rm ${TMPFILE}
```
### System with impermanence
```bash
TMPDIR01=$(mktemp -d)
systemd-machine-id-setup --root "${TMPDIR01}/extra-files/persist/data/system"
nix run github:numtide/nixos-anywhere -- --flake .#<system> root@<ip> --extra-files "${TMPDIR01}/extra-files"
```
