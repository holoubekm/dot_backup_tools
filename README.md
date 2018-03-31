# .dot files backup scripts
This directory contains backup system made to easify the **.dot files** management. 
It makes setting-up a new system from the scratch more bearable.

### Features
* Scripts maintain one global `git` repository keeping all **.dot** files versioned and kept together.
* Build on the top of `git`, `bash` and `GNU make`. Make system is not necesary - works just as a driver - you may avoid using it completely.
* Files are stored using absolute paths to avoid collisions.
* Backups from the same hostname are kept on the branch named as the hostname.
* List of explicitly and implicitly installed packages are saved as well if using the `pacman` or `apt-get` package manager.
Feel free to customize scripts. Feedback is more than welcomed.

### The first run
```bash
git clone https://github.com/holoubekm/dot_backup_tools
cd dot_backup_tools
cp ./example/backup.list .
```
Now please modify the backup.list and specify files to be backed-up
Lines with the leading hash "#" are considered to be comments
You can specify files as well as whole directories

```bash
make
# The backup repo doesn't exist yet
# Please enter URL or path of the git repository you would like to store backup to: 
# >
```

Now let's create a custom git repository with write permissions and copy-paste it's URL or path
Example: `git://github.com/holoubekm/dot_backup`

```bash
git://github.com/holoubekm/dot_backup
```

If everything goes well the files will be automatically added, commited and pushed to the origin

### How to load data from the backup
```bash
cd ./backup
git checkout "${HOSTNAME}" # Checkout the branch of the given hostname 
cd ./${BACKUP_REPO}/${USER}/ABS_PATH
```
Where
* `BACKUP_REPO` - Name of the backup git repo. Ex. `dot_files_backup`
* `ABS_PATH` - Absolute path of the requested file. Ex. `/home/user/.bashrc`

### Makefile commands overview
`Makefile` commands are 1 to 1 bound with files in the `./scripts` folder.

```bash
make init -> ./scripts/init.sh
```
Add the backup submodule for the first time. The module get afterwards initialized and updated as well

```bash
make checkout -> ./scripts/checkout.sh
```
Checkout branch with the name of `${HOSTNAME}` from the submodule.

```bash
make copy_files -> ./scripts/copy_files.sh
```
Read entries from the `backup.list`, copy each of them to the `backup` directory. The script has several config flags one can modify:
* `HONOR_COMMENTS` - if commend in the `backup.list` should be honored by the script
* `PRUNE_GIT_REPOS` - remove any `.git` folder copied to the `backup` directory

Please feel free to modify `cp` flags in the `copy_files.sh` script.
```bash
# Copy a single file
cp --no-preserve mode,ownership --parents "$source_abs" "$OUTPUT_DIR" 2>&1
# Copy a directory
cp --no-preserve mode,ownership -R --parents "$source_abs" "$OUTPUT_DIR" 2>&1
```

```bash
make add -> ./scripts/add.sh
```
Use a git add command to add files

```bash
make commit -> ./scripts/commit.sh
```
Commit modified and new changes among .dot files.
The commit message can be changed in the file `commit.sh`:
```bash
COMMIT_MSG="${HOSTNAME} $(date '+backup_%Y-%m-%d_%H-%M')"
```

### Notice
Please keep in mind that this package is ment mostly as a **manager for lightweight** readable **files**. 
While it's certainly possible to backup binary files it's discouraged to do so mainly due to bad performance.

Please **consider carefully** which files or folder you really want to backup. Incautious one can easily share `ssh keys`, `credentials`, `api keys` and other private stuff. 

If copying directories the size may grow rapidly - consider adding only files to the `backup.list`.
