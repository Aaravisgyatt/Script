package main

VERSION :: "0.2.0"

import "core:fmt"
import "core:os"

import config
import installer
import database

usage :: proc() {
	fmt.println("script — package manager v" + VERSION)
	fmt.println("")
	fmt.println("Usage:")
	fmt.println("  script install <package>")
	fmt.println("  script remove <package>")
	fmt.println("  script list")
	fmt.println("  script --version")
	fmt.println("")
}

main :: proc() {
	args := os.args

	if len(args) < 2 {
		usage()
		return
	}

	command := args[1]

	switch command {
	case "install":
		if len(args) < 3 {
			fmt.println("error: no package specified")
			return
		}
		pkg := args[2]
		installer.install(pkg)

	case "remove":
		if len(args) < 3 {
			fmt.println("error: no package specified")
			return
		}
		pkg := args[2]
		installer.remove(pkg)

	case "list":
		database.list_installed()

	case "--version", "-v":
		fmt.println(VERSION)

	case "--help", "-h":
		usage()

	default:
		fmt.println("unknown command:", command)
		usage()
	}
}
