#!/bin/bash
echo 'gdb te -ex "set disassembly-flavor intel" -ex "lay next" -ex "lay next" -ex "lay next" -ex "lay next" -ex "b _start"'
gdb te -ex "set disassembly-flavor intel" -ex "lay next" -ex "lay next" -ex "lay next" -ex "lay next" -ex "b _start"

