#!/bin/sh

swift build -c release
cp .build/release/Coverage executables/
