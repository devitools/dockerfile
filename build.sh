#!/usr/bin/env bash

DEVITOOLS_DIR_NAME=$(dirname "$(readlink -f "${0}")")

DEVITOOLS_IMAGE=${1}
DEVITOOLS_VERSION=${2}
DEVITOOLS_NAMESPACE=lyseontech/${DEVITOOLS_IMAGE}
DEVITOOLS_VALID=""

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function __validate
{
  DEVITOOLS_VALID=""
  for entry in "${2}"/*
  do
    option=$(basename "${entry}")
    if [[ "${option}" == "${1}" ]]; then
      DEVITOOLS_VALID="true"
      return
    fi
  done
}

function __build
{
  __validate "${DEVITOOLS_IMAGE}" "${DEVITOOLS_DIR_NAME}"
  if [[ -z ${DEVITOOLS_VALID} ]];then
    echo -e "${RED} ~> Invalid image '${DEVITOOLS_IMAGE}'${NC}"
    return
  fi

  __validate "${DEVITOOLS_VERSION}" "${DEVITOOLS_DIR_NAME}"/"${DEVITOOLS_IMAGE}"
  if [[ -z ${DEVITOOLS_VALID} ]]; then
    echo -e "${RED} ~> Invalid version '${DEVITOOLS_VERSION}'${NC}"
    return
  fi

  if [[ ! -d "${DEVITOOLS_DIR_NAME}/${DEVITOOLS_IMAGE}/${DEVITOOLS_VERSION}" ]]; then
    echo -e "${RED} ~> Invalid build '${DEVITOOLS_DIR_NAME}/${DEVITOOLS_IMAGE}/${DEVITOOLS_VERSION}'${NC}"
    return
  fi

  if [[ ! -d "${DEVITOOLS_DIR_NAME}/${DEVITOOLS_IMAGE}/latest" ]]; then
    mkdir -p "${DEVITOOLS_DIR_NAME}/${DEVITOOLS_IMAGE}/latest"
  fi
  cp "${DEVITOOLS_DIR_NAME}/${DEVITOOLS_IMAGE}/${DEVITOOLS_VERSION}/Dockerfile" "${DEVITOOLS_DIR_NAME}/${DEVITOOLS_IMAGE}/latest/Dockerfile"

  echo -e "${YELLOW} ~> Building '${DEVITOOLS_NAMESPACE}' with '${DEVITOOLS_DIR_NAME}/${DEVITOOLS_IMAGE}/${DEVITOOLS_VERSION}/Dockerfile'${NC}"
  docker build -t "${DEVITOOLS_NAMESPACE} ${DEVITOOLS_DIR_NAME}/${DEVITOOLS_IMAGE}/${DEVITOOLS_VERSION}"

  echo -e "${YELLOW} ~> Tagging '${DEVITOOLS_IMAGE}' with 'v${DEVITOOLS_VERSION}'${NC}"
  docker tag "${DEVITOOLS_NAMESPACE}" "${DEVITOOLS_NAMESPACE}":"${DEVITOOLS_VERSION}"

  echo -e "${YELLOW} ~> Pushing '${DEVITOOLS_NAMESPACE}:${DEVITOOLS_VERSION}'${NC}"
  docker push "${DEVITOOLS_NAMESPACE}":"${DEVITOOLS_VERSION}"

  echo -e "${YELLOW} ~> Pushing '${DEVITOOLS_NAMESPACE}:latest'${NC}"
  docker push "${DEVITOOLS_NAMESPACE}:latest"

  echo -e "${GREEN} ~> All successfully done ${NC}"
}

__build
