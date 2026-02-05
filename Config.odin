package config

import "core:os"

ROOT      :: "/"
DB_PATH   :: "/var/lib/script/db.toml"
CACHE     :: "/var/cache/script"
REPO      :: "/etc/script/repo.txt"
SANDBOX   :: "/opt/script"

init :: proc() {
	os.mkdir_all("/var/lib/script", 0o755)
	os.mkdir_all(CACHE, 0o755)
	os.mkdir_all("/etc/script", 0o755)
	os.mkdir_all(SANDBOX, 0o755)
}
