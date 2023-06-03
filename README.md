# mynix

## Bootstrap (nixos-anywhere)
### System with luks
```bash
TMPFILE=$(mktemp)
echo -n "<key>" > ${TMPFILE}
nix run github:numtide/nixos-anywhere -- --flake .#<system> root@<ip> --disk-encryption-keys  /root/secret.key "${TMPFILE}"
rm ${TMPFILE}
```
### System with impermanence
```bash
TMPDIR=$(mktemp -d)
systemd-machine-id-setup --root "${TMPDIR}/extra-files/persist/data/system"
nix run github:numtide/nixos-anywhere -- --flake .#<system> root@<ip> --extra-files "${TMPDIR}/extra-files"
```
