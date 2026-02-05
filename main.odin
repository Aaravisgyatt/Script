package main

VERSION :: "0.3.0"

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
	fmt.println("  script upgrade <package>")
	fmt.println("  script rollback <package>")
	fmt.println("  script info <package>")
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
		installer.install(args[2])

	case "remove":
		if len(args) < 3 {
			fmt.println("error: no package specified")
			return
		}
		installer.remove(args[2])

	case "list":
		database.list_installed()

	case "upgrade":
		if len(args) < 3 {
			fmt.println("error: no package specified")
			return
		}
		installer.upgrade(args[2])

	case "rollback":
		if len(args) < 3 {
			fmt.println("error: no package specified")
			return
		}
		installer.rollback(args[2])

	case "info":
		if len(args) < 3 {
			fmt.println("error: no package specified")
			return
		}
		installer.info(args[2])

	case "--version", "-v":
		fmt.println(VERSION)

	case "--help", "-h":
		usage()

	default:
		fmt.println("unknown command:", command)
		usage()
	}
}
