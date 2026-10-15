#!/bin/bash
#
#  .cmy (複数の TESRY データをまとめたもの) を個別の .yaml に展開する
#
#  usage: expand_tesry.sh <outdir> <cmy>...
#  <outdir>/<cmy 名>/*.yaml を作る (aktb.sh の expand_tesry と同じ配置)
#
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
AKTSP=$(cd "$HERE/../../.." && pwd)
[ $# -ge 2 ] || { echo "usage: $0 <outdir> <cmy>..."; exit 1; }
out=$1; shift
mkdir -p "$out"
for cmy in "$@"; do
  cmy=$(cd "$(dirname "$cmy")" && pwd)/$(basename "$cmy")
  name=$(basename "$cmy" .cmy)
  rm -rf "$out/$name"; mkdir -p "$out/$name"
  (cd "$out/$name" && ruby "$AKTSP/tools/akc2y/akc2y.rb" -d "$cmy" > /dev/null)
  echo "$name: $(ls "$out/$name" | wc -l) yaml"
done
