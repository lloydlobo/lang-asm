#!/usr/bin/env bash

set -xe

cc code.c -o binary
./binary
