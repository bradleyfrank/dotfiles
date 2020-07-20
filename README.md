# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

## Bootstrapping macOS & Fedora

The `run.sh` script bootstraps Ansible itself before running the playbook.

* Create vault password file: `echo "password" > ~/.ansible_vault_password`
* For macOS ensure you're signed into iCloud and the Mac App Store

Supports systems for work or home.

* Use `-h` to run on a personal computer
* Use `-w` to run on a work computer

```
curl -fsSL https://raw.githubusercontent.com/bradleyfrank/dotfiles/master/run.sh | bash -s -- [-h|-w]
```

## Applying dotfiles

To use Ansible to manage dotfiles only, run the following:

```
ansible-pull --url https://github.com/bradleyfrank/dotfiles.git --directory ~/.dotfiles --skip-tags work_only playbooks/dotfiles.yml
```

The argument `skip_tags` can be:
* `home_only`: use this for a work computer
* `work_only`: use this for a personal computer

Once applied, the script `~/.local/bin/dotfiles` provides a wrapper for managing dotfiles, and takes the following arguments:

* `-h`: for a personal computer
* `-w`: for a work computer