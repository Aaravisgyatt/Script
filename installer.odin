package installer

import "core:os"
import "core:process"
import "core:fmt"

import config
import repo
import database
import manifest
import log

install :: proc(name: string) {
    pkgs := repo.load()

    for p in pkgs {
        if p.name == name {
            log.info("Downloading " + name)

            archive := config.CACHE + "/" + name + ".tar.gz"
            temp := config.CACHE + "/extract/" + name
            os.mkdir_all(temp, 0o755)

            // Download package
            download := process.run({
                program = "curl",
                args = {"-L", "-o", archive, p.url},
            })
            if download.exit_code != 0 {
                log.err("Failed to download " + name)
                return
            }

            // Extract package
            extract := process.run({
                program = "tar",
                args = {"-xzf", archive, "-C", temp},
            })
            if extract.exit_code != 0 {
                log.err("Failed to extract " + name)
                return
            }

            // Load manifest
            m := manifest.load(temp + "/" + name + "/manifest.toml")
            log.info("Installing " + m.name + " v" + m.version)
            log.info("Description: " + m.description)

            // Copy files and track installed paths
            installed_files := copy_files(temp + "/" + name + "/files", "/")

            // Register in database
            database.register(m.name, m.version, installed_files)

            log.ok("Installed " + m.name + " successfully")
            return
        }
    }

    log.err("Package " + name + " not found in repo")
}

// Recursive copy helper
copy_files :: proc(src: string, dest_root: string) -> []string {
    installed := make([]string, 0)
    entries, ok := os.read_dir(src)
    if !ok {
        log.err("Failed to read directory: " + src)
        return nil
    }

    for e in entries {
        src_path := src + "/" + e.name
        dest_path := dest_root + "/" + e.name

        if e.is_dir {
            os.mkdir_all(dest_path, 0o755)
            sub_files := copy_files(src_path, dest_path)
            for f in sub_files {
                append(&installed, f)
            }
        } else {
            data, _ := os.read_entire_file(src_path)
            os.write_file(dest_path, data, 0o644)
            append(&installed, dest_path)
        }
    }

    return installed
}

// Remove package using DB and delete files
remove :: proc(name: string) {
    database.remove(name)
}
