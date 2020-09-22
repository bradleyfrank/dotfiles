# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

## Bootstrapping macOS & Fedora

The `run.sh` script bootstraps Ansible itself before running the playbook.

* Create vault password file: `echo "password" > ~/.ansible_vault_password`
* For macOS ensure you're signed into iCloud and the Mac App Store

Supports systems for work or home.

* Use `-h` to run on a personal computer (default)
* Use `-w` to run on a work computer

```shell
curl -O https://bradleyfrank.github.io/dotfiles/run.sh && bash run.sh [-h|-w]
```

## Applying dotfiles

To use Ansible to manage dotfiles only, run the following:

```shell
ansible-pull --url https://github.com/bradleyfrank/dotfiles.git --directory ~/.dotfiles --skip-tags {{ skip_tags }} playbooks/dotfiles.yml
```

Values for `{{ skip_tags }}` can be:

* `work_only`: use this for a personal computer
* `home_only`: use this for a work computer

Once applied, the script `~/.local/bin/dotfiles` provides a wrapper for managing dotfiles.