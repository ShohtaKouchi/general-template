#!/bin/bash

# SPDX-License-Identifier: Unlicense

# @name Install Hadolint Script
# @brief Script to install hadolint.
# @description This script is used to install hadolint.
# @example
# 	./install_hadolint.sh 2.12.0

# Define the base URL for hadolint downloads.
readonly BASE_URL="https://github.com/hadolint/hadolint/releases/download"

# @brief Validate the version format.
# @arg $1 The version of hadolint.
# @exitcode 0 If the version is valid.
# @exitcode 1 If the version is invalid.
function is_valid_version_format() {
	local -r version="${1}"
	if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		return 0
	else
		return 1
	fi
}

# @brief Get the download URL for hadolint based on the system architecture and version.
# @arg $1 The version of hadolint.
# @stdout Output the download URL.
# @exitcode 0 If the download URL was successfully determined.
# @exitcode 1 If the system architecture is not supported.
function get_hadolint_download_url() {
	local -r version="${1}"
	local -r architecture=$(uname -m)
	case "$architecture" in
		"aarch64")
			download_url="${BASE_URL}/v${version}/hadolint-Linux-arm64"
			;;
		"x86_64")
			download_url="${BASE_URL}/v${version}/hadolint-Linux-x86_64"
			;;
		*)
			echo "Unsupported architecture" >&2
			exit 1
	esac
	echo "$download_url"
}

# @brief Download hadolint.
# @arg $1 The download URL.
# @arg $2 The path to save the downloaded file.
# @exitcode 0 If the download was successful.
# @exitcode 1 If the download failed.
function download_hadolint() {
	local -r download_url="${1}"
	local -r downloaded_file_path="${2}"
	curl -fsSL "$download_url" -o "$downloaded_file_path"
	if [ $? -ne 0 ]; then
		echo "Failed to download hadolint from $download_url" >&2
		exit 1
    fi
}

# @brief Install hadolint.
# @arg $1 The path to the hadolint binary.
function install_hadolint() {
    local -r hadolint_path="${1}"
    if [ ! -f "$hadolint_path" ]; then
		echo "The hadolint binary does not exist at $hadolint_path" >&2
		exit 1
	fi
    mv "$hadolint_path" /usr/local/bin/hadolint
    chmod +x /usr/local/bin/hadolint
}

# @brief Main function.
# @arg $@ The arguments
function main() {
	if [ "$#" -ne 1 ]; then
		echo "The number of arguments provided may be incorrect. This may indicate an error with the way the script is invoked. Please report this to the development team." >&2
		exit 1
    fi
	local -r version="${1}"
	if ! is_valid_version_format "$version"; then
		echo "Invalid version format. Please provide a version in the format X.Y.Z." >&2
		exit 1
	fi
	local -r download_url=$(get_hadolint_download_url "$version")
	local -r download_file_path=$(mktemp)
	download_hadolint "$download_url" "$download_file_path"
	install_hadolint "$download_file_path"
}

# Execute the main function if this script is executed directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	main "$@"
fi
