#!/bin/bash

# SPDX-License-Identifier: Unlicense

# @name Dev Container Post Create Script
# @brief Script to execute after creating the Dev Container.
# @description This script is used to execute after creating the Dev Container.
# @example
# 	"postCreateCommand": "./.devcontainer/post_create.sh"

# @brief Restore the dependencies.
# @noargs
function restore_dependencies() {
	:
}

# @brief Change the ownership of the volumes.
# @noargs
# @description Docker volumes are created with root ownership. This function changes the ownership of the volumes to the current user.
function change_volume_ownership() {

	sudo chown -R "$(whoami)" ./node_modules
	sudo chown -R "$(whoami)" ./.pnpm-store
}

# @brief Main function.
# @arg $@ The arguments
function main() {

	# Change the ownership of the volumes.
	change_volume_ownership

	# Restore the dependencies.
	restore_dependencies
}

# Execute the main function if this script is executed directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	main "$@"
fi
