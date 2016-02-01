#!/bin/bash
set -e

while true 
do 
inotifywait -r -e modify,attrib,close_write,move,create,delete lib &&
rm -Rf ~/.atom/dev/packages/autocomplete-computercraft &&
cp -R ../autocomplete-computercraft ~/.atom/dev/packages/autocomplete-computercraft
done
