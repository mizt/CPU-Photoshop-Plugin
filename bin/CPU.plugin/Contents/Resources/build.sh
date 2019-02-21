#!/bin/bash
cd "$(dirname "$0")"
clang++ ./main.mm -dynamiclib -std=c++14 -Wc++14-extensions -arch x86_64 -fobjc-arc -framework Cocoa -O3 -o ./CPU.dylib
