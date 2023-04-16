generate_update_inputs() {
	nix flake metadata "$1" --json | jq -r '.locks.nodes  | keys_unsorted[] | select(startswith("my"))' | awk -v d=" --update-input " '{s=(s d)$0}END{print s}'
}

FLAKES=$(find . -name "flake.lock")

for flake in $FLAKES; do

	dir=$(dirname "$flake")
	update_inputs=$(generate_update_inputs "$dir")

	echo nix flake lock "$dir" $update_inputs
	nix flake lock "$dir" $update_inputs
done
