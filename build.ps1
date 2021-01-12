# powershell

$BULD_DIR_NAME=$PSScriptRoot

$BULD_IMAGE=$args[0]
$BULD_VERSION=$args[1]
$BULD_NAMESPACE="devitools/${BULD_IMAGE}"
#$BULD_VALID=""

Write-Host $BULD_IMAGE -ForegroundColor Yellow
Write-Host $BULD_VERSION -ForegroundColor Yellow
Write-Host $BULD_NAMESPACE -ForegroundColor Yellow

#function __validate
#{
#    BULD_VALID=""
#    #    for entry in "${2}"/*
#    #    do
#    #        option=$(basename "${entry}")
#    #        if [[ "${option}" == "${1}" ]]; then
#    #            BULD_VALID="true"
#    #            return
#    #        fi
#    #    done
#}

function __build
{
#    __validate "${BULD_IMAGE}" "${BULD_DIR_NAME}"
#    #    if [[ -z ${BULD_VALID} ]];then
#    #        echo -e "${RED} ~> Invalid image '${BULD_IMAGE}'${NC}"
#    #        return
#    #    fi
#    #
#    #__validate "${BULD_VERSION}" "${BULD_DIR_NAME}"/"${BULD_IMAGE}"
#    #if [[ -z ${BULD_VALID} ]]; then
#    #    echo -e "${RED} ~> Invalid version '${BULD_VERSION}'${NC}"
#    #    return
#    #fi
#    #
#    #if [[ ! -d "${BULD_DIR_NAME}/${BULD_IMAGE}/${BULD_VERSION}" ]]; then
#    #    echo -e "${RED} ~> Invalid build '${BULD_DIR_NAME}/${BULD_IMAGE}/${BULD_VERSION}'${NC}"
#    #    return
#    #fi

    New-Item -ItemType Directory -Force -Path "${BULD_DIR_NAME}\\${BULD_IMAGE}\\latest"

    $LATEST="${BULD_DIR_NAME}\\${BULD_IMAGE}\\latest\\Dockerfile"
    $TARGET="${BULD_DIR_NAME}\\${BULD_IMAGE}\\${BULD_VERSION}\\Dockerfile"
    Copy-Item $TARGET $LATEST

    $BUILD_DIRECTORY="${BULD_DIR_NAME}\${BULD_IMAGE}\${BULD_VERSION}"

    Write-Host "~> Building '${BULD_NAMESPACE}' with '$TARGET'" -ForegroundColor Yellow
    docker build -t "${BULD_NAMESPACE}" "${BUILD_DIRECTORY}"

    Write-Host "~> Tagging '${BULD_IMAGE}' with '${BULD_VERSION}'" -ForegroundColor Yellow
    docker tag "${BULD_NAMESPACE}" "${BULD_NAMESPACE}:${BULD_VERSION}"

    Write-Host "~> Pushing '${BULD_NAMESPACE}:${BULD_VERSION}'" -ForegroundColor Yellow
    docker push "${BULD_NAMESPACE}:${BULD_VERSION}"

    Write-Host "~> Pushing '${BULD_NAMESPACE}:latest'" -ForegroundColor Yellow
    docker push "${BULD_NAMESPACE}:latest"

    Write-Host "~> All successfully done" -ForegroundColor green
}

__build
