#!/bin/bash
#
# Run unit tests and pytest files. Optionally, generates coverage report.
#
# Note:
# - Based on mezcla's run_tests.bash.
# - The status of the last command determines whether the dockerfile run fails.
# - This is normally pytest which returns success (0) if no tests fail,
#   excluding tests marked with xfail.
# - Disables nitpicking shellcheck:
#   SC2010: Don't use ls | grep
#   SC2046: Quote this to prevent word splitting.
#   SC2086: Double quote to prevent globbing and word splitting.
#
# Usage:
# $ ./tools/run_tests.bash
# $ ./tools/run_tests.bash --coverage
#

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

script_path="$(realpath -s "$0")"
src_dir="$(dirname "$script_path")"
DEBUG_LEVEL="${DEBUG_LEVEL:-2}"
#
if [ "$DEBUG_LEVEL" -ge 4 ]; then
    echo "in $0 $*"
fi
# Show environment if detailed debugging
if [ "$DEBUG_LEVEL" -ge 5 ]; then
    echo "in $0 $*"
    echo "Environment: {"
    printenv | sort | perl -pe "s/^/    /;"
    echo "   }"
fi
#
base="$src_dir"
tests="$base/tests"
# note: TEST_REGEX is perl-style regex of Python files under tests to run
if [ "$TEST_REGEX" != "" ]; then
    # shellcheck disable=SC2010
    tests=$(ls "$tests"/*.py | grep --perl-regexp "$TEST_REGEX")
fi

echo -e "Running tests on $tests\n"

export PYTHONPATH="$mezcla/:$PYTHONPATH"

# Run with coverage enabled
# shellcheck disable=SC2046,SC2086
if [ "$1" == "--coverage" ]; then
    export COVERAGE_RCFILE="$base/.coveragerc"
    export CHECK_COVERAGE='true'
    coverage erase
    coverage run -m pytest $tests
    coverage combine
    coverage html
else
    pytest $tests
fi
