#!/usr/bin/env bash

# ```bash
# chmod +x tests/test_gdb_main.sh
# ./tests/test_gdb_main.sh
# ```

set -xe

# Warmup before test
#
stat scratch

# Run tests via gdb aka The GNU Debugger
#	run once and output registers info at exit
yes | time gdb -ex "set disassembly-flavor intel" \
	-ex "break _start" \
	-ex "run" \
	-ex "info registers" \
	-ex "quit" \
	./scratch
sleep 2
#	run interactively
gdb -ex "set disassembly-flavor intel" \
	-ex "break _start" \
	-ex "run" \
	-ex "layout next" -ex "lay n" -ex "lay n" -ex "lay n" \
	-ex "nexti" \
	./scratch

# Notes
#
# 	`yes` command is used to interactively help use exit gdb when prompted
# 	for quit:
# 	(gdb) Quit anyway? (y or n) [answered Y; input not from terminal]
