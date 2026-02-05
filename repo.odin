package repo

import "core:os"
import "core:strings"

Package :: struct {
    name: string
    urls: []string
}

load :: proc() -> []Package {
    data, ok := os.read_entire_file("/etc/script/repo.txt")
    if !ok {
        return nil
    }

    lines := strings.split_lines(string(data))
    pkgs := make([]Package, 0)

    for l in lines {
        l = strings.trim(l)
        if l == "" || strings.has_prefix(l, "#") {
            continue
        }

        parts := strings.split(l, " ")
        if len(parts) >= 2 {
            append(&pkgs, Package{parts[0], parts[1:]})
        }
    }

    return pkgs
}
