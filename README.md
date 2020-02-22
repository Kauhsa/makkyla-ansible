# Ansible scripts for McKylän Superarcade

## Very rough installation guide

### Debian installation

- Get Debian 10.3 amd64 `netinstall` image.
- Write image it to USB stick.
- Make sure that the target machine is set to "legacy mode" in BIOS to avoid Debian being installed in UEFI mode to avoid UEFI problems.
- Boot from USB stick.
- Boot in non-graphical installer, because that's what the rest of the guide follows.
- When asked for hostname, use hostname `dedicab-<machine here>`.
- When asked for domain, set nothing.
- When asked to create user, use username `stepmania`.
- Partition as you like. Using whole disk as a single partition is good. Make sure there is some swap.
- Eventually you will asked to "select software". Select the following:
    - "...Xfce"
    - "SSH server"
    - "standard system utilities"
    - Unselect everything else
- After the installation is complete, boot to the new Debian system!

### Preparing for running Ansible

- Log in as `stepmania` user.
- Start terminal.
- Run `su -c "gpasswd -a stepmania sudo"` to add `stepmania` to `sudo` group.
- Reboot (or log out + log in) for the group change to take effect.
- Now we need to add the SSH key to the system so we can continue with Ansible. If you have Github account, you can do the following:
    - `sudo apt install curl`
    - `mkdir ~/.ssh`
    - `curl https://github.com/<GitHub username>.keys > ~/.ssh/authorized_keys`
- Let's set the `stepmania` user to be able to run with passwordless `sudo`, so we don't need to care about password when running Ansible. Let's do the following:
    - Run `sudo /sbin/visudo`.
    - Add row `stepmania ALL=(ALL) NOPASSWD:ALL` to the bottom.
    - Save. Now `sudo` should work without password.

### Running Ansible script for full install

Now we can start running commands on a remote computer with Ansible.

- Create file `vault-key` to the root of this repository and set the Ansible vault key there. Ask Kauhsa about it.
- Run `ansible-playbook -i inventories/makkyla full-install.yml --diff --vault-password-file vault-key --limit <machine ip>`.
- Now we will get to the slightly janky part of this. Reboot and start Stepmania. It will not have the correct configuration yet - we just need to do this once to generate initial `Preferences.ini` and some other files.
- Close Stepmania. It might be difficult, since you might not have proper key bindings to do that. I suggest connecting to the machine via SSH and executing `pkill stepmania`.
- Run `ansible-playbook -i inventories/makkyla full-install.yml --diff --vault-password-file vault-key --limit <machine ip>` again. Reboot.
- Copy your songs and courses to the `/home/stepmania/content` folder.