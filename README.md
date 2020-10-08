# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

## Bootstrapping macOS & Fedora

The `run.sh` script updates the OS and bootstraps Ansible itself before running the playbook.

* For macOS ensure iCloud and the Mac App Store are logged in to the appropriate account
* The script will prompt for the vault password and create `~/.ansible_vault_password`

```shell
wget -qO- https://bradleyfrank.github.io/dotfiles/run.sh -bh | bash
```

Use the following for non-personal systems, which excludes certain tasks and doesn't install personally licensed software:

```shell
wget -qO- https://bradleyfrank.github.io/dotfiles/run.sh -bw | bash
```

## Applying dotfiles

```shell
wget -qO- https://bradleyfrank.github.io/dotfiles/run.sh -dh | bash
```

Use the following for non-personal systems, which excludes certain tasks and doesn't install personally licensed software:

```shell
wget -qO- https://bradleyfrank.github.io/dotfiles/run.sh -dw | bash
```

Once applied, the `dotfiles` function provides a wrapper for applying dotfiles.
