package log

import "core:fmt"

info :: proc(msg: string) { fmt.println("→", msg) }
ok   :: proc(msg: string) { fmt.println("✓", msg) }
err  :: proc(msg: string) { fmt.println("✗", msg) }
