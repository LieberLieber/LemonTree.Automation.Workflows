function oid_to_path {
  local oid="$1"
  local dir="$(git lfs env | git grep LocalMediaDir | cut -d '=' -f 2)"

  echo "$dir/${oid:0:2}/${oid:2:2}/$oid"
}

$rev1="$(git rev-parse "$1")"
$rev2="$(git rev-parse "$2")"
$fname="$3"

$oid1="$(git cat-file -p "$rev1":"$fname" | grep oid | cut -d ':' -f 2)"
$oid2="$(git cat-file -p "$rev2":"$fname" | grep oid | cut -d ':' -f 2)"

$path1="$(oid_to_path "$oid1")"
$path2="$(oid_to_path "$oid2")"

diff -U "$path1" "$path2"