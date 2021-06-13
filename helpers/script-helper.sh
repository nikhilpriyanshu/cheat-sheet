#!/bin/bash

function assistme.script-helper.list-scripts() {
    echo $SCRIPT_LIST
}

function assistme.script-helper.show-script() {
    echo $SCRIPT_LIST | grep $1 &> /dev/null
    if [[ $? -eq 0 ]]; then
        fetch $SCRIPT_BASE_URL${SCRIPT_PATH_MAP[$1]}
    else
        echo "Failed to fetch script $1" 
    fi
}

function main() {
    assistme.script-helper.list-scripts
    assistme.script-helper.show-script
}

main