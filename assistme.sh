#!/bin/bash

GIT_PROFILE_LINK="http://localhost:8080"
SCRIPT_PATH="$GIT_PROFILE_LINK/cheat-sheet/metadata/script-metadata/script_paths"
DOCUMENT_PATH="$GIT_PROFILE_LINK/cheat-sheet/metadata/document-metadata/document_paths"
SCRIPT_HELPER_SCRIPT_PATH="$GIT_PROFILE_LINK/cheat-sheet/helpers/script-helper.sh"
DOCUMENT_HELPER_SCRIPT_PATH="$GIT_PROFILE_LINK/cheat-sheet/helpers/document-helper.sh"
FETCH_SCRIPT_PATH="$GIT_PROFILE_LINK/cheat-sheet/resources/scripts/fetch.sh"
declare -A SCRIPT_PATH_MAP
declare -A DOCUMENT_PATH_MAP

function sourceAll() {
    source <(curl --silent -o- $SCRIPT_HELPER_SCRIPT_PATH) &> /dev/null
    source <(curl --silent -o- $DOCUMENT_HELPER_SCRIPT_PATH) &> /dev/null
    source <(curl --silent -o- ${SCRIPT_PATH_MAP[BASE_URL]}${SCRIPT_PATH_MAP["fetch"]}) ${SCRIPT_PATH_MAP[BASE_URL]}${SCRIPT_PATH_MAP["fetch"]} &> /dev/null
}

function readPaths() {
    local response=$(curl --silent -o- $1)
    local responseCode=$?
    if [[ $responseCode -eq 0 ]]; then
        PATH_LIST=$(echo $response | tr " " "\n")
    fi
}

function storePathsAsMap() {
    unset PATH_MAP
    declare -gA PATH_MAP
    for path in $PATH_LIST; do
        local key=$(echo $path | cut -d "=" -f 1)
        local value=$(echo $path | cut -d "=" -f 2)
        PATH_MAP[$key]=$value
    done
}

function createListFromMap() {
    local key
    LIST=""
    for key in ${!PATH_MAP[@]}; do
        if [[ "$key" == "BASE_URL" ]]; then
            continue
        fi
        local length=$(($(echo ${PATH_MAP[$key]} | grep -o "/" | wc -l)+1))
        LIST+=$(echo ${PATH_MAP[$key]} | cut -d "/" -f "$length")
    done
    echo $LIST
}

function recreateDocumentHelper() {
    readPaths $DOCUMENT_PATH
    storePathsAsMap
    for key in ${!PATH_MAP[@]}; do
        DOCUMENT_PATH_MAP[$key]=${PATH_MAP[$key]}
    done
    DOCUMENT_LIST=$(createListFromMap)
}

function recreateScriptHelper() {
    readPaths $SCRIPT_PATH
    storePathsAsMap
    for key in ${!PATH_MAP[@]}; do
        SCRIPT_PATH_MAP[$key]=${PATH_MAP[$key]}
    done
    SCRIPT_LIST=$(createListFromMap)
}

function main() {
    recreateDocumentHelper
    recreateScriptHelper
    sourceAll
}

main