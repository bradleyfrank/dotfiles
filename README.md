# Brad's Bootstrapping & dotfiles Manager

Ansible playbook for bootstrapping macOS/Linux workstations and managing dotfiles.

## Bootstrapping macOS & Fedora

The `run.sh` script updates the OS and bootstraps Ansible itself before running the playbook.

* For macOS ensure iCloud and the Mac App Store are logged in to the appropriate account
* The script will prompt for the vault password and create `~/.ansible_vault_password`

```shell
wget https://bradleyfrank.github.io/dotfiles/run.sh -O run.sh && bash run.sh && rm run.sh
```

Use the following for non-personal systems, which excludes certain tasks and doesn't install personally licensed software:

```shell
wget https://bradleyfrank.github.io/dotfiles/run.sh  -O run.sh && bash run.sh -w && rm run.sh
```

## Applying dotfiles

To use Ansible to manage dotfiles only, run the following:

```shell
ansible-pull \
  --url https://github.com/bradleyfrank/dotfiles.git \
  --directory ~/.dotfiles \
  --tags dotfiles \
  --skip-tags {{ skip_tags }} \
  playbooks/site.yml
```

Where `{{ skip_tags }}` can be:

* `work_only`: for a personal system
* `home_only`: for a non-personal system

Once applied, the `dotfiles` function provides a wrapper for applying dotfiles.
