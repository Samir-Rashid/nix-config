# https://github.com/DavHau/mach-nix#build-a-virtualenv-style-python-environment-from-a-requirementstxt

nix shell github:DavHau/mach-nix

  Build a virtualenv-style python environment from a requirements.txt

mach-nix env ./env -r requirements.txt

  This will generate the python environment into ./env. To activate it, execute:

nix-shell ./env

  The ./env directory contains a portable and reproducible definition of your python environment. To reuse this environment on another system, just copy the ./env directory and use nix-shell to activate it.
