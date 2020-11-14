# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

## Bootstrap & Manage dotfiles

* **Workstations supported:** *macOS, Fedora, Ubuntu*
* **Servers supported:** *CentOS*

The `bootstrap.sh` script updates the OS and bootstraps Ansible itself before running the playbook.

* For macOS ensure iCloud and the Mac App Store are authenticated to the appropriate account
* The script will prompt for the vault password and create `~/.ansible_vault_password`

To use with `curl` (i.e. **macOS**):

```shell
curl -O https://bradleyfrank.github.io/dotfiles/bin/bootstrap.sh && bash bootstrap.sh [-h|-w]
```

To use with `wget` (i.e. **Linux**):

```shell
wget https://bradleyfrank.github.io/dotfiles/bin/bootstrap.sh -O bootstrap.sh && bash bootstrap.sh [-h|-w]
```

*Use `-h` for home systems, and `-w` for work systems.*

## Manage dotfiles Only

The `dotfiles.sh` script runs Ansible to manage dotfiles in the user's home directory only.

* Git, Python, and relevant modules (e.g. selinux) are required
* If Ansible is not installed, it will be installed via `pip`
* The script will prompt for the vault password and create `~/.ansible_vault_password`

To use with `curl` (i.e. **macOS**):

```shell
curl -O https://bradleyfrank.github.io/dotfiles/bin/dotfiles.sh && bash dotfiles.sh [-h|-w]
```

To use with `wget` (i.e. **Linux**):

```shell
wget https://bradleyfrank.github.io/dotfiles/bin/dotfiles.sh -O dotfiles.sh && bash dotfiles.sh [-h|-w]
```

*Use `-h` for home systems, and `-w` for work systems.*

Once applied, the `dotfiles` function provides a wrapper for applying dotfiles.

## Post-Ansible Instructions

Other tasks:

* MacOS disk encryption
* Customize Slack: `#FDF6E3,#EEE8D5,#B58900,#FDF6E3,#EEE8D5,#002B36,#B58900,#DC322F,#EEE8D5,#073642`
