# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

***Currently supports macOS, Fedora, and Ubuntu.***

## Bootstrapping Systems

The `bootstrap.sh` script updates the OS and bootstraps Ansible itself before running the playbook.

* For macOS ensure iCloud and the Mac App Store are logged in to the appropriate account
* The script will prompt for the vault password and create `~/.ansible_vault_password`

```shell
wget -qO- https://bradleyfrank.github.io/dotfiles/run.sh | bash -s -- -bh
```

Use the following for non-personal systems:

```shell
wget -qO- https://bradleyfrank.github.io/dotfiles/run.sh | bash -s -- -bw
```

## Applying dotfiles

```shell
wget -qO- https://bradleyfrank.github.io/dotfiles/run.sh | bash -s -- -dh
```

Use the following for non-personal systems:

```shell
wget -qO- https://bradleyfrank.github.io/dotfiles/run.sh | bash -s -- -dw
```

Once applied, the `dotfiles` function provides a wrapper for applying dotfiles.
