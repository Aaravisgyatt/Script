package installer

import "core:process"

import repo
import config
import database
import log

install :: proc(name: string) {
    pkgs := repo.load()

    for p in pkgs {
        if p.name == name {
            log.info("Installing " + name)

            archive := config.CACHE + "/" + name + ".tar.gz"

            process.run({
                program = "curl",
                args = {"-L", "-o", archive, p.url},
            })

            process.run({
                program = "tar",
                args = {"-xzf", archive, "-C", "/"},
            })

            database.add(name)
            log.ok("Installed " + name)
            return
        }
    }

    log.err("Package not found")
}
