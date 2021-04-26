#! /bin/sh
set -x
# maven plugin version
VER=$1
BASEDIR=${PWD}
# destination of generated binaries
BIN="${BASEDIR}/bin"
# destination of the test reports
TEST="${BASEDIR}/test-results"
# failure file
FAILED="${TEST}/failed"
NAME="durable_task_monitor"

# gotestsum will generate junit test reports. v0.4.2 is the latest compatible with golang 1.14
rm -rf "${TEST}"
mkdir -p "${TEST}"
cd ${BASEDIR}/pkg/common
go mod tidy
go get -v gotest.tools/gotestsum@v0.4.2
if ! gotestsum --format standard-verbose --junitfile ${TEST}/common-unit-test.xml
then
  echo "common" >> ${FAILED}
fi
cd ${BASEDIR}/cmd/bash
go mod tidy
go get -v gotest.tools/gotestsum@v0.4.2
if ! gotestsum --format standard-verbose --junitfile ${TEST}/bash-unit-test.xml
then
  echo "bash" >> ${FAILED}
fi
#TODO: Windows test
#cd ${SRC}/cmd/windows
#go mod tidy
#go get -v gotest.tools/gotestsum@v0.4.2
#gotestsum --format standard-verbose --junitfile ${TEST}/windows-unit-test.xml

# build the binaries
rm -rf ${BIN}
mkdir ${BIN}
cd ${BASEDIR}/cmd/bash
env CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -a -o ${BIN}/${NAME}_${VER}_darwin_64
env CGO_ENABLED=0 GOOS=darwin GOARCH=386 go build -a -o ${BIN}/${NAME}_${VER}_darwin_32
env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o ${BIN}/${NAME}_${VER}_unix_64
env CGO_ENABLED=0 GOOS=linux GOARCH=386 go build -a -o ${BIN}/${NAME}_${VER}_unix_32
#TODO: Windows build
#cd ${BASEDIR}/cmd/windows
#env CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -a -o ${BIN}/${NAME}_${VER}_win_64
#env CGO_ENABLED=0 GOOS=windows GOARCH=386 go build -a -o ${BIN}/${NAME}_${VER}_win_32

echo "binary generation complete. If you are still seeing this message, press Ctrl-C to exit."