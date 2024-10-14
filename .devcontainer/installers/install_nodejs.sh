#!/bin/bash

# SPDX-License-Identifier: Unlicense

# @name NodeJS Installer
# @brief Script to install NodeJS.
# @description This script installs NodeJS based on the specified version or .nvmrc file.
# @example
#   ./install_nodejs.sh --version 22.0.0
#   ./install_nodejs.sh --nvmrc-path ./.nvmrc

# @section Error Handling
# @description Functions for handling errors.

set -CeEu

# Check if the Bash version is 4.4 or higher.
if [ "${BASH_VERSINFO[0]}" -lt 4 ] || { [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -lt 4 ]; }; then

	echo "This script requires Bash version 4.4 or higher." >&2
	exit 1
fi

shopt -s inherit_errexit

# @description Error trap handler.
# @noargs
on_error() {

	echo "Error occurred in function \`${FUNCNAME[1]}\` at line \`${BASH_LINENO[0]}\`." 1>&2
}

# @description Display an error message.
# @arg $1 The error message.
# @stderr The error message.
function raise() {

	echo "$1" 1>&2
	# Return 1 instead of exiting to allow the error trap handler to manage the error.
	return 1
}

trap on_error ERR

# @section Install NodeJS
# @description This section includes functions to download and install NodeJS.

# The minimum supported version of NodeJS.
readonly MIN_SUPPORTED_VERSION=20

# The version of NodeJS to install.
nodejs_version=""

# The version of NodeJS provided as an option.
version_option=""

# The path to the .nvmrc file provided as an option.
nvmrc_path_option=""

# @description Display the usage of the script.
# @noargs
# @stdout The usage of the script.
function usage() {

	cat <<-EOF
		Usage: install_nodejs.sh [OPTIONS]

		Options:
		  --version, -v <version>     The version of NodeJS to install.
		  --nvmrc-path, -n <path>     The path to the .nvmrc file.

		Examples:
		  ./install_nodejs.sh --version 22.0.0
		  ./install_nodejs.sh --nvmrc-path ./.nvmrc
	EOF
}

# @description Validate the version format.
# @arg $1 The version of actionlint.
# @exitcode 0 If the version is valid.
# @exitcode 1 If the version is invalid.
function is_valid_version_format() {

	local -r version="${1}"

	if [ -z "$version" ]; then

		raise "The version of NodeJS is not provided."
	fi

	if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+\*?$ ]] && [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.\*$ ]] && [[ ! "$version" =~ ^[0-9]+\.\*$ ]]; then

		return 1
	fi

	return 0
}

# @description This script installs the specified version of NodeJS.
# @arg $1 The version of NodeJS to install.
# @stdout The completed version of NodeJS.
function complete_version() {
	local -r version="${1}"

	# If the patch version or minor version is not specified, complete it with '*'.
	if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then

		echo "${version}.*"
	# Adding * allows installation regardless of build number or architecture.
	elif [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+\*$ ]]; then

		echo "${version}*"
	fi
}

# @description Download the NodeJS setup.
# @arg $1 The path to download the NodeJS setup.
function download_nodejs_setup() {

	local -r download_path="$1"

	if [ -z "$download_path" ]; then

		raise "The path to download the NodeJS setup is not provided."
	fi

	# Get the major version of NodeJS.
	local -r major_version=$(echo "$nodejs_version" | cut -d '.' -f 1)

	# Check if the major version of NodeJS is a positive integer.
	if ! [[ "$major_version" =~ ^[0-9]+$ ]]; then

		raise "The major version of NodeJS must be a positive integer."
	fi

	local -r nodejs_setup_url="https://deb.nodesource.com/setup_${major_version}.x"

	# Check if the URL is valid.
	if ! curl -s --head "$nodejs_setup_url" >/dev/null; then

		raise "The URL is invalid."
	fi

	# Download the NodeJS setup.
	curl -fsSL -o "$download_path" "$nodejs_setup_url"
}

# @description Execute the NodeJS setup.
# @noargs
function execute_nodejs_setup() {

	# Make temporary file to store the NodeJS setup.
	local -r nodejs_setup=$(mktemp)

	# Download the NodeJS setup.
	download_nodejs_setup "$nodejs_setup"

	# Run the NodeJS setup.
	bash "$nodejs_setup"

	# Clean up.
	rm -f "$nodejs_setup"
}

# @description Install NodeJS.
# @noargs
function install_nodejs() {

	apt-get update
	apt-get install -y nodejs="$nodejs_version"

	# Clean up.
	apt-get clean
	rm -rf /var/lib/apt/lists/*
}

# @description Read the version of NodeJS from the .nvmrc file.
# @arg $1 The path to the .nvmrc file.
# @stdout The version of NodeJS.
function read_nodejs_version_from_nvmrc() {

	local -r nvmrc_path="$1"

	if [ -z "$nvmrc_path" ]; then

		raise "The path to the .nvmrc file is not provided."
	fi

	if [[ ! -f "$nvmrc_path" ]]; then

		raise ".nvmrc file not found at $nvmrc_path."
	fi

	# Read the version of NodeJS to install.
	local -r version=$(cat "$nvmrc_path")

	if [ -z "$version" ]; then

		raise "The version of NodeJS is not provided in the .nvmrc file."
	fi

	echo "$version"
}

# @description Determine the version of NodeJS to install.
# @noargs
# @set nodejs_version The variable that will hold the determined NodeJS version to install.
function determine_nodejs_version() {

	# If the version is specified, ignore nvmrc_path.
	if [ -n "$version_option" ]; then

		nodejs_version=$(complete_version "$version_option")
	else

		local nvmrc_full_path=""
		# If the path to the .nvmrc file is not absolute, make it absolute.
		if [[ ! "$nvmrc_path_option" =~ ^/ ]]; then

			nvmrc_full_path="$(pwd)/\"$nvmrc_path_option\""
		else

			nvmrc_full_path="$nvmrc_path_option"
		fi

		# Read the version of NodeJS from the .nvmrc file.
		local -r nvmrc_version=$(read_nodejs_version_from_nvmrc "$nvmrc_full_path")

		# Complete the version of NodeJS.
		nodejs_version=$(complete_version "$nvmrc_version")
	fi
}

# @description Parse the command-line arguments.
# @arg $@ The command-line arguments.
# @set nvmrc_path_option Sets the path to the .nvmrc file if provided.
# @set version_option Sets the version of NodeJS to install if provided.
function parse_arguments() {

	if [ "$#" -ne 2 ]; then

		raise "The number of arguments provided may be incorrect. Please report this to the development team."
	fi

	while [ "$#" -gt 0 ]; do
		case "$1" in
		--nvmrc-path | -n)

			nvmrc_path_option="$2"
			shift 2
			;;
		--version | -v)

			version_option="$2"
			shift 2
			;;
		*)

			raise "Unknown argument: $1"
			shift
			;;
		esac
	done

	# Check if the version of NodeJS or the path to the .nvmrc file is provided.
	if [ -z "$version_option" ] && [ -z "$nvmrc_path_option" ]; then

		raise "The version of NodeJS or the path to the .nvmrc file is not provided."
	fi
}

# @description Main function.
# @arg $@ The arguments.
function main() {

	if [ "$#" -eq 0 ]; then

		usage
		# Exiting normally as there's no point in raising an error
		exit 0
	fi

	# Parse the arguments.
	parse_arguments "$@"

	# Determine the version of NodeJS to install.
	determine_nodejs_version

	# Check if the version format is valid.
	if ! is_valid_version_format "$nodejs_version"; then

		raise "The version format is invalid: $nodejs_version."
	fi

	# Check if the version of NodeJS is supported.
	if [ "$(echo "$nodejs_version" | cut -d '.' -f 1)" -lt "$MIN_SUPPORTED_VERSION" ]; then

		raise "NodeJS version ${MIN_SUPPORTED_VERSION} or higher is required."
	fi

	echo "Installing NodeJS version $nodejs_version ..."

	# Execute the NodeJS setup.
	execute_nodejs_setup

	# Install NodeJS.
	install_nodejs

	echo "NodeJS version $nodejs_version has been installed."
}

# Execute the main function if this script is executed directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	main "$@"
fi
