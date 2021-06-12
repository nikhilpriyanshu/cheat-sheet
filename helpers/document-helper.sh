#!/bin/bash

function assistme.document-helper.list-documents() {
    echo $DOCUMENT_LIST
}

function assistme.document-helper.show-document() {
    echo $DOCUMENT_LIST | grep $1 &> /dev/null
    if [[ $? -eq 0 ]]; then
        fetch ${DOCUMENT_PATH_MAP[BASE_URL]}${DOCUMENT_PATH_MAP[$1]}
    fi
}

function main() {
    assistme.document-helper.list-documents
    assistme.document-helper.show-document
}

main