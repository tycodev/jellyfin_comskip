#!/usr/bin/env sh
filePath=$1
iteration=0
maxRetries=5

echo "Comskip launched under user $(whoami) for file $filePath"

while [ "$iteration" -lt "$maxRetries" ]; do
    /usr/bin/env comskip --ini="/comskip.ini" "$filePath"
    comskipReturn=$?
    echo "Comskip returned: $comskipReturn"
    if [ "$comskipReturn" -eq "0" ]; then
        exit 0
    fi
    iteration=$((iteration+1))
done

echo "Comskip failed with error code $comskipReturn"
exit 1

