package main

import (
	"fmt"
	"os"
	"strings"
)

const usage = `recall - search past opencode sessions

usage:
  recall search <keyword>... [--mode and|or] [--project dir] [--after date] [--before date]
                [--role user|assistant|tool|reasoning|any] [--limit n] [--db path]... [--json]
  recall show <session> [--keywords k]... [--reasoning] [--tools] [--full] [--max-chars n] [--db path]...
  recall sessions [--project dir] [--limit n] [--json] [--db path]...

session ref: full id, unique id prefix (min 4 chars), or exact slug
dates: YYYY-MM-DD (local time)
dbs default to ~/.local/share/opencode/*.db`

func main() {
	if len(os.Args) < 2 {
		die(usage)
	}
	var err error
	switch os.Args[1] {
	case "search":
		err = cmdSearch(os.Args[2:])
	case "show":
		err = cmdShow(os.Args[2:])
	case "sessions":
		err = cmdSessions(os.Args[2:])
	case "help", "-h", "--help":
		fmt.Println(usage)
	default:
		die(fmt.Sprintf("unknown command %q\n\n%s", os.Args[1], usage))
	}
	if err != nil {
		die(err.Error())
	}
}

func die(msg string) {
	fmt.Fprintln(os.Stderr, msg)
	os.Exit(1)
}

type flagSet map[string][]string

// parseArgs accepts flags anywhere in argv. "list" flags greedily consume all
// following non-flag arguments (--keywords a b c), "valued" flags take one.
func parseArgs(args []string, boolean, valued, list []string) (flagSet, []string, error) {
	isBool := make(map[string]bool)
	for _, n := range boolean {
		isBool[n] = true
	}
	isVal := make(map[string]bool)
	for _, n := range valued {
		isVal[n] = true
	}
	isList := make(map[string]bool)
	for _, n := range list {
		isList[n] = true
	}
	out := flagSet{}
	var pos []string
	for i := 0; i < len(args); i++ {
		a := args[i]
		if a == "-" || !strings.HasPrefix(a, "-") {
			pos = append(pos, a)
			continue
		}
		name := strings.TrimLeft(a, "-")
		var val string
		hasVal := false
		if eq := strings.IndexByte(name, '='); eq >= 0 {
			val, hasVal = name[eq+1:], true
			name = name[:eq]
		}
		switch {
		case isBool[name]:
			if hasVal {
				out[name] = append(out[name], val)
			} else {
				out[name] = append(out[name], "true")
			}
		case isVal[name]:
			if !hasVal {
				i++
				if i >= len(args) {
					return nil, nil, fmt.Errorf("flag -%s needs a value", name)
				}
				val = args[i]
			}
			out[name] = append(out[name], val)
		case isList[name]:
			if hasVal {
				out[name] = append(out[name], val)
				break
			}
			for i+1 < len(args) && !strings.HasPrefix(args[i+1], "-") {
				i++
				out[name] = append(out[name], args[i])
			}
			if len(out[name]) == 0 {
				return nil, nil, fmt.Errorf("flag -%s needs at least one value", name)
			}
		default:
			return nil, nil, fmt.Errorf("unknown flag -%s", name)
		}
	}
	return out, pos, nil
}

func (fl flagSet) has(name string) bool {
	_, ok := fl[name]
	return ok
}

func (fl flagSet) val(name string) string {
	if v, ok := fl[name]; ok && len(v) > 0 {
		return v[len(v)-1]
	}
	return ""
}

func (fl flagSet) intVal(name string, def int) int {
	v := fl.val(name)
	if v == "" {
		return def
	}
	n := 0
	for _, c := range v {
		if c < '0' || c > '9' {
			return def
		}
		n = n*10 + int(c-'0')
	}
	return n
}
