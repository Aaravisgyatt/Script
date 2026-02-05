package installer

import "core:os"
import "core:process"
import "core:fmt"

import config
import repo
import database
import manifest
import log"

import "core:crypto/sha256"

download_file :: proc(url: string, dest: string) -> bool {
	dl := process.run({program="curl", args={"-L","-o",dest,url}})
	return dl.exit_code == 0
}

verify_checksum :: proc(file: string, expected: string) -> bool {
	data, ok := os.read_entire_file(file)
	if !ok { return false }
	sum := sha256.hash(data)
	return sum == expected
}

copy_files :: proc(src: string, dest_root: string) -> []string {
	installed := make([]string,0)
	entries, ok := os.read_dir(src)
	if !ok { return nil }
	for e in entries {
		src_path := src + "/" + e.name
		dest_path := dest_root + "/" + e.name
		if e.is_dir {
			os.mkdir_all(dest_path,0o755)
			sub := copy_files(src_path,dest_path)
			for f in sub { append(&installed,f) }
		} else {
			data,_ := os.read_entire_file(src_path)
			os.write_file(dest_path,data,0o644)
			append(&installed,dest_path)
		}
	}
	return installed
}

install :: proc(name: string) {
	pkgs := repo.load()
	for p in pkgs {
		if p.name != name { continue }

		// Try all mirrors
		var archive_ok bool = false
		archive := config.CACHE + "/" + name + ".tar.gz"
		temp := config.SANDBOX + "/" + name
		os.mkdir_all(temp,0o755)
		for _,url in p.urls {
			if download_file(url,archive) {
				archive_ok = true
				break
			}
		}
		if !archive_ok { log.err("Failed to download "+name); return }

		// Extract
		extract := process.run({program="tar", args={"-xzf",archive,"-C",temp}})
		if extract.exit_code !=0 { log.err("Failed to extract "+name); return }

		m := manifest.load(temp + "/manifest.toml")

		// Check SHA256
		if m.sha256 != "" && !verify_checksum(archive,m.sha256) {
			log.err("Checksum mismatch for "+name)
			return
		}

		// Install dependencies
		for _,dep in m.depends { install(dep) }

		// Copy files to sandbox
		files := copy_files(temp + "/files", temp)

		database.register(m.name,m.version,files,m.depends)
		log.ok("Installed "+m.name+" v"+m.version)
		return
	}
	log.err("Package "+name+" not found")
}

remove :: proc(name: string) { database.remove(name) }

upgrade :: proc(name: string) {
	remove(name)
	install(name)
}

rollback :: proc(name: string) {
	log.info("Rollback not implemented yet")
}

info :: proc(name: string) {
	ver, deps, files := database.read_package(name)
	log.info("Package: " + name)
	log.info("Version: " + ver)
	log.info("Depends: " + strings.join(deps,", "))
	log.info("Files: " + strings.join(files,", "))
}
