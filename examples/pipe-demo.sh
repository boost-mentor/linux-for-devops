set -e
false | cat
echo without-pipefail
set -o pipefail
false | cat
echo after
