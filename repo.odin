package repo

import "core:os"
import "core:strings"

import config

Package :: struct {
    name: string
    url:  string
}

load :: proc() -> []Package {
    data, ok := os.read_entire_file(config.REPO)
    if !ok return nil

    lines := strings.split_lines(string(data))
    pkgs := make([]Package, 0)

    for l in lines {
        parts := strings.split(l, " ")
        if len(parts) >= 2 {
            append(&pkgs, Package{parts[0], parts[1]})
        }
    }

    return pkgs
}
