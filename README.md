SLURM Quickstart Guide
==
The [*SLURM*][1] is an open source, fault-tolerant, and highly scalable cluster management and job scheduling system for Linux clusters.

This quickstart guide will help you get a SLURM cluster up in running quicker than any other guide. This expounds on the [SLURM quickstart guide][2].


# Requirements

* A [Digital Ocean][4] account and the ability to install two droplets with a [Debian][9] 9.3 x64 distro

* SSH capability (with X11 forwarding and server if possible; I use [MobaXterm][7] on Windows)

* How to use vim a bit
    - i for insert
    - esc to exit insert mode
    - x to delete a single character
    - :wq to save and quit
    - :q to quit without save
    - u to undo
    - Arrow keys/hjkl to move

# Create a Debian Droplet

Log in to [Digital Ocean][4].

Create a *single* droplet with a Debian 9.3 x64 distro. Choose the cheapest droplet size (e.g. Standard droplet, 1 GB, 1vCPU, 25 GB Storage @ $5/month).

Choose any datacenter region and any additional options.

Name the hostname `debian-1`.

Create the droplet.

Later, after you configure this droplet, you'll clone it to another droplet so that you have two identical droplets.

SSH into the droplet as `root` using the credentials emailed to you. It will prompt you to change your password.

# Configure the Droplet

Get Debian package stuff up to date:

    apt-get upgrade
    apt-get update

Install the SLURM Debian package:

    apt-get install slurm-wlm

This installs SLURM 16.05.9.

Install these other packages:

    apt-get install build-essential git man xauth firefox-esr

Now create users other than `root`. See [Configuring Users and Groups](#configuring-users-and-groups) for more information.

# Duplicate the Droplet

At this point, you want to duplicate your newly-configured Debian droplet.

In [Digital Ocean][6], click the `Images` tab and then the `Snapshots` tab. Select the `debian-1` droplet you just created. Click `Take Snapshot`.

Once the snapshot is complete, create another droplet like before, except during the `Choose an image` section, select the newly-created snapshot under the `Snapshots` tab.

In a separate terminal, SSH into `debian-2` as `root` and update your password.

You now have two identical Debian distros to work with in SLURM. Take note of their IP addresses.

# slurm.conf file

Make sure you are on the `debian-1` droplet as `root`.

If you try to run the `slurmctld` command to start SLURM, it will complain that there is no file at `/etc/slurm-llnl/slurm.conf`. So you need to create it.

If you want to use the slurm html conf generator, see the [Configurator](#configurator) section. Otherwise, use the template provided in this repo as follows:

Download a copy of the template `slurm.conf` file:

    cd ~
    git clone https://github.com/hintron/slurm_quickstart
    cp slurm_quickstart/slurm_confs/slurm.conf.2_node slurm.conf

In `slurm.conf`, you need to insert the IP addresses of your SLURM nodes. Replace `<TODO: INSERT IP ADDRESS>` with the IP address of the corresponding droplets in Digital Ocean. If you named the droplets something different than `debian-1` and `debian-2`, change them as well:

    vim slurm.conf

Now `slurm.conf` is ready to be installed in its proper location:

    mv slurm.conf /etc/slurm-llnl/

Note that this conf file specifies a partition called `testing` that has two compute (`slurmd`) nodes: `debian-1` and `debian-2`. `debian-1` will act as both `slurmctld` and a `slurmd`.

# Starting SLURM

Run `top`. You should see a `munged` process owned by `munge`. If not, run the `munged` command.

Start `slurmctld`:

    slurmctld

If it started correctly, there will be no output. Run `top` again and you will see a `slurmctld` process owned by user `slurm`.

Now start the compute node on `debian-1`:

    slurmd

If you run `top` again, you will see it as being owned by `root` this time.

Verify that `debian-1` shows up as a compute node now in SLURM via the `sinfo` command.

`slurm.conf` needs to be the same on all nodes in the cluster.
So send `slurm.conf` from `debian-1` to `debian-2`:

    scp /etc/slurm-llnl/slurm.conf root@111.111.111.111:/etc/slurm-llnl/

Make sure to replace `111.111.111.111` with the actual IP address for `debian-2`.

In your separate `debian-2` terminal, start the compute node:

    slurmd

Type `sinfo` and you should see two nodes!


# Trying out SLURM

On `debian-1`, switch to your preferred sudo user:

    su hintron

Now let's get a bash script ready for testing out SLURM:

    cd ~
    sudo cp /root/slurm_quickstart/scripts/x_seconds.sh .
    chmod 755 x_seconds.sh

Let's try running the script a few times on SLURM!

    sbatch ./x_seconds.sh 60 5
    sbatch ./x_seconds.sh 60 5
    sbatch ./x_seconds.sh 60 5

Each script invocation will run for 60 seconds total while printing out a timestamp every 5 seconds.

To see the jobs you just scheduled:

    squeue

You should see 3 jobs, with two of them running, one on each node. Success!

To see the stats on the jobs:

    scontrol show job

You will see that the output of the script is printed to `~/slurm-<JOBID>.out` for the user that submitted it on the node that it was run on.

To cancel any pending or running jobs:

    scancel <JOBID>

Congratulations! You now have a basic SLURM cluster that you can schedule jobs to! You now know enough to be dangerous.

For more information on SLURM commands and use cases, visit [Quick Start User Guide][3].

Also, read the man pages (e.g. `man slurm` or `man slurm.conf`). They are actually quite informative.

Here is a [simple 8-minute introduction video on how to use SLURM][8].

# More SLURM Commands

If you want to have command-line access to a node, switch to the user you want and type:

    salloc

Then, execute a command using the srun command. e.g.

    srun hostname

This will not print out the hostname of the your computer, but of the node that was allocated to you.

To deallocate the node allocated by `salloc`, simply run the `scancel` command on the allocated job.


# Starting slurmctld and slurmd on boot

To start SLURM on boot, you need to enable `slurmctld` and `slurmd` as services with `systemd` via the `systemctl` command:

    systemctl enable slurmctld
    systemctl enable slurmd

See [How To Use Systemctl to Manage Systemd Services and Units][5].

# Rebooting slurmctld and slurmd after changing slurm.conf

Many changes you make to `slurm.conf` will not require you to restart any of the SLURM daemons. Simply run

    scontrol reconfigure

See `man scontrol` and look for reconfigure for more information.

However, if you are adding or removing nodes to the cluster, you will need to restart `slurmctld`.

To kill it, run `top`, find the `slurmctld` process, and press `k`. Input the process ID, and then enter either `15`, or if that doesn't kill it, `9`.

To start it again, simply run the `slurmctld` command. Check to make sure the cluster changed by running `sinfo`.


# Configuring Users and Groups

To create users, do:

    adduser hintron
    adduser thor
    adduser capn
    adduser ironman
    adduser panther

Grant your preferred user sudo permission by adding them to the sudo group:

    usermod -aG sudo hintron

You can also create user groups:

    groupadd marvel

Now add a user to a group:

    usermod -aG marvel thor
    usermod -aG marvel capn
    usermod -aG marvel ironman
    usermod -aG marvel panther

To see all the groups:

    vim /etc/group

To see who's in a specific group:

    grep marvel /etc/group

Note that the SLURM Debian package automatically created the `slurm` and `munge` users already.

You are now ready to duplicate the droplet. [Jump to Duplicate the Droplet](#duplicate-the-droplet)


# Configurator

The `xauth` package should already be installed. This is needed to have the Firefox GUI forwarded properly over SSH via X11. However, you need to restart the server and log in again for `xauth` to take effect.

    reboot -h now

Now you can run the configurator html page in Firefox:

    firefox /usr/share/doc/slurmctld/slurm-wlm-configurator.easy.html &

Right click and save the page. Save it as a *text file*, not as a complete web page. Save it to `/etc/slurm-llnl/slurm.conf`.

Comment or remove the last line in the file that contains `MaxTime`, so `slurmctld` can start without error.

You are now ready to start SLURM. [Jump to Starting SLURM](#starting-slurm)


[1]: https://slurm.schedmd.com/ "SLURM"
[2]: https://slurm.schedmd.com/quickstart_admin.html "Quickstart"
[3]: https://slurm.schedmd.com/quickstart.html "SLURM Architecture Overview"
[4]: https://www.digitalocean.com/ "Digital Ocean"
[5]: https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units "How To Use Systemctl to Manage Systemd Services and Units"
[6]: https://cloud.digitalocean.com/ "Digital Ocean Dashboard"
[7]: https://mobaxterm.mobatek.net/ "MobaXterm"
[8]: https://youtu.be/U42qlYkzP9k "Introduction to SLURM Tools"
[9]: https://www.debian.org/ "Debian"
