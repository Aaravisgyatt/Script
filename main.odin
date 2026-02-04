package main

import "core:os"
import "core:fmt"

import config
import installer
import database

usage :: proc() {
    fmt.println("script — package manager")
    fmt.println("usage:")
    fmt.println("  script install <pkg>")
    fmt.println("  script remove  <pkg>")
    fmt.println("  script list")
}

main :: proc() {
    args := os.args
    if len(args) < 2 {
        usage()
        return
    }

    config.init()
    database.init()

    switch args[1] {
    case "install":
        installer.install(args[2])
    case "remove":
        database.remove(args[2])
    case "list":
        database.list()
    default:
        usage()
    }
}
