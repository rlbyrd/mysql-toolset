#!/bin/bash
#
# Make sure you're using GNU find and gnu sed.

find . -type f -exec sed -i 's/OLDSTRING/NEWSTRING/g' {} +