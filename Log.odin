package log

import "core:fmt"
import "core:time"

VERBOSE :: true

timestamp :: proc() -> string {
	t := time.now()
	return fmt.sprintf("[%04d-%02d-%02d %02d:%02d:%02d]", t.year,t.month,t.day,t.hour,t.minute,t.second)
}

info :: proc(msg: string) { if VERBOSE { fmt.println(timestamp(),"→",msg) } }
ok   :: proc(msg: string) { fmt.println(timestamp(),"✓",msg) }
err  :: proc(msg: string) { fmt.println(timestamp(),"✗",msg) }
