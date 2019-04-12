#!/bin/bash
# Substitute the [COMMAND] with any command you need to run on all the associated files; ditto '*.txt'. “print0” 
# automagically escapes filenames with spaces or weird characters.

find . -name '*.txt' -print0 | xargs -0 [COMMAND]

