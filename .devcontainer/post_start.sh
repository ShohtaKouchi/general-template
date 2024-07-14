#!/bin/bash

# SPDX-License-Identifier: Unlicense

# @name Dev Container Post Start Script
# @brief Script to execute after starting the Dev Container.
# @description This script is used to execute after starting the Dev Container.
# @example
# 	"postStartCommand": "./.devcontainer/post_start.sh ${containerWorkspaceFolder}",

# @brief Main function.
# @arg $@ The arguments
function main() {

	if [ "$#" -ne 1 ]; then
		echo "The number of arguments provided may be incorrect. This may indicate an error with the way the script is invoked. Please report this to the development team." >&2
		exit 1
	fi
}

# Execute the main function if this script is executed directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

	main "$@"
fi
