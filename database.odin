package database

import "core:os"
import "core:strings"
import "core:fmt"

import config

init :: proc() {
    if _, ok := os.stat(config.DB_PATH); !ok {
        os.write_file(config.DB_PATH, "")
    }
}

add :: proc(name: string) {
    os.write_file(config.DB_PATH, name + "\n", os.File_Write_Append)
}

list :: proc() {
    data, _ := os.read_entire_file(config.DB_PATH)
    fmt.print(string(data))
}

remove :: proc(name: string) {
    data, _ := os.read_entire_file(config.DB_PATH)
    lines := strings.split_lines(string(data))

    os.write_file(config.DB_PATH, "")
    for l in lines {
        if l != name {
            os.write_file(config.DB_PATH, l + "\n", os.File_Write_Append)
        }
    }
}
