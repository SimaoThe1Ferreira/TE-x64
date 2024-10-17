#!/bin/bash
echo "as te.s -o te.o"
as te.s -o te.o
echo "ld te.o -o te -static"
ld te.o -o te.elf -static
echo "rm te.o"
rm te.o

