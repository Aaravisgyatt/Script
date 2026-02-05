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

register :: proc(name, version: string, files: []string, depends: []string) {
	os.write_file(config.DB_PATH, "[" + name + "]\nversion=\"" + version + "\"\ndepends=[\n", os.File_Write_Append)
	for d in depends {
		os.write_file(config.DB_PATH, " \"" + d + "\",\n", os.File_Write_Append)
	}
	os.write_file(config.DB_PATH, "]\nfiles=[\n", os.File_Write_Append)
	for f in files {
		os.write_file(config.DB_PATH, " \"" + f + "\",\n", os.File_Write_Append)
	}
	os.write_file(config.DB_PATH, "]\n", os.File_Write_Append)
}

list_installed :: proc() {
	data, _ := os.read_entire_file(config.DB_PATH)
	fmt.print(string(data))
}

// Read installed package info
read_package :: proc(name: string) -> (version: string, depends: []string, files: []string) {
	data, _ := os.read_entire_file(config.DB_PATH)
	lines := strings.split_lines(string(data))
	inside := ""
	depends := make([]string, 0)
	files := make([]string, 0)
	version := ""

	for l in lines {
		l = strings.trim(l)
		if strings.has_prefix(l, "[") {
			if l == "[" + name + "]" {
				inside = name
			} else {
				inside = ""
			}
		}
		if inside == name {
			if strings.has_prefix(l, "version") {
				version = strings.trim(strings.split(l, "=")[1], "\" ")
			} else if strings.has_prefix(l, "depends") {
				continue // parsed in installer
			} else if strings.has_prefix(l, "files") {
				continue
			} else if strings.has_prefix(l, "\"") {
				if strings.contains(l, ".") {
					append(&files, strings.trim(l, "\" ,"))
				} else {
					append(&depends, strings.trim(l, "\" ,"))
				}
			}
		}
	}
	return version, depends, files
}

// Remove package
remove :: proc(name: string) {
	version, _, files := read_package(name)

	for f in files {
		if _, ok := os.stat(f); ok {
			os.remove(f)
			log.info("Deleted " + f)
		}
	}

	data, _ := os.read_entire_file(config.DB_PATH)
	lines := strings.split_lines(string(data))
	os.write_file(config.DB_PATH, "")

	inside := false
	for l in lines {
		if strings.has_prefix(l, "[" + name + "]") { inside = true; continue }
		if inside && strings.has_prefix(l, "]") { inside = false; continue }
		if !inside { os.write_file(config.DB_PATH, l + "\n", os.File_Write_Append) }
	}

	log.ok("Removed package " + name + " v" + version)
}
