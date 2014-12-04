nimble-wrapper
==============

nimble-wrapper is a small wrapper around the nimble package manager that
transparently bootstraps nimble installations in user home directories
from a system nimble installation. This allows nimble to be distributed by
system package managers while staying close to upstream nimble's default
settings. (nimble installs itself into a user's home directory by default.)

How It Works
------------

When ran, nimble-wrapper first checks if there is a nimble installation in the
user's home directory. If there isn't one then nimble-wrapper bootstraps one
from the system's nimble installation. From then on, nimble-wrapper will
redirect all calls to the user's nimble installation.

Installation
------------

To install, simply run:

```
$ nimrod c -r install $installdir
```

where `$installdir` is the path to the directory that you want to install
nimble-wrapper to. The install script will create two directories in this
location, `bin` and `nimble`, and will populate them. If `$installdir` is
omitted, the install script will create a `nimble_wrapper` folder in the
current directory and install to it.
