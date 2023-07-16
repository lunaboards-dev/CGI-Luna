#!/usr/bin/env bash
for e in $(ls luna_modules); do
    if [[ -d "luna_modules/$e" ]]; then
        echo ":: Building $e..."
        lua luna_modules/build.lua "luna_modules/$e" "luna/modules/$e.cpio"
    fi
done