package database

import "core:os"
import "core:fmt"
import "core:strings"

import config
import log

init :: proc() {
    if _, ok := os.stat(config.DB_PATH); !ok {
        os.write_file(config.DB_PATH, "")
    }
}

register :: proc(name, version: string, files: []string) {
    os.write_file(config.DB_PATH, "[" + name + "]\nversion=\"" + version + "\"\nfiles=[\n", os.File_Write_Append)
    for f in files {
        os.write_file(config.DB_PATH, " \"" + f + "\",\n", os.File_Write_Append)
    }
    os.write_file(config.DB_PATH, "]\n", os.File_Write_Append)
}

list_installed :: proc() {
    data, _ := os.read_entire_file(config.DB_PATH)
    fmt.print(string(data))
}

// Remove package and delete files
remove :: proc(name: string) {
    data, _ := os.read_entire_file(config.DB_PATH)
    lines := strings.split_lines(string(data))
    inside := false
    files := make([]string, 0)

    os.write_file(config.DB_PATH, "") // clear DB

    for l in lines {
        if strings.has_prefix(l, "[" + name + "]") {
            inside = true
            continue
        }
        if inside {
            if strings.has_prefix(l, "]") {
                inside = false
                continue
            }
            if strings.has_prefix(strings.trim(l), "\"") {
                // extract file path
                f := strings.trim(strings.trim(l), "\" ,")
                append(&files, f)
            }
            continue
        }
        os.write_file(config.DB_PATH, l + "\n", os.File_Write_Append)
    }

    // delete files
    for f in files {
        if _, ok := os.stat(f); ok {
            os.remove(f)
            log.info("Deleted " + f)
        }
    }

    log.ok("Removed package " + name)
}
