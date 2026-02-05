package manifest

import "core:os"
import "core:strings"

Manifest :: struct {
    name:        string
    version:     string
    description: string
    depends:     []string
    sha256:      string
}

load :: proc(path: string) -> Manifest {
    data, _ := os.read_entire_file(path)
    text := string(data)
    m := Manifest{}
    lines := strings.split_lines(text)

    for l in lines {
        l = strings.trim(l)
        if strings.has_prefix(l, "name") {
            m.name = strings.trim(strings.split(l, "=")[1], "\" ")
        }
        if strings.has_prefix(l, "version") {
            m.version = strings.trim(strings.split(l, "=")[1], "\" ")
        }
        if strings.has_prefix(l, "description") {
            m.description = strings.trim(strings.split(l, "=")[1], "\" ")
        }
        if strings.has_prefix(l, "depends") {
            dep_list := strings.split(strings.split(l, "=")[1], ",")
            for d in dep_list {
                append(&m.depends, strings.trim(d, "\" "))
            }
        }
        if strings.has_prefix(l, "sha256") {
            m.sha256 = strings.trim(strings.split(l, "=")[1], "\" ")
        }
    }

    return m
}
