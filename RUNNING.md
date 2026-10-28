# Running Eden locally

How to get this repo running on your own machine for development.
Works on Windows, macOS and Linux. Only a few steps differ by OS, and
those are marked.

Eden is a [web2py](https://github.com/web2py/web2py) application: you
install web2py, put Eden inside it, and run web2py.

## 1. Prerequisites

- **Python 3.11 or newer** ([python.org](https://www.python.org/downloads/)).
  On Windows, tick "Add python.exe to PATH" in the installer.
- **Git** ([git-scm.com](https://git-scm.com/downloads)).

Check both are installed:

```
python --version    (macOS/Linux: python3 --version)
git --version
```

## 2. Get web2py and Eden

Run these in a terminal (Windows: PowerShell or Command Prompt), from
whatever folder you keep projects in:

```
git clone https://github.com/web2py/web2py.git
cd web2py
git reset --hard 9005306
git submodule update --init --recursive
git clone https://github.com/hazzyxz/eden.git applications/eden
```

`9005306` is web2py 3.3.3, the version Eden supports. Don't use newer.

You end up with:

```
web2py/
├── web2py.py
└── applications/
    └── eden/        <- this repo
```

> **Already have this repo cloned somewhere else?** Link it into web2py
> instead of cloning again (run inside `web2py/applications`):
>
> - macOS/Linux: `ln -s /path/to/eden eden`
> - Windows (admin terminal or Developer Mode on): `mklink /D eden C:\path\to\eden`

## 3. Create a virtual environment and install packages

Stay in the `web2py` folder.

**Create and activate** (differs by OS):

| OS | Create | Activate |
|---|---|---|
| macOS / Linux | `python3 -m venv .venv` | `source .venv/bin/activate` |
| Windows PowerShell | `py -m venv .venv` | `.venv\Scripts\Activate.ps1` |
| Windows Command Prompt | `py -m venv .venv` | `.venv\Scripts\activate.bat` |

Your prompt now starts with `(.venv)`. From here on, `python` and `pip`
are the same commands on every OS.

**Install packages:**

```
pip install -r applications/eden/requirements.txt
pip install pyparsing shapely geopy xlrd xlwt openpyxl reportlab Pillow
```

The first line is the minimum; the second adds maps, spreadsheet
import/export and PDF export. `optional_requirements.txt` lists more
for special features (GDAL for shapefiles, pyserial for SMS modems,
etc.); you don't need them to run the app.

## 4. Configure Eden

Copy the config template into place:

**macOS / Linux:**

```
cp applications/eden/modules/templates/000_config.py applications/eden/models/
```

**Windows** (PowerShell or Command Prompt):

```
copy applications\eden\modules\templates\000_config.py applications\eden\models\
```

Open `applications/eden/models/000_config.py` in any editor and change
these two lines:

```python
FINISHED_EDITING_CONFIG_FILE = True    # was False
settings.base.debug = True             # was False
```

This file is gitignored, so your local changes won't be committed.

## 5. First run (sets up the database)

```
python web2py.py -S eden -M -R applications/eden/static/scripts/tools/noop.py
```

This creates a local SQLite database and loads demo data. It takes
about a minute and ends with `*** FIRST RUN COMPLETE ***`. A few
`WARNING` lines are normal.

## 6. Start the server

```
python web2py.py --no_gui -a choose-a-password
```

Open **http://127.0.0.1:8000/eden** and log in with a demo account
(both use the password `testing`):

- `admin@example.com`: administrator
- `normaluser@example.com`: normal user

The `-a` password is for web2py's admin panel at
http://127.0.0.1:8000/admin, where you can read error tickets.

Stop the server with **Ctrl+C**.

## Every time after that

Open a terminal in the `web2py` folder, activate the venv (table in step 3),
then:

```
python web2py.py --no_gui -a choose-a-password
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `python` / `python3` not found (Windows) | Use `py` instead, or reinstall Python with "Add to PATH" ticked. |
| PowerShell says running scripts is disabled | Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once, then activate again. |
| Port 8000 already in use | Add `-p 8001` to the start command and use http://127.0.0.1:8001/eden. |
| Page says the config file isn't finished | You skipped the `FINISHED_EDITING_CONFIG_FILE = True` edit in step 4. |
| `unresolved dependency` warnings | Optional features. Install the named package with `pip` only if you need that feature. |
| Want a fresh database | Stop the server, delete everything inside `applications/eden/databases/`, then redo step 5. |
| Something crashed in the browser | Open the error ticket link, or go to http://127.0.0.1:8000/admin and log in with your `-a` password. |

## Running with Docker instead

Skips steps 1–6. Needs only Docker. From this repo's folder:

```
docker compose up --build
```

Open **http://127.0.0.1:8000/eden** (same demo logins). The first start
builds the database and takes a minute or two. The repo is mounted into
the container, so code edits apply live, and it uses (or creates)
`models/000_config.py` and `databases/` in this folder. web2py's admin
panel is blocked from outside the container; error tickets are saved in
`errors/`. Stop with **Ctrl+C**, or `docker compose down` if you started
it with `-d`.

The full developer handbook is in [docs/](docs/) and on
[ReadTheDocs](https://eden-asp.readthedocs.io).
