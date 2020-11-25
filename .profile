REPO_DIR=$(dirname ${BASH_SOURCE})
GIT_DIR=$(cd "${REPO_DIR}/.."; pwd)

# basic command prompt
export PS1='$(pwd)/ $ '

if [[ -z "${PATH_ORIG}" ]]; then
    PATH_ORIG=$PATH
fi

PATH="${PATH_ORIG}"
PATH+=":${GIT_DIR}/cli"
PATH+=":${GIT_DIR}/cli_assert"
PATH+=":${GIT_DIR}/cli_util"
PATH+=":${GIT_DIR}/cli_emit"
PATH+=":${GIT_DIR}/integrate"
PATH+=":${GIT_DIR}/vscs"
PATH+=":${GIT_DIR}/azx"