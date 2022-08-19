# pacman (arch linux package manager)

## Install pacman

1. open `Konsole` or connect via `ssh`
2. Initialize the pacman keyring
```bash
sudo pacman-key --init
```
3. populate the keyring for Arch
```bash
sudo pacman-key --populate archlinux
```
## Update pacman packages

```bash
sudo pacman -Syu
```

## Search for Packages
```bash
pacman -Ss <package name>
```