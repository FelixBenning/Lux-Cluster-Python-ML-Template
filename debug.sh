#!/bin/bash

# use like:
# . debugh.sh my_file.py
# then attach vscode debugger

python -m debugpy --listen 0.0.0.0:5678 --wait-for-client $1
