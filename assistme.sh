#!/bin/bash

GIT_BRANCH="/main"
GIT_PROFILE_LINK="https://raw.githubusercontent.com/nikhilpriyanshu"
SCRIPT_PATH="$GIT_PROFILE_LINK/cheat-sheet$GIT_BRANCH/metadata/script-metadata/script_paths"
DOCUMENT_METADATA_PATH="$GIT_PROFILE_LINK/cheat-sheet$GIT_BRANCH/metadata/document-metadata/document_paths"
SCRIPT_HELPER_SCRIPT_PATH="$GIT_PROFILE_LINK/cheat-sheet$GIT_BRANCH/helpers/script-helper.sh"
DOCUMENT_HELPER_SCRIPT_PATH="$GIT_PROFILE_LINK/cheat-sheet$GIT_BRANCH/helpers/document-helper.sh"
FETCH_SCRIPT_PATH="$GIT_PROFILE_LINK/cheat-sheet$GIT_BRANCH/resources/scripts/fetch.sh"
SCRIPT_BASE_URL="$GIT_PROFILE_LINK/cheat-sheet$GIT_BRANCH/resources/scripts"
DOCUMENT_BASE_URL="$GIT_PROFILE_LINK/cheat-sheet$GIT_BRANCH/resources/documents"
declare -A SCRIPT_PATH_MAP
declare -A DOCUMENT_PATH_MAP

function sourceAll() {
    source <(curl --silent -o- $SCRIPT_HELPER_SCRIPT_PATH) &> /dev/null
    source <(curl --silent -o- $DOCUMENT_HELPER_SCRIPT_PATH) &> /dev/null
    source <(curl --silent -o- $SCRIPT_BASE_URL${SCRIPT_PATH_MAP["fetch"]}) $SCRIPT_BASE_URL${SCRIPT_PATH_MAP["fetch"]} &> /dev/null
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
        local length=$(($(echo ${PATH_MAP[$key]} | grep -o "/" | wc -l)+1))
        LIST+=$(echo ${PATH_MAP[$key]} | cut -d "/" -f "$length")" "
    done
    echo $LIST
}

function recreateDocumentHelper() {
    readPaths $DOCUMENT_METADATA_PATH
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