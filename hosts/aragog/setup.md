# Setup - Aragog
1. Boot a nixos live ISO

## Luks
### Benchmark
```
[nixos@nixos:~]$ cryptsetup benchmark
# Tests are approximate using memory only (no storage IO).
PBKDF2-sha1       443560 iterations per second for 256-bit key
PBKDF2-sha256     607517 iterations per second for 256-bit key
PBKDF2-sha512     406424 iterations per second for 256-bit key
PBKDF2-ripemd160  343120 iterations per second for 256-bit key
PBKDF2-whirlpool  212779 iterations per second for 256-bit key
argon2i       4 iterations, 520126 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
argon2id      4 iterations, 522199 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
#     Algorithm |       Key |      Encryption |      Decryption
        aes-cbc        128b       491.0 MiB/s      1024.6 MiB/s
    serpent-cbc        128b        46.7 MiB/s       125.9 MiB/s
    twofish-cbc        128b       122.7 MiB/s       136.4 MiB/s
        aes-cbc        256b       401.5 MiB/s       874.4 MiB/s
    serpent-cbc        256b        50.3 MiB/s       126.2 MiB/s
    twofish-cbc        256b       127.2 MiB/s       136.2 MiB/s
        aes-xts        256b       881.5 MiB/s       900.0 MiB/s
    serpent-xts        256b       112.6 MiB/s       117.3 MiB/s
    twofish-xts        256b       123.6 MiB/s       126.1 MiB/s
        aes-xts        512b       791.1 MiB/s       791.1 MiB/s
    serpent-xts        512b       118.0 MiB/s       117.2 MiB/s
    twofish-xts        512b       126.1 MiB/s       126.1 MiB/s
```

Modify the `disk.one.content.luks.content.extraFormatArgs` in ./disko.nix to the prefered options

## Hardware
### Config
replace ./hardware.nix with the output from following command
```
[nixos@nixos:~]$ nixos-generate-config --show-hardware-config
```
remove the following parts
- fileSystems
- swapDevices
- networking

## Install
### Prep
Comment out `users.users.user.passowrdFile` in ./configuration.nix

```bash
IP=<IP>

# LUKS2 prep
 KEY="<key>" # LUKS2 passphrase
TMPFILE=$(mktemp)
echo -n "${KEY}" > "${TMPFILE}"

# We have to precreate a systemd-id otherwise impermanence can't create a valid link and nixos-install will fail
TMPDIR01=$(mktemp -d)
systemd-machine-id-setup --root "${TMPDIR01}/extra-files/persist/data/system"
```

## Boot strap
Don't forget to set u root password/pub key on the live ISO
```bash
./update.sh && nix run github:numtide/nixos-anywhere -- --flake .#aragog "root@${IP}" \
  --disk-encryption-keys  /root/secret.key "${TMPFILE}" \
  --extra-files "${TMPDIR01}/extra-files"

rm ${TMPFILE}
rm -r ${TMPDIR01}
```

## Get pub key
```bash
nix-shell -p ssh-to-age --run 'ssh-keyscan "${IP}" | ssh-to-age'
```
Add it to secrets/.sops.yaml (root of repo)

```
# Run this inside secrets (root of repo)
find -type f -not -path '*/.*' -name '*.sops.yaml' -exec sops updatekeys {} \;
```

## Deploy secrets
1. uncomment `users.users.user.passowrdFile` in ./configuration.nix
```bash
./update.sh && nixos-rebuild boot --flake .#aragog --target-host "${IP}" --use-remote-sudo
```

