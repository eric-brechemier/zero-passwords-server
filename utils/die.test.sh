#!/bin/sh
# Unit tests for die() utility
#
# Standard Output:
#   Test results in TAP format [1].
#
# Reference:
#   [1] TAP (Test Anything Protocol) specification
#   http://testanything.org/tap-specification.html

cd "$(dirname "$0")"
. ./die.sh

echo "1..4"

if test "$(type -t 'die') = 'function'"
then
  echo 'ok 1 - die() is a function'
else
  echo 'not ok 1 - die() should be a function,' \
       "found '$(type -t 'die')' instead"
fi

setStatusCode()
{
  return $1
}

testMessage="TEST ERROR MESSAGE"
testStatusCode=42
setStatusCode $testStatusCode
standardError="$( die "$testMessage" 2>&1 1>/dev/null )"
statusCode=$?

if test "$standardError" = "$testMessage"
then
  echo 'ok 2 - given error message is printed on standard error'
else
  echo 'not ok 2 - expected message not found on standard error,' \
       "found '"$standardError"' instead"
fi

if test $statusCode -eq "$testStatusCode"
then
  echo 'ok 3 - non-zero status code of previous command is returned by die()'
else
  echo 'not ok 3 - die() shall return' \
       'non-zero status code of previous command,' \
       "found $statusCode instead"
fi

setStatusCode 0
( die "$testMessage" 2>/dev/null )
statusCode=$?

if test $statusCode -ne 0
then
  echo 'ok 4 - die() never returns a zero status code'
else
  echo 'not ok 4 - die() shall not return' \
       'zero status code of previous command,' \
       "found: $statusCode"
fi
