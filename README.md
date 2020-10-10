# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

## Bootstrap & Manage dotfiles

* **Workstations supported:** *macOS, Fedora, Ubuntu*
* **Servers supported:** *CentOS*

The `bootstrap.sh` script updates the OS and bootstraps Ansible itself before running the playbook.

* For macOS ensure iCloud and the Mac App Store are logged in to the appropriate account
* The script will prompt for the vault password and create `~/.ansible_vault_password`

For personal systems:

```shell
wget https://bradleyfrank.github.io/dotfiles/bin/bootstrap.sh -O bootstrap.sh && bash bootstrap.sh -h
```

For non-personal systems:

```shell
wget https://bradleyfrank.github.io/dotfiles/bin/bootstrap.sh -O bootstrap.sh && bash bootstrap.sh -w
```

## Manage dotfiles Only

The `dotfiles.sh` script runs Ansible to manage dotfiles in the user's home directory only.

* Git, Python, and relevant modules (e.g. selinux) are required
* If Ansible is not installed, it will be installed via `pip`
* The script will prompt for the vault password and create `~/.ansible_vault_password`

For personal systems:

```shell
wget https://bradleyfrank.github.io/dotfiles/bin/dotfiles.sh -O dotfiles.sh && bash dotfiles.sh -h
```

For non-personal systems:

```shell
wget https://bradleyfrank.github.io/dotfiles/bin/dotfiles.sh -O dotfiles.sh && bash dotfiles.sh -w
```

Once applied, the `dotfiles` function provides a wrapper for applying dotfiles.
