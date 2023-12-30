#!/bin/bash
#
# This hook is called by 'git push' and can be used to prevent a push from taking place.
#

# Stylua check
stylua --check lua/ --config-path ./.stylua.toml || exit 1
echo "Stylua check passed"

# Stylua Tests
stylua --check tests/ --config-path ./.stylua.toml || exit 1
echo "Stylua check tests passed"

# Luacheck
luacheck lua/ --globals vim || exit 1
echo "Luacheck passed"

# Echo success
echo "Pre-push checks passed"
exit 0

