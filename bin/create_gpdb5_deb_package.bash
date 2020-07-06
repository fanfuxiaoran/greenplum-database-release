#!/usr/bin/env bash

set -eo pipefail

# shellcheck disable=SC1091
source bin/common.bash
export BUILD_IMAGE=ubuntu:16.04

build_gpdb5_deb() {
	echo "Creating DEB Package..."
	docker build --tag debian-build:5X_STABLE "$(dirname "$0")"/..
	rm -rf "${BUILD_DIR}"/gpdb5_deb_installer
	mkdir -p "${BUILD_DIR}"/gpdb5_deb_installer
	docker run -it --rm -v "${BUILD_DIR}"/gpdb5_deb_installer:/output debian-build:5X_STABLE bash -c "cp /tmp/greenplum-db*.deb /output"
}

check_deb_installer() {
	cat <<EOF >>"${CHECK_SCRIPT}"
#!/bin/bash
set -ex
apt-get update
apt-get install -y "\${1}"
EOF

	chmod a+x "${CHECK_SCRIPT}"
	INSTALLER=$(echo "${BUILD_DIR}"/gpdb5_deb_installer/*.deb) check_installer
}

main() {
	build_gpdb5_deb
	check_deb_installer
}

main
