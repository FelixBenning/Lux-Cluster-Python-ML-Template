## Initial Setup

1. Create an Account:
    > https://service.uni.lu/sp?id=sp_research and then HPC account creation
2. Add a **public ssh key to the account**. If you already have generated an ssh key
pair you would likely find it in the folder `~/.ssh`, otherwise generate a new
pair with the command `ssh-keygen`. In the folder `~/.ssh` you should then find
    - `id_rsa` the private key
    - `id_rsa.pub` the public key.

    You need to upload the **public** key to the university account. The private
    key is used to authenticate you. If you did not protect it with a password
    in the key generation step, this allows connecting to the server without typing
    your password every time. Just make sure that nobody else has access to the
    private key.

2. Connect (e.g. using [VSCode](https://code.visualstudio.com/)'s [Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) Extension pack)
    1. Click the button on the lower left corner of VSCode
    2. `Connect to Host `
    3. `Configure SSH Hosts`
    4. `/Users/<yourname>/.ssh/config` and add the following to the file

        ```sh
        Host iris-cluster
            Hostname access-iris.uni.lu
            User <username>
            Port 8022
            ForwardAgent no
        ```
    5. Click on the button in the lower left corner of VSCode again and choose `iris-cluster`



3. Configure git
    ```sh
    git config --global user.name "Your name"
    git config --global user.email <your.email@uni.lu>
    git config --global core.autocrlf input
    ```

    Ideally, you would also sign your commits to authenticate that they come from you. If you want to do so, create a gpg signing key and
    ```sh
    git config --global commit.gpgsign true

    gpg --import ~/git_private_signing_gpg.key
    gpg --list-secret-keys
    # find the key you added and copy the key ID

    gpg --edit-key <key ID you just added> trust quit
    # choose full trust (5)
    # confirm (y)

    git config --global user.signingkey <key ID>

    ```
4. Install Micromamba (Package manager), see https://hpc-docs.uni.lu/environment/conda/#the-micromamba-package-manager


## General Cluster Information

When you login to the cluster using the Remote development extension, you are connected to a **login node**.
The actual compute happens on **compute nodes**, which you can control with SLURM commands. In particular, you
are not supposed to install software on the login node with the exception of the
package manager Micromamba.


### SLURM Commands

1. Interactive use of compute nodes (limited to a maximum of 2h)
    1. Reserve an interactive node (maximum of 2h)
        ```shell
        si -t 02:00:00
        ```
    2. Reserve an interactive node with access to GPUs (maximum of 2h)
        ```shell
        si-gpu -t 02:00:00 -G 1 -c 7
        ```
        `-G` is the number of GPU's and `-c` is the number of CPU cores.
        The GPUs are grouped in groups of 4 with 4*7 CPU cores, so you
        are supposed to reserve 7n CPU cores with n GPUs and try to limit
        yourself to 4 GPUs.

2. List current jobs/reserved nodes
    ```shell
    squeue
    ```
    with `sq` listing only your own jobs.

3. Actual workloads should be sheduled asynchronusly using `sbatch` (https://slurm.schedmd.com/sbatch.html).
For this it makes sense to create a launch script and launch it with
    ```shell
    $ sbatch launch_script.sh [arg1,...]
    ```
    where the (potential) arguments `[arg1,...]` are accessed with `$1`, `$2` etc. in the `launch_sript.sh` that may look like this:
    ```shell
    # launch_script.sh
    
    #SBATCH --job-name=<your job name>

    #SBATCH --nodes=1
    #SBATCH --ntasks-per-node=1
    #SBATCH --cpus-per-task=7n  # count of CPU cores
    #SBATCH --partition=gpu # ["batch" (CPU), "bigmem" (large memory)]
    #SBATCH --gpus-per-task=n # count of GPUs per task
    #SBATCH --qos=normal # Quality of Service  https://hpc-docs.uni.lu/slurm/qos/


    python my_task.py $1
    ```
    any of the options in the file can be overridden at the call
    e.g.
    ```shell
    $ sbatch --nodes=2 launch_script.sh
    ```


## Setting up the Python packages (in particular Pytorch)

It is good practice to reccord the dependencies in an environment file. See `environment.yml` in this template.

The remaining setup should be done on a compute node. It may need to be a GPU node to compile pytorch for GPU usage I am not sure.
Reserve an interactive one using SLURM.


```shell
micromamba env create -f environment.yml
micromamba activate project-name
```

Whenever you reconnect to the server you first need to reactivate the project to make all the installed packages available. Different projects can have different installed packages.

After changes to `environment.yml` run
```shell
micromamba env update -f environment.yml
```

Check if `pytorch` has acces to the GPU by running diagnostic script
```shell
python ensure_gpu.py
```
Ideally you would get `torch cuda available: True` and you can ignore the other diagnostic information. Otherwise ensure this works before proceeding.

## Debugging using VSCode

0. Install the `python` extension in VSCode
1. Enter an interactive compute node
2. find its name, (use the command `hostname`), should be something like `iris-***`
3. set a breakpoint in `your_python_file.py`.
4. In the interactive compute node, source the
script `debug.sh`, that is type

    ```shell
    $ . debug.sh your_python_file.py
    ```

5. In VScode click the start symbol in the 'run and debug' panel.
    > The `launch.json` file in this template is configured to
    attach to the process started by the `debug.sh` file.


> **Why is this so complicated?** The issue is that the VSCode server is on the login node, while the debugging should happen on the compute node. If VScode starts the debugging process itself, it starts it on the login node and typically fails because the python environment is not set up there. The `debug.sh` starts
the process on the compute node and tells it to wait for vscode
to attach.



