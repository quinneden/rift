# Usage: nix .#bump-version
# shellcheck shell=bash

error() {
	local RED="\033[0;31m"
	local RESET="\033[0m"
	echo -e "${RED}error:${RESET} $*" >&2
}

repoRoot=$(git rev-parse --show-toplevel)
semverRegex="^([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$"

currentVersion=@currentVersion@
newVersion="${1:-}"

cd "$repoRoot" &>/dev/null || error "failed to change directory to repository top-level"

if [[ -z $newVersion ]]; then
	error "no version specified"
	exit 1
elif ! grep -qE "$semverRegex" <<<"$newVersion"; then
	error "invalid version format"
	exit 1
fi

if ! uncommittedChanges=$(git status --porcelain); then
	error "failed to get uncommitted changes"
	exit 1
fi

if [[ -n $uncommittedChanges ]]; then
	error "there are uncommitted changes"
	exit 1
fi

if ! gitRemote=$(git remote get-url origin &>/dev/null); then
	error "failed to get remote URL"
	exit 1
fi

if ! currentBranch=$(git branch --show-current 2>/dev/null); then
	error "failed to get current branch"
	exit 1
fi

if [[ $currentBranch != "main" ]]; then
	error "not on main branch"
	exit 1
fi

if ! commitsBehind=$(git rev-list HEAD..origin/"$currentBranch" --count); then
	error "failed to get commits behind"
	exit 1
fi

if [[ $commitsBehind -ne 0 ]]; then
	error "this branch is $commitsBehind commits behind origin/$currentBranch"
	exit 1
fi

if ! sed -i "s|^version = \"${currentVersion}\"$|version = \"${newVersion}\"|g" Cargo.toml; then
	error "failed to update version in Cargo.toml"
	exit 1
fi

if ! {
	git add Cargo.toml
	git commit -m "chore(Cargo.toml): bump version $currentVersion -> $newVersion"
}; then
	error "failed to commit changes"
	exit 1
fi

if ! git tag -a "v$newVersion"; then
	error "failed to create tag "
	exit 1
fi

if ! {
	git push origin main
	git push origin "v$newVersion"
}; then
	error "failed to push to remote"
	exit 1
fi

echo "Successfully bumped version to $newVersion and pushed to remote"
