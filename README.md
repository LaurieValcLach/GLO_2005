# GLO_2005
Projet de session du cours de bases de données

## Conventions

### New branch

```bash
git switch -c issue_number-branch_name
```

### Merge branch

1.

```bash
git merge main
```

2. Open a pull request

### Commit

```
description of change (#issue_number)
```

For example,

```
Fix the network (#2)
```
## create virtual environnement
### Linux
sudo apt-get install python3-venv  
python3 -m venv .venv
source .venv/bin/activate

### macOS
python3 -m venv .venv
source .venv/bin/activate

### Windows
py -3 -m venv .venv
.venv\scripts\activate
