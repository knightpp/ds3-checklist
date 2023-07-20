#/bin/env bash

set -euo pipefail

flatc --dart *.fbs
mv *.dart ../ds3_checklist/lib/Generated/
