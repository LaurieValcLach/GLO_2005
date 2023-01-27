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
```bash
sudo apt-get install python3-venv 
```
```bash
python3 -m venv .venv
```
```bash
source .venv/bin/activate
```

### macOS
```bash
python3 -m venv .venv
```
```bash
source .venv/bin/activate
```

### Windows
```bash
py -3 -m venv .venv
```
```bash
.venv\scripts\activate
```
