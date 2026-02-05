package manifest

import "core:os"
import "core:strings"

Manifest :: struct {
    name:        string
    version:     string
    description: string
}

load :: proc(path: string) -> Manifest {
    data, _ := os.read_entire_file(path)
    text := string(data)

    m := Manifest{}
    lines := strings.split_lines(text)

    for l in lines {
        l = strings.trim(l)
        if strings.has_prefix(l, "name") {
            m.name = strings.trim(strings.split(l, "=")[1])
            m.name = strings.trim(m.name, "\"")
        }
        if strings.has_prefix(l, "version") {
            m.version = strings.trim(strings.split(l, "=")[1])
            m.version = strings.trim(m.version, "\"")
        }
        if strings.has_prefix(l, "description") {
            m.description = strings.trim(strings.split(l, "=")[1])
            m.description = strings.trim(m.description, "\"")
        }
    }

    return m
}
