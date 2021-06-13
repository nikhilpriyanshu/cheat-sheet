#!/bin/bash

function fetch() {
    local response="$(curl --silent -o- $1)"
    local responseCode=$?
    if [[ $responseCode -eq 0 ]]; then
        echo -e "$response"
        return 0
    fi
    return -1
}

function main() {
    fetch "$url"
}

url="$1"
main $url
